#!/usr/bin/env perl

use strict;
use warnings;
use WWW::Phanfare::API;
use File::HomeDir;
use Config::General;
use Data::Dumper;
use YAML::Syck;

my $rcfile = File::HomeDir->my_home . "/.phanfarerc";
my %config = Config::General->new( $rcfile )->getall;

my $agent = WWW::Phanfare::API->new(
  api_key     => $config{api_key},
  private_key => $config{private_key},
);

my $session = $agent->Authenticate(
  email_address => $config{email_address},
  password      => $config{password},
);
my $uid = $session->{session}{uid};
#print Dump $session;
#exit;

my $albumlist = $agent->GetAlbumList(
  target_uid => $uid,
);
my %album =
  map { $_->{album_id} => $_->{album_name} }
  @{ $albumlist->{albums}{album} };
#print Dump $albumlist;
#exit;

# A random album is
my ($albumid) = keys %album;
my $albuminfo = $agent->GetAlbum(
  target_uid => $uid,
  album_id   => $albumid,
);
#print Dump $albuminfo;
#exit;

# Find a random section with random image
my $sections = $albuminfo->{album}{sections}{section};
$sections = [ $sections] unless ref $sections eq 'ARRAY';
my $section = shift @$sections;
my $sectionid = $section->{section_id};
my $images = $section->{images}{imageinfo};
$images = [ $images] unless ref $images eq 'ARRAY';
my $image = shift @$images;
my $imageid = $image->{image_id};

my $imageinfo = $agent->GetImageInfo(
  target_uid => $uid,
  album_id   => $albumid,
  section_id   => $sectionid,
  image_id   => $imageid,
);
print Dump $imageinfo;
exit;
