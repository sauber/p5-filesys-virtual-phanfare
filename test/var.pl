#!/usr/bin/perl

use Data::Dumper;

my %store;
my $content = "";
my $contentref = \$content;
warn "*** contentref: " . Dumper $contentref;
open(my $fh, '>', $contentref);
$store{$fh} = $contentref;
print $fh "hello\n";
close $fh;
my $ref = $store{$fh};
warn "*** contentref: " . Dumper $ref;
