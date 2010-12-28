#!/usr/bin/env perl

use strict;
use warnings;
use WWW::Phanfare::API;
use File::HomeDir;
use Config::General;
use Data::Dumper;

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
print Dumper $session;

my $albumlist = $agent->GetAlbumList(
  target_uid => $uid,
);
my %album =
  map { $_->{album_id} => $_->{album_name} }
  @{ $albumlist->{albums}{album} };
#print Dumper $albumlist;

# A random album is
my ($albumid) = keys %album;
my $albuminfo = $agent->GetAlbum(
  target_uid => $uid,
  album_id   => $albumid,
);
print Dumper $albuminfo;

