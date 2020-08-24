#!/usr/bin/perl

my $ko;


open(IN, "/exports/cmvm/eddie/eb/groups/watson_grp/data/kegg_data/all_ko.list");
while(<IN>) {
	chomp();

	my($g,$k) = split(/\t/);

	$ko->{$g}->{$k}++;

}
close IN;

my %reads;

my %r1done;
my $r1k;

my $file1 = shift;

open(IN, $file1);
while(<IN>) {
	my @data = split(/\t/);

	my $read = $data[0];
	my $g1   = $data[1];

	next if exists $r1done{$read};
	
	$reads{$read}++;

	$r1done{$read}++;

	unless (exists $ko->{$g1}) {
		warn "R1: Can't find KO for $g1\n";
		next;
	}

	foreach $k (keys %{$ko->{$g1}}) {
		$r1k->{$read}->{$k}++;		
	}

}
close IN;


my %r2done;
my $r2k;

my $file2 = shift;

open(IN, $file2);
while(<IN>) {
        my @data = split(/\t/);

        my $read = $data[0];
        my $g2   = $data[1];

        next if exists $r2done{$read};

	$reads{$read}++;

	$r2done{$read}++;

        unless (exists $ko->{$g2}) {
                warn "R2: Can't find KO for $g2\n";
                next;
        }

        foreach $k (keys %{$ko->{$g2}}) {
                $r2k->{$read}->{$k}++;
        }
}
close IN;


foreach $read (keys %reads) {
	
	my %all;

	foreach $k (keys %{$r1k->{$read}}) {
		$all{$k}++;
	}

	foreach $k (keys %{$r2k->{$read}}) {
                $all{$k}++;
        }

	foreach $k (keys %all) {
		print $read, "\t", $k, "\n";
	}

}


use File::Basename;
my $sample = basename $file1, ".out";
open(OUT,">$sample.done");
print OUT "done\n";
close OUT;
