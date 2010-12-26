#!/usr/bin/env perl

use Fuse::Filesys::Virtual;
use Filesys::Virtual::Plain;

#my $fs = Filesys::Virtual::Plain->new( 'root_path' => '/tmp' );
my $fs = Filesys::Virtual::Plain->new({'root_path'=>'/Users/sauber/projects'});
my $fuse = Fuse::Filesys::Virtual->new($fs, { debug => 1});
warn "*** new done\n";

$fuse->main(
  mountpoint => '/Users/sauber/Phanfare',
  mountopts => "allow_other",
  #mountopts => "allow_root",
  debug => 1,
);
warn "*** main done\n";
