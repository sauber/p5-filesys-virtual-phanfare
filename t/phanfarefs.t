#!perl

# Verify basic operations on phanfare tree

use Test::More;

use_ok( 'Filesys::Virtual::Phanfare' );
use lib 't';
use_ok( 'FakeAgent' );

my $fs   = new_ok( 'Filesys::Virtual::Phanfare' => [ 
  api_key       => 'secret',
  private_key   => 'secret',
  email_address => 's@c.et',
  password      => 'secret',
] );

$fs->phanfare->api( FakeAgent->new() );

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

# List years in site
ok( @dir = $fs->list("/$sitename"), 'list years' );
ok( scalar @dir >= 1, 'At least 1 year' );
my $yearname = shift @dir;

# List albums in site
ok( @dir = $fs->list("/$sitename/$yearname"), 'list albums' );
ok( scalar @dir >= 1, 'At least 1 album' );

# Which entry is an album
my $albumname;
for my $entry ( @dir ) {
  if ( $fs->test('d', "/$sitename/$yearname/$entry" ) ) {
    $albumname = $entry;
    last;
  }
}
ok( $albumname, "albumname" );
#diag "albumname: $albumname";

# List sections in album
ok( @dir = $fs->list("/$sitename/$yearname/$albumname"), 'list sections' );
ok( scalar @dir >= 1, 'At least 1 section' );

# Which entry is a section
my $sectionname;
for my $entry ( @dir ) {
  if ( $fs->test('d', "/$sitename/$yearname/$albumname/$entry" ) ) {
    $sectionname = $entry;
    last;
  }
}
ok( $sectionname, "sectionname" );
#diag "sectionname: $sectionname";

# List renditions in section
ok( @dir = $fs->list("/$sitename/$yearname/$albumname/$sectionname"), 'list renditions' );
ok( scalar @dir >= 1, 'At least 1 rendition' );

# Which entry is a rendition
my $renditionname;
for my $entry ( @dir ) {
  if ( $fs->test('d', "/$sitename/$yearname/$albumname/$sectionname/$entry" ) ) {
    $renditionname = $entry;
    last;
  }
}
ok( $renditionname, "renditionname" );
#diag "renditionname: $renditionname";

# List images in rendition
ok( @dir = $fs->list("/$sitename/$yearname/$albumname/$sectionname/$renditionname"), 'list images' );
ok( scalar @dir >= 1, 'At least 1 image' );

# Which entry is an image
my $imagename;
for my $entry ( @dir ) {
  if ( $fs->test('f', "/$sitename/$yearname/$albumname/$sectionname/$renditionname/$entry" ) ) {
    $imagename = $entry;
    last;
  }
}
ok( $imagename, "imagename" );
#diag "imagename: $imagename";




done_testing();
