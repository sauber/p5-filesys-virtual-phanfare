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
  die unless $config{api_key}
         and $config{private_key}
         and $config{email_address}
         and $config{password};
';
plan skip_all => "Local config not found: $@" if $@;

my $fs   = new_ok( 'Filesys::Virtual::Phanfare' => [ %config          ] );
my $fuse = new_ok( 'Fuse::Filesys::Virtual'     => [ $fs, { debug=>1} ] );

ok( my @dir = $fuse->getdir('/'), 'list /' );
ok( scalar @dir >= 4, 'At least 4 entries in /' );
ok( my @stat = $fuse->getattr('/'), 'Stat stat /' );
ok( scalar @stat == 13, 'stat for / has 13 entries' );

done_testing();
