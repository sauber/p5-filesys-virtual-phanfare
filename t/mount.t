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
  root_path => '/',
  home_path => '/',
  cwd       => '/',
  %config
] );

my $fuse = new_ok ( 'Fuse::Filesys::Virtual' => [
  $fs, { debug => 1},
] );

ok( my @dir = $fuse->getdir('/'), 'Cannot list /');
diag "@dir";
#ok( $fuse->read('/cookie'), 'Cannot list /');

done_testing();
