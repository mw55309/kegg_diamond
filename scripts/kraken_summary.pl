#!/usr/bin/perl

use File::Basename;

open(CTS, ">kraken.counts.txt");
open(KIN, ">kraken.kingdom.txt");
open(PIN, ">kraken.phylum.txt");
open(GIN, ">kraken.genus.txt");
open(FIN, ">kraken.family.txt");


my $kout;
my %ks;

my $pout;
my %ps;

my $gout;
my %gs;

my $fout;
my %fs;

foreach $fname (@ARGV) {

	my $base = basename($fname, ".report");

	my $dir  = dirname($fname);

	my $count = `cat $fname \| head -n 1`;
	chomp($count);
	$count =~ s/^\s+//;

	my ($perc, $count, @rest) = split(/\s+/, $count);

	print CTS "$base\t$count\n";
	
	#next;

	# kingdom
	open(GREP, "cat $fname \| awk '\$4 == \"D\"' |");
	while(<GREP>) {
		chomp();
		s/^\s+//;
		my($p, $c, $d1, $d2, $t, $k) = split(/\t/, $_);

		$k =~ s/^\s+//;

		$kout->{$base}->{$k} = $c;
		$ks{$k}++;
	}
	close GREP;

	#next;

	# phylum
        open(GREP, "cat $fname \| awk '\$4 == \"P\"' |");
	while(<GREP>) {
                chomp();
                s/^\s+//;
                my($p1, $c, $d1, $d2, $t, $p) = split(/\t/, $_);

		$p =~ s/^\s+//;

                $pout->{$base}->{$p} = $c;
                $ps{$p}++;
        }
        close GREP;

	#next;

	# genus
        open(GREP, "cat $fname \| awk '\$4 == \"G\"' |");
	while(<GREP>) {
                chomp();
                s/^\s+//;
                my($p, $c, $d1, $d2, $t, $g) = split(/\t/, $_);

		$g =~ s/^\s+//;

                $gout->{$base}->{$g} = $c;
                $gs{$g}++;
        }
        close GREP;

	# family
	open(GREP, "cat $fname \| awk '\$4 == \"F\"' |");
        while(<GREP>) {
                chomp();
                s/^\s+//;
                my($p, $c, $d1, $d2, $t, $f) = split(/\t/, $_);

                $f =~ s/^\s+//;

                $fout->{$base}->{$f} = $c;
                $fs{$f}++;
        }
        close GREP;

}
close IN;

my @ks = keys %ks;
print KIN "sample\t", join("\t", @ks), "\n";
while (my($samp,$hr) = each %{$kout}) {
		print KIN $samp;
        	foreach $k (@ks) {
        		print KIN "\t", $hr->{$k};
        	}
        	print KIN "\n";
}

my @ps = keys %ps;
print PIN "sample\t", join("\t", @ps), "\n";
while (my($samp,$hr) = each %{$pout}) {
        	print PIN $samp;
        	foreach $p (@ps) {
                	print PIN "\t", $hr->{$p};
        	}
        	print PIN "\n";
}

my @gs = keys %gs;
print GIN "sample\t", join("\t", @gs), "\n";
while (my($samp,$hr) = each %{$gout}) {
        print GIN $samp;
        	foreach $g (@gs) {
                	print GIN "\t", $hr->{$g};
        	}
        	print GIN "\n";
	
}

close;

my @fs = keys %fs;
print FIN "sample\t", join("\t", @fs), "\n";
while (my($samp,$hr) = each %{$fout}) {
        
        	print FIN $samp;
                foreach $f (@fs) {
                        print FIN "\t", $hr->{$f};
                }
                print FIN "\n";
        
}

close;

#system("module add igmm/apps/R/3.2.2");
#system("module add java/jdk/1.8.0");

#system("./process.R kraken.kingdom.txt");
#system("./process.R kraken.phylum.txt");
#system("./process.R kraken.family.txt");
#system("./process.R kraken.genus.txt");
