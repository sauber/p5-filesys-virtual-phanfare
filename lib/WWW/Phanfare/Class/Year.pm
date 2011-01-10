package WWW::Phanfare::Class::Year;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Album;

# List of album_id=>album_name pairs
# XXX: Filter by year
#
method albumid {
  my $albumlist = $self->api->GetAlbumList(target_uid=>$self->uid);
  $self->_idnamepair(
    $albumlist->{albums}{album},
    'album',
    { album_start_date=>$self->nodename },
  );
}

method subnodetype { 'WWW::Phanfare::Class::Album' };
method subnodelist { $self->_idnamestrings({ $self->albumid }) }

# Specify ID, Name or Name.ID to get an Album object
#
method buildnode ( $nodename ) {
  my %node = $self->albumid;
  my($id,$name) = $self->_idnamematch( \%node, $nodename );
  my $type = $self->subnodetype;
  $type->new(
    parent     => $self,
    nodename   => $nodename,
    album_id   => $id,
    #album_name => $name,
  );
}

method albumlist { $self->subnodelist }
method album ( Str $albumname ) { $self->getnode( $albumname ) }

method create ( Str $nodename ) {
  $self->api->NewAlbum(
     target_uid => $self->uid,
     album_name => $nodename,
     album_start_date => sprintf("%04s-01-01T00:00:00", $self->nodename),
     album_end_date => sprintf("%04s-12-31T23:59:59", $self->nodename),
  )
}

method delete ( Str $nodename ) {
  my %node = $self->albumid;
  my($id,$name) = $self->_idnamematch( \%node, $nodename );
  $self->api->DeleteAlbum(
     target_uid => $self->uid,
     album_id => $id,
  );
}

with 'WWW::Phanfare::Class::Role::Branch';

=head1 NAME

WWW::Phanfare::Class::Year - Year Node

=head1 SUBROUTINES/METHODS

=head2 subnodetype

Class type of sub nodes.

=head2 subnodelist

Names of subnodes.

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
