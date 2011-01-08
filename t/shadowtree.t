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
my($yearname) = grep { $fs->test('d', "/$sitename/$_") }
                 $fs->list("/$sitename");
my($albumname) = grep { $fs->test('d', "/$sitename/$yearname/$_") }
                 $fs->list("/$sitename/$yearname");
my($sectionname) = grep { $fs->test('d', "/$sitename/$yearname/$albumname/$_") }
                   $fs->list("/$sitename/$yearname/$albumname");
my($renditionname) = 'Full';
my($imagename) = grep {
  $fs->test('f', "/$sitename/$yearname/$albumname/$sectionname/$renditionname/$_")
} $fs->list("/$sitename/$yearname/$albumname/$sectionname/$renditionname");

# List of dirs to test with
my @testdirs = (
  '/',
  "/$sitename",
  "/$sitename/$yearname",
  "/$sitename/$yearname/$albumname",
  "/$sitename/$yearname/$albumname/$sectionname",
  "/$sitename/$yearname/$albumname/$sectionname/$renditionname",
);

# List of files to test with
my @testfiles = (
  '/cookie',
  "/$sitename/$yearname/$albumname/$sectionname/$renditionname/$imagename",
);

for my $dir ( @testdirs ) {
  diag "shadowtree test dir $dir";
  ok( my $node = $fs->createpath($dir), "Node for $dir" );
  ok ( $node->uid, "uid for $dir" );
  ok ( $node->gid, "gid for $dir" );
  ok ( $node->parent, "parent for $dir" );
  ok ( $node->test('d'), "$dir is dir" );
  ok ( ! $node->test('f'), "$dir is not file" );
}

for my $file ( @testfiles ) {
  diag "shadowtree test file $file";
  ok( my $node = $fs->createpath($file), "Node for $file" );
  ok ( $node->test('f'), "$file is file" );
  ok ( ! $node->test('d'), "$file is not dir" );
  ok ( $node->uid, "uid for $file" );
  ok ( $node->gid, "gid for $file" );
  ok ( my $parent = $node->parent, "parent for $file" );
  ok ( $parent->uid, "uid for parent of $file" );
  ok ( $parent->gid, "gid for parent of $file" );
  ok ( $parent->test('d'), "parent of $file is dir" );
}

done_testing();
