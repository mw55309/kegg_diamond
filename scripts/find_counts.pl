#!/usr/bin/perl

$c;

my $dir = shift;
unless (defined $dir) {
	$dir = "ko";
}

my @files;

open(FIND, "find $dir -name \"\*.out\" |");
while (<FIND>) {

	chomp();
	$f = $_;

	push(@files, $f);


#foreach $f (@files) {
        if ($f =~ m/.gz/) {
                open(IN, "zcat $f |");
        } else {
                open(IN, $f);
        }
        while(<IN>) {
                s/\n|\r//g;
                s/^\s+//g;
                my($count,$gene) = split(/\s+/);
                #my $gene = join(":", @gene);


                $c->{$gene}->{$f} = $count;
        }
        close IN;
}

print "MIR\t", join("\t", @files), "\n";
foreach $mir (keys %{$c}) {
        print "$mir";
        foreach $f (@files) {
                if (exists $c->{$mir}->{$f}) {
                        print "\t", $c->{$mir}->{$f};
                } else {
                        print "\t0",
		}
        }
        print "\n";
}

