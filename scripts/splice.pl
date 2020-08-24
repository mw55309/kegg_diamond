#!/usr/bin/perl

my $r1 = shift;
my $r2 = shift;

my $cat = "cat";
if ($r1 =~ m/\.gz/) {
	$cat = "zcat";
}

open(R1, "$cat $r1 \| paste - - - - |");

my $cat = "cat";
if ($r2 =~ m/\.gz/) {
        $cat = "zcat";
}

open(R2, "$cat $r2 \| paste - - - - |");

while (<R1>) {
	chomp();
	my($r1id,$r1seq,$r1plus,$r1qual) = split(/\t/);

	my $r2line = <R2>;
	my($r2id,$r2seq,$r2plus,$r2qual) = split(/\t/, $r2line);

	print "$r1id\n${r1seq}NNN${r2seq}\n+\n${r1qual}!!!${r2qual}\n";
}


close R1;
close R2;


