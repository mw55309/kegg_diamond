shell.executable("/bin/bash")
shell.prefix("source $HOME/.bashrc; ")

IDS, = glob_wildcards("{id}.fastq.gz")
RIDS, = glob_wildcards("{rid}.R1.fastq.gz")
GIDS, = glob_wildcards("genome_ids/{gid}.txt")

localrules: kocount, countstable

rule all:
	input:  expand("kocounts/{sample2}.out", sample2=RIDS), expand("kraken/{sample3}.report", sample3=RIDS), "kocounttable/kocounttable.tsv", expand("trimmed/{sample4}_1.t.fastq.gz", sample4=GIDS), "abyss.done", "kraken.family.xlsx"

rule build_diamond:
	input: "/exports/cmvm/eddie/eb/groups/watson_grp/data/kegg_data/all_bacterial_archaeal_pep.fasta"
	output: "/exports/cmvm/eddie/eb/groups/watson_grp/data/kegg_data/all_bacterial_archaeal_pep.fasta.dmnd"
	conda: "envs/diamond.yaml"
	shell:
		'''
		diamond makedb --in {input} -d {output}
		'''

rule diamond_search:
	input: 
		R=ancient("{id}.fastq.gz"),
		db="/exports/cmvm/eddie/eb/groups/watson_grp/data/kegg_data/all_bacterial_archaeal_pep.fasta.dmnd"
	output: "diamond/{id}.out"
	threads: 8
	params:
		of="6 qseqid sseqid stitle pident qlen slen length mismatch gapopen qstart qend sstart send evalue bitscore"
	conda: "envs/diamond.yaml"
	shell:
		'''
		diamond blastx --query {input.R} --threads {threads} --outfmt {params.of} -d {input.db} --max-target-seqs 10 > {output}
		'''

rule diamond2ko:
	input: 
		R1="diamond/{rid}.R1.out",
		R2="diamond/{rid}.R2.out"
	output: "ko/{rid}.out"
	threads: 4
	shell:
		'''
		perl scripts/diamond2ko.pl {input.R1} {input.R2} > {output}
		'''

rule kocount:
	input: "ko/{rid}.out"
	output: "kocounts/{rid}.out"
	shell:
		'''
		cat {input} | awk '{{print $2}}' | sort | uniq -c | sed -e 's/^\s*//' > {output}
		'''

rule countstable:
	input: expand("kocounts/{sample3}.out", sample3=RIDS)
	output: "kocounttable/kocounttable.tsv"
	params: 
		dir="kocounts"
	shell:
		'''
		perl scripts/find_counts.pl {params.dir} > {output}
		module load R
		module load java
		scripts/process.kegg.R {output} "../data/kegg_data/ko_names.txt" "kocounttable/kocounttable"
		'''

rule kraken:
	input:
		R1=ancient("{rid}.R1.fastq.gz"),
		R2=ancient("{rid}.R2.fastq.gz")
	output: 
		raw="kraken/{rid}.kraken",
		rep="kraken/{rid}.report"
	conda: "envs/kraken.yaml"
	params:
		db="/exports/cmvm/eddie/eb/groups/watson_grp/hungate_1000/bfap_hungate_rug2_plus/"
	threads: 16
	shell:
		'''
		kraken --preload --db {params.db} --threads 16 --fastq-input --gzip-compressed --output {output.raw} --paired {input.R1} {input.R2}
		kraken-report --db {params.db} {output.raw} > {output.rep}
		'''

rule kraken_summary:
	input:  expand("kraken/{sample6}.report", sample6=RIDS)
	output: "kraken.family.txt"
	shell:
		'''
		perl scripts/kraken_summary.pl {input}
		'''

rule kraken_to_excel:
	input: "kraken.family.txt"
	output: "kraken.family.xlsx"
	conda: "envs/xlsx.yaml"
	shell:
		'''
		./scripts/process.R kraken.kingdom.txt
		./scripts/process.R kraken.phylum.txt
		./scripts/process.R kraken.family.txt
		./scripts/process.R kraken.genus.txt
		'''

rule cutadapt:
	input: "genome_ids/{gid}.txt"
	output:
		R1="trimmed/{gid}_1.t.fastq.gz",
		R2="trimmed/{gid}_2.t.fastq.gz"
	params:
		gid="{gid}"
	conda: "envs/cutadapt.yaml"
	threads: 4
	shell: "curl https://raw.githubusercontent.com/WatsonLab/GoogleMAGs/master/scripts/ftp_n_trimm.sh | bash -s {params.gid} {output.R1} {output.R2}"


rule assemble:
	input: expand("trimmed/{sample5}_1.t.fastq.gz", sample5=GIDS)
	output: "abyss.done"
	conda: "envs/abyss.yaml"
	threads: 16
	shell: 
		'''
		abyss-pe np={threads} k=31 name=o_ostertagi lib='SRR2568723  SRR2864012  SRR2864990  SRR2895242  SRR2895243  SRR2895244' SRR2568723='trimmed/SRR2568723_1.t.fastq.gz trimmed/SRR2568723_2.t.fastq.gz' SRR2864012='trimmed/SRR2864012_1.t.fastq.gz trimmed/SRR2864012_2.t.fastq.gz' SRR2864990='trimmed/SRR2864990_1.t.fastq.gz trimmed/SRR2864990_2.t.fastq.gz' SRR2895242='trimmed/SRR2895242_1.t.fastq.gz trimmed/SRR2895242_2.t.fastq.gz' SRR2895243='trimmed/SRR2895243_1.t.fastq.gz trimmed/SRR2895243_2.t.fastq.gz' SRR2895244='trimmed/SRR2895244_1.t.fastq.gz trimmed/SRR2895244_2.t.fastq.gz' && touch {output}
		'''
	
