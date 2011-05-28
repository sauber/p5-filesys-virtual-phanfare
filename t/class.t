#!perl -T

# Test all class methods

use Test::More;
use_ok( 'WWW::Phanfare::Class' );
use lib 't';
use_ok( 'FakeAgent' );

use Data::Dumper;

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
ok( my($sitename) = $account->names, "Class has sites" );
#diag "*** site is " . $sitename;
ok( my $site = $account->$sitename, "Class has site object" );
isa_ok( $site, 'WWW::Phanfare::Class::Site' );

# Verify there are years
ok( my($yearname) = $site->names, "Class has years" );
#diag "*** yearname is " . $yearname;
ok( my $year = $site->$yearname, "Class has year object" );
#diag "*** year is " . $year;
isa_ok( $year, 'WWW::Phanfare::Class::Year' );

# Verify there are albums
ok( my($albumname) = $year->names, "Class has an album" );
#diag "*** album is " . $albumname;
ok( my $album = $year->$albumname, "Class has album object" );
isa_ok( $album, 'WWW::Phanfare::Class::Album' );
#diag Dumper $album;

# Verify there are sections
ok( my($sectionname) = $album->names, "Class has sections" );
#diag "*** section is " . $sectionname;
ok( my $section = $album->$sectionname, "Class has section object" );
isa_ok( $section, 'WWW::Phanfare::Class::Section' );

# Verify there are renditions
ok( my($renditionname) = $section->names, "Class has renditions" );
#diag "*** rendition is " . $renditionname;
ok( my $rendition = $section->$renditionname, "Class has section object" );
isa_ok( $rendition, 'WWW::Phanfare::Class::Rendition' );

# Verify there are images
ok( my @imagenames = $rendition->names, "Class has images" );
#diag Dumper \@imagenames;
my $imagename = shift @imagenames;
#diag "*** imagename is " . $imagename;
ok( my $image = $rendition->$imagename, 'Class has image object' );
isa_ok( $image, 'WWW::Phanfare::Class::Image' );

# URL of image
#diag Dumper $image;
#diag "*** image url is " . $image->url;
ok( 'http://' eq substr $image->url, 0, 7, "url starts with http" );

# Caption of image
ok( length $image->caption, "Image has caption" );
#diag "Image Caption: " . $image->caption;

# Make sure all image filenames are different
my %U;
my @uniqnames = grep { ! $U{$_}++ } @imagenames;
ok( scalar @uniqnames == scalar @imagenames, "All image names are unique: @imagenames" );

# Create, read and delete a year
my $newyear = '1999';
ok( ! grep(/$newyear/, $site->names), "Year $newyear doesn't yet exist" );
ok( $site->add( $newyear ), "Year $newyear created" );
#diag '*** yearlist:' . Dumper [$site->yearlist];
ok( grep(/$newyear/, $site->names), "Year $newyear now exists" );
ok( $site->remove( $newyear ), "Year $newyear removed" );
ok( ! grep(/$newyear/, $site->names), "Year $newyear no longer exists" );

# Verify that a year with albums cannot be delete
ok( ! $site->remove( $yearname ), "Year $yearname removed" );
#diag '*** yearlist:' . Dumper [$site->names];

# Create, read and delete an album
my $newalbum = "New Album";
ok( ! grep(/$newalbum/, $year->names), "Album $newalbum doesn't yet exist" );
$year->add( $newalbum );
ok( grep(/$newalbum/, $year->names), "Album $newalbum now exists" );
#diag '*** album list:' . Dumper [$year->names];
$year->remove( $newalbum );
ok( ! grep(/$newalbum/, $year->names), "Album $newalbum no longer exists" );

# Create, read and delete a section
my $newsection = 'New Section';
ok( ! grep(/$newsection/, $album->names), "Section $newsection doesn't yet exist" );
$album->add( $newsection );
#diag '*** section list:' . Dumper [$album->names];
ok( grep(/$newsection/, $album->names), "Section $newsection now exists" );
$album->remove( $newsection );
ok( ! grep(/$newsection/, $album->names), "Section $newsection no longer exists" );

# Create, read and delete and image
#$rendition = $section->Full;
$rendition = $section->WebLarge;
$renditionname = $rendition->name;
#diag "Rendition for new image: " . $renditionname;
my $newimage = 'New Image.jpg';
ok( ! grep(/$newimage/, $rendition->names), "Image $newimage doesn't yet exist" );
ok( ! $rendition->add( $newimage, '<imagedata>' ), "Cannot add to $renditionname rendition" );
$rendition = $section->Full;
$renditionname = $rendition->name;
ok( $rendition->add( $newimage, '<imagedata>' ), "Added to $renditionname rendition" );
ok( grep(/$newimage/, $rendition->names), "Image $newimage now exists" );
$rendition->remove( $newimage );
ok( ! grep(/$newimage/, $rendition->names), "Image $newimage no longer exists" );

# Create, read and delete and caption
my $caption = "New Caption";
ok( $image->caption( $caption ), "Set new image caption" );
ok( $caption eq $image->caption, "Read new image caption" );
#diag "Caption: " . $image->caption;

# Some nodes have attributes - some don't
ok (   $account->attributes,   "Album has attributes"     );
ok ( ! $site->attributes,      "Site has attributes"      );
ok ( ! $year->attributes,      "Year has attributes"      );
ok (   $album->attributes,     "Album has attributes"     );
ok (   $section->attributes,   "Section has attributes"   );
ok ( ! $rendition->attributes, "Rendition has attributes" );
ok (   $image->attributes,     "Image has attributes"     );
#done_testing(); exit;

done_testing(); exit;
