#!/usr/bin/env perl

# Check the XML response for sub site access.

use warnings;
use strict;
use File::HomeDir;
use Config::General;
use WWW::Phanfare::API;
use Data::Dumper;

my $rcfile = File::HomeDir->my_home . "/.phanfarerc";
my $conf = Config::General->new( $rcfile );
my %config = $conf->getall;

my $api = WWW::Phanfare::API->new(
    api_key     => $config{api_key},
  private_key => $config{private_key},
);
my $user = $api->Authenticate(
  email_address => $config{email_address},
  password      => $config{password},
);

my $myuid = $user->{session}{uid};
my $album = $api->GetAlbumList( target_uid => $myuid );

print Dumper $album;

# XXX:
# Probably need to check each album to find out which site it is published to.
