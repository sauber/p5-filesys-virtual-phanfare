package FakeAgent;

# Emulate responses from Phanfare using local data files.

use YAML::Syck qw(Load LoadFile);
use Clone qw(clone);
use base qw(WWW::Phanfare::API);
our $AUTOLOAD;
my($_albumlist,$_albuminfo);

sub AUTOLOAD {
  warn "*** FakeAgent $AUTOLOAD not handled\n";
}

# Create an Authentication response
#
sub Authenticate {
  #warn "*** FakeAgent Authenticate\n";
  LoadFile 't/data/session.yaml';
}

# Convert unix time to phanfare time
#
#sub timephanfare {
#  my @t = gmtime shift;
#  sprintf "%04s-02%-%02sT%02s:%02s:%02",
#    $t[5]+1900, $t[4]+1, $t[3],
#    $t[2], $t[1], $t[0];
#}

sub GetAlbumList {
  #shift;
  #my %data = @_;
  #use Data::Dumper;
  #warn "*** GetAlbumList: " . Dumper \%data;
  warn "*** FakeAgent GetAlbumList Add\n" if $_albumlist;
  my $list = LoadFile 't/data/albumlist.yaml';
  push @{ $list->{albums}{album} }, $_albumlist if $_albumlist;
  return $list;
}

sub GetAlbum     {
  #warn "*** FakeAgent GetAlbum\n";
  $_albuminfo || LoadFile 't/data/albuminfo.yaml';
}

sub NewAlbum {
  my $self = shift;
  my %data = @_;
  use Data::Dumper;
  warn "*** NewAlbum: " . Dumper \%data;

  # Clone last albumlist entry
  #
  my $list = GetAlbumList;
  $_albumlist = clone $list->{albums}{album}[-1];
  while (my($k,$v) = each %data ) {
    $_albumlist->{$k} = $v;
  }
  ++$_albumlist->{album_id};
  #warn "*** NewAlbum _albumlist: " . Dumper $_albumlist;

  # Clone Album
  my $album = GetAlbum;
  $_albuminfo = clone $album->{album};
  while (my($k,$v) = each %data ) {
    $_albuminfo->{$k} = $v;
  }
  ++$_albuminfo->{album_id};
  #warn "*** NewAlbum _albuminfo: " . Dumper $_albuminfo;
  
}

sub DeleteAlbum {
  undef $_albumlist;
  undef $_albuminfo;
 }

# Make sure not caught by AUTOLOAD
sub DESTROY {}

1;
