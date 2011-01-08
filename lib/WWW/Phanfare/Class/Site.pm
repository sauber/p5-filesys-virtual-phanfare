package WWW::Phanfare::Class::Site;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Album;

# List of album_id=>album_name pairs
#
method albumid {
  my $albumlist = $self->api->GetAlbumList(target_uid=>$self->uid);
  $self->_idnamepair( $albumlist->{albums}{album}, 'album' );
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
    album_name => $name,
  );
}

method albumlist { $self->subnodelist }
method album ( Str $albumname ) { $self->getnode( $albumname ) }

with 'WWW::Phanfare::Class::Role::Branch';

=head1 NAME

WWW::Phanfare::Class::Site - Site Node

=head1 SUBROUTINES/METHODS

=head2 subnodetype

Class type of sub nodes.

=head2 subnodelist

Names of subnodes.

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
