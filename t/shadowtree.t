#!perl

# Verify shadow tree nodes behave correctly

use Test::More;
use Date::Parse;

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
my($renditionname) = 'Web';
my($imagename) = 
  $fs->list("/$sitename/$yearname/$albumname/$sectionname/$renditionname");
my($captionname) =
  $fs->list("/$sitename/$yearname/$albumname/$sectionname/Caption");

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
  #diag "shadowtree test dir $dir";
  ok( my $node = $fs->createpath($dir), "Node for $dir" );
  ok ( $node->uid, "uid for $dir" );
  ok ( $node->gid, "gid for $dir" );
  ok ( $node->parent, "parent for $dir" );
  ok ( $node->inode, "inode for $dir" );
  #diag "inode for $dir: " . $node->inode;
  ok ( $node->test('d'), "$dir is dir" );
  ok ( ! $node->test('f'), "$dir is not file" );
  ok( $node->atime > 0, "$dir atime" );
  ok( $node->mtime > 0, "$dir mtime" );
  ok( $node->ctime > 0, "$dir ctime" );
}

for my $file ( @testfiles ) {
  #diag "shadowtree test file $file";
  ok( my $node = $fs->createpath($file), "Node for $file" );
  ok ( $node->test('f'), "$file is file" );
  ok ( ! $node->test('d'), "$file is not dir" );
  ok ( $node->uid, "uid for $file" );
  ok ( $node->gid, "gid for $file" );
  ok ( $node->inode, "inode for $file" );

  ok( $node->atime > 0, "$file atime" );
  ok( $node->mtime > 0, "$file mtime" );
  ok( $node->ctime > 0, "$file ctime" );

  # Cannot read files from FakeAgent
  #ok( my $fh = $node->open_read, "$file open_read" );
  #ok( <$fh>, "$file read" );
  #ok( $fs->close_read( $fh ), "$file close_read" );

  ok ( my $parent = $node->parent, "parent for $file" );
  ok ( $parent->uid, "uid for parent of $file" );
  ok ( $parent->gid, "gid for parent of $file" );
  ok ( $parent->test('d'), "parent of $file is dir" );
}

# Time stamps of years
my $ye = str2time sprintf "%04s-01-01T00:00:00", $yearname;
ok( my $yearnode = $fs->createpath("/$sitename/$yearname") );
ok( $ye == $yearnode->mtime, "mtime matches year" );
ok( $ye == $yearnode->ctime, "ctime matches year" );

# Caption
ok( $captionname =~ /\.txt$/, "$captionname ends with txt" );

done_testing();
