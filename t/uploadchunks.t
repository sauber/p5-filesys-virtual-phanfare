#!perl

# Add an image by write small chunks at a time

use Test::More;
use File::Slurp;
use Data::Dumper;

use_ok( 'Filesys::Virtual::Phanfare' );
use lib 't';
use_ok( 'FakeAgent' );

# Create FS handler
my $fs   = new_ok( 'Filesys::Virtual::Phanfare' => [ 
  api_key       => 'secret',
  private_key   => 'secret',
  email_address => 's@c.et',
  password      => 'secret',
] );
$fs->phanfare->api( FakeAgent->new() );

my($site) = grep { $fs->test('d', "/$_") }
            $fs->list('/');
my($year) = grep { $fs->test('d', "/$site/$_") }
            $fs->list("/$site");
my($album) = grep { $fs->test('d', "/$site/$year/$_") }
             $fs->list("/$site/$year");
my($section) = grep { $fs->test('d', "/$site/$year/$album/$_") }
               $fs->list("/$site/$year/$album");
#my $rendition = 'Full';
#my $image     = 'testimage.png';

# A test image
my $data = read_file('t/data/testimage.png', binmode => ':raw');

my $fh = $fs->open_write("/$site/$year/$album/$section/Full/testimage.png");
diag Dumper $fh;
$fh->close_write();

done_testing();
