#!perl -T

# Verify basic operations on phanfare tree

use Test::More;

use_ok( 'Filesys::Virtual::Phanfare' );

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

my $fs   = new_ok( 'Filesys::Virtual::Phanfare' => [ %config ] );

# stat on top dir
ok( my @stat = $fs->stat('/'), 'Stat stat /' );
ok( scalar @stat == 13, 'stat for / has 13 entries' );

# / dir listing
ok( my @dir = $fs->list('/'), 'list /' );
ok( scalar @dir >= 4, 'At least 4 entries in /' );
#diag "\@dir: @dir";

# Which one is the site dir?
my $sitename;
for my $entry ( @dir ) {
  if ( $fs->test('d', "/$entry" ) ) {
    $sitename = $entry;
    last;
  }
}
ok( $sitename, "sitename" );
#diag "sitename: $sitename";

# List albums in site
ok( @dir = $fs->list("/$sitename"), 'list albums' );
ok( scalar @dir >= 1, 'At least 1 album' );

# Which entry is an album
my $albumname;
for my $entry ( @dir ) {
  if ( $fs->test('d', "/$sitename/$entry" ) ) {
    $albumname = $entry;
    last;
  }
}
ok( $albumname, "albumname" );
#diag "albumname: $albumname";

done_testing();
