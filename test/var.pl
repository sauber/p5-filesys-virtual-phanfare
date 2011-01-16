#!/usr/bin/perl

use Data::Dumper;

#my %store;
#my $content = "";
#my $contentref = \$content;
#warn "*** contentref: " . Dumper $contentref;
#open(my $fh, '>', $contentref);
#$store{$fh} = $contentref;
#print $fh "hello\n";
#close $fh;
#my $ref = $store{$fh};
#warn "*** contentref: " . Dumper $ref;

warn "Opening file\n";
open(my $fh, '>', '/home/sauber/Phanfare/phf4/1999/Test/Main Section/Full/img.jpg')  or die $!;
sleep 5;
warn "Writing to file\n";
print $fh "test test\n";
sleep 5;
warn "Closing file\n";
close $fh;
