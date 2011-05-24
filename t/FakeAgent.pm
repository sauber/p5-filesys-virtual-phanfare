package FakeAgent;

# Emulate responses from Phanfare using local data files.

use YAML::Syck qw(Load LoadFile);
use Data::Dumper;
use Clone qw(clone);
use base qw(WWW::Phanfare::API);
our $AUTOLOAD;

sub AUTOLOAD {
  warn "*** FakeAgent $AUTOLOAD not handled\n";
}

# Create an Authentication response
#
sub Authenticate {
  my $self = shift;
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
  my $self = shift;
  my $list = LoadFile 't/data/albumlist.yaml';
  push @{ $list->{albums}{album} }, $self->{_albumlist} if $self->{_albumlist};
  return $list;
}

# If a new album is created, then assume return the one just created
# Otherwise load from file
#
sub GetAlbum {
  shift->{_albuminfo} || LoadFile 't/data/albuminfo.yaml';
}

sub NewAlbum {
  my($self, %data) = @_;

  # Clone last albumlist entry
  #
  my $list = $self->GetAlbumList;
  $self->{_albumlist} = clone $list->{albums}{album}[-1];
  while (my($k,$v) = each %data ) {
    $self->{_albumlist}->{$k} = $v;
  }
  ++$self->{_albumlist}{album_id};

  # Clone Album
  my $album = $self->GetAlbum;
  #$self->{_albuminfo} = clone $album->{album};
  $self->{_albuminfo} = clone $album;
  while (my($k,$v) = each %data ) {
    $self->{_albuminfo}{album}{$k} = $v;
  }
  ++$self->{_albuminfo}{album}{album_id};
}

sub DeleteAlbum {
  my $self = shift;
  delete $self->{_albumlist};
  delete $self->{_albuminfo};
}

sub NewSection {
  my($self, %data) = @_;

  #$self->{_albuminfo} = clone $self->GetAlbum->{album};

  #warn "*** NewSection section: " . Dumper $self->GetAlbum->{album}{sections}{section};
  my $oldsection = clone $self->GetAlbum->{album}{sections}{section};
  my $section = clone $oldsection;
  $section->{section_name} = $data{section_name};
  ++$section->{section_id};
  $self->{_albuminfo} = clone $self->GetAlbum->{album};
  $self->{_albuminfo}{sections}{section} = [
    $oldsection,
    $section
  ];
  #warn "*** NewSection sections: " . Dumper $self->{_albuminfo}{sections};
}

sub DeleteSection {
  my $self = shift;
  delete $self->{_albuminfo};
}


# Make sure not caught by AUTOLOAD
sub DESTROY {}

1;
