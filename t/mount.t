#!perl -T

use Test::More;
use_ok( 'Filesys::Virtual::Phanfare' );
use_ok( 'Fuse::Filesys::Virtual' );

my %config;
eval '
  use Config::General;
  use File::HomeDir;
  use WWW::Phanfare::API;

  my $rcfile = File::HomeDir->my_home . "/.phanfarerc";
  %config = Config::General->new( $rcfile )->getall;
  die unless $config{api_key} and $config{private_key}
         and $config{email_address} and $config{password};
';
plan skip_all => "Modules or config not found: $@" if $@;

my $fs = new_ok ( 'Filesys::Virtual::Phanfare' => [
  %config,
] );

my $fuse = new_ok ( 'Fuse::Filesys::Virtual' => [
  $fs, { debug => 1},
] );

ok( my @dir = $fuse->getdir('/'), 'list /' );
ok( scalar @dir >= 2, 'At least two entries in /' );
ok( my @stat = $fuse->getattr('/'), 'Stat stat /' );
ok( scalar @stat == 13, 'stat has 13 entries' );
diag "stat scalar: " . scalar @stat;
#ok( $fuse->read('/cookie'), 'Cannot list /');

done_testing();
