#!perl -T

#use Test::More skip_all => 'Building up Class tree first';
use Test::More;
use_ok( 'Filesys::Virtual::Phanfare' );
use Data::Dumper;

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

my $fs = new_ok( 'Filesys::Virtual::Phanfare' => [ %config ] );
#my $fuse = new_ok( 'Fuse::Filesys::Virtual'     => [ $fs, { debug=>1} ] );

#ok( my @dir = $fuse->getdir('/'), 'list /' );
#ok( scalar @dir >= 4, 'At least 4 entries in /' );
#ok( my @stat = $fuse->getattr('/'), 'Stat stat /' );
#ok( scalar @stat == 13, 'stat for / has 13 entries' );

# Verify account properties
#
my %accountproperties =
  map {($_=>1)}
  qw(pro uid primary_site_id cookie website_title timeless_header
     public_group_id primary_site_name family_group_id friend_group_id
     premium timeless_first);
my %dir = map {($_=>1)} $fs->list('/');
for my $key ( keys %accountproperties ) {
  ok( $dir{$key}, "account property $key" );
  my @stat = $fs->stat( $key );
  #warn "*** stat $key: " . Dumper \@stat;
  ok( scalar @stat == 13, "stat $key has 13 values" );
  ok( $stat[2] eq 0100444, "$key is file" );
}

# Verify there is a site
my($sitename) = grep ! $accountproperties{$_}, keys %dir;
ok( $sitename, 'There is a site' );
my @sitestat = $fs->stat( $sitename );
ok( scalar @sitestat == 13, "stat $sitename has 13 values" );
ok( $sitestat[2] eq 042555, "$sitename is dir" );

done_testing();
