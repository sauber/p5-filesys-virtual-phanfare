#!perl

# Verify shadow tree nodes behave correctly

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

# Determine name of dirs and files to test
my($sitename) = grep { $fs->test('d', "/$_") } $fs->list('/');
my($albumname) = grep { $fs->test('d', "/$sitename/$_") }
                 $fs->list("/$sitename");
my($sectionname) = grep { $fs->test('d', "/$sitename/$albumname/$_") }
                   $fs->list("/$sitename/$albumname");
my($renditionname) = 'Full';
my($imagename) = grep {
  $fs->test('f', "/$sitename/$albumname/$sectionname/$renditionname/$_")
} $fs->list("/$sitename/$albumname/$sectionname/$renditionname");

# Build list of dirs to test with
my @testdirs = (
  '/',
  "/$sitename",
  "/$sitename/$albumname",
  "/$sitename/$albumname/$sectionname",
  "/$sitename/$albumname/$sectionname/$renditionname"
);

for my $dir ( @testdirs ) {
  diag "shadowtree test $dir";
  my $node = $fs->fsnode($dir);
}


done_testing();
