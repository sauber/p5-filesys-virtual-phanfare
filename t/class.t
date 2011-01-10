#!perl -T

# Test all class methods

use Test::More;
use_ok( 'WWW::Phanfare::Class' );
use lib 't';
use_ok( 'FakeAgent' );

use Data::Dumper;

#my %config;
#eval '
#  use Config::General;
#  use File::HomeDir;
#  use WWW::Phanfare::API;
#
#  my $rcfile = File::HomeDir->my_home . "/.phanfarerc";
#  %config = Config::General->new( $rcfile )->getall;
#  die unless $config{api_key}
#         and $config{private_key}
#         and $config{email_address}
#         and $config{password};
#';
#plan skip_all => "Local config not found: $@" if $@;

# Create an object
my $class = new_ok( 'WWW::Phanfare::Class' => [ 
  api_key       => 'secret',
  private_key   => 'secret',
  email_address => 's@c.et',
  password      => 'secret',
] );
isa_ok( $class, 'WWW::Phanfare::Class' );
$class->api( FakeAgent->new() );

# Verify there is account
ok( my $account = $class->account, "Class has account" );
isa_ok( $account, 'WWW::Phanfare::Class::Account' );

# Verify there is a site
ok( my($sitename) = $class->sitelist, "Class has sites" );
diag "*** site is " . $sitename;
ok( my $site = $class->site($sitename), "Class has site object" );
isa_ok( $site, 'WWW::Phanfare::Class::Site' );

# Verify there are years
ok( my($yearname) = $class->yearlist, "Class has years" );
diag "*** year is " . $yearname;
ok( my $year = $class->year($yearname), "Class has year object" );
isa_ok( $year, 'WWW::Phanfare::Class::Year' );

# Verify there are albums
ok( my($albumname) = $class->albumlist($yearname), "Class has an album" );
diag "*** album is " . $albumname;
ok( my $album = $class->album($yearname,$albumname), "Class has album object" );
isa_ok( $album, 'WWW::Phanfare::Class::Album' );
#diag Dumper $album;

# Verify there are sections
ok( my($sectionname) = $class->sectionlist($yearname,$albumname), "Class has sections" );
diag "*** section is " . $sectionname;
ok( my $section = $class->section($yearname,$albumname,$sectionname), "Class has section object" );
isa_ok( $section, 'WWW::Phanfare::Class::Section' );

# Verify there are renditions
ok( my($renditionname) = $class->renditionlist($yearname,$albumname,$sectionname), "Class has renditions" );
diag "*** rendition is " . $renditionname;
ok( my $rendition = $class->rendition($yearname,$albumname,$sectionname,$renditionname), "Class has section object" );
isa_ok( $rendition, 'WWW::Phanfare::Class::Rendition' );

# Verify there are images
ok( my @imagenames = $class->imagelist($yearname,$albumname,$sectionname,$renditionname), "Class has images" );
my $imagename = shift @imagenames;
diag "*** image is " . $imagename;
ok( my $image = $class->image($yearname,$albumname,$sectionname,$renditionname,$imagename), 'Class has image object' );
isa_ok( $image, 'WWW::Phanfare::Class::Image' );

# URL of image
diag "*** image url is " . $image->url;

# Make sure all filenames are different
my %U;
my @uniqnames = grep { ! $U{$_}++ } @imagenames;
ok( scalar @uniqnames == scalar @imagenames, "All image names are unique: @imagenames" );

done_testing();
