#!/usr/bin/perl

use strict;
use warnings;
use Fuse::Filesys::Virtual;
use File::HomeDir;
use Config::General;
use lib 'lib';
use Filesys::Virtual::Phanfare;

my $rcfile = File::HomeDir->my_home . "/.phanfarerc";
my %config = Config::General->new( $rcfile )->getall;

my $fs = Filesys::Virtual::Phanfare->new(
  root_path => '/',
  home_path => '/',
  cwd       => '/',
  %config
);
my $fuse = Fuse::Filesys::Virtual->new($fs, { debug => 1});

$fuse->main(
  mountpoint => File::HomeDir->my_home . "/Phanfare",
  #mountopts  => "allow_other",
);

