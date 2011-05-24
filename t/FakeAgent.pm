package FakeAgent;

# Emulate responses from Phanfare using local data files.

use YAML::Syck qw(Load LoadFile);
use Data::Dumper;
use Clone qw(clone);
use base qw(WWW::Phanfare::API);
our $AUTOLOAD;
#my($_albumlist,$_albuminfo);

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
  #my %data = @_;
  #use Data::Dumper;
  #warn "*** GetAlbumList: " . Dumper \%data;
  my $list = LoadFile 't/data/albumlist.yaml';
  if ( defined $self->{_albuminfo} ) {
    #warn "*** FakeAgent GetAlbumList Add\n";
    push @{ $list->{albums}{album} }, $self->{_albumlist};
  } else {
    #warn "*** FakeAgent GetAlbumList NoAdd: " . Dumper $self;
  }
  return $list;
}

sub GetAlbum     {
  my $self = shift;
  #warn "*** $self FakeAgent GetAlbum: " . Dumper $self;
  $self->{_albuminfo} || LoadFile 't/data/albuminfo.yaml';
}

sub NewAlbum {
  my $self = shift;
  my %data = @_;
  #warn "*** $self NewAlbum: " . Dumper \%data;
  #warn "*** $self self: " . Dumper $self;

  # Clone last albumlist entry
  #
  my $list = $self->GetAlbumList;
  $self->{_albumlist} = clone $list->{albums}{album}[-1];
  while (my($k,$v) = each %data ) {
    $self->{_albumlist}->{$k} = $v;
  }
  ++$self->{_albumlist}{album_id};
  #warn "*** NewAlbum _albumlist: " . $self->{_albumlist};

  # Clone Album
  my $album = $self->GetAlbum;
  $self->{_albuminfo} = clone $album->{album};
  while (my($k,$v) = each %data ) {
    $self->{_albuminfo}{$k} = $v;
  }
  ++$self->{_albuminfo}{album_id};
  #warn "*** NewAlbum _albuminfo: " . $self->{_albuminfo};
  #warn "*** $self self: " . Dumper $self;
  
}

sub DeleteAlbum {
  my $self = shift;
  delete $self->{_albumlist};
  delete $self->{_albuminfo};
 }

# Make sure not caught by AUTOLOAD
sub DESTROY {}

1;
