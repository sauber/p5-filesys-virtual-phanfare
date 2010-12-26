#!/usr/bin/env perl

use Fuse;
my ($mountpoint) = "";
$mountpoint = shift(@ARGV) if @ARGV;
Fuse::main(mountpoint=>$mountpoint, getattr=>"main::my_getattr", getdir=>"main::my_getdir", );

