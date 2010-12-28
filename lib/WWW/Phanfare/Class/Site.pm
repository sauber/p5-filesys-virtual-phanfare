package WWW::Phanfare::Class::Site;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Album;

# List of album_id=>album_name pairs
#
method albumid {
  my $albumlist = $self->api->GetAlbumList(target_uid=>$self->uid);
  my %node = 
    map { $_->{album_id} => $_->{album_name} }
    @{ $albumlist->{albums}{album} };
  #x('albumid', \%node);
  return %node;
}

method subnodetype { 'WWW::Phanfare::Class::Album' };
method subnodelist {
  my @albums;
  my %node = $self->albumid;
  while ( my($id,$name) = each %node ) {
    # XXX: If there are more than one album with same name,
    #        then append ID
    #        otherwise don't append ID
    push @albums, "$name.$id";
  }
  return @albums;
}

# Specify ID, Name or Name.ID
method buildnode ( $nodename ) {
  my %node = $self->albumid;
  while ( my($id,$name) = each %node ) {
    if ( "$name.$id" eq $nodename or $name eq $nodename or "$id" eq "$nodename" ) {
      return WWW::Phanfare::Class::Album->new(
        parent     => $self,
        nodename   => $nodename,
        album_id   => $id,
        album_name => $name,
      );
    }
  }
}

method albumlist { $self->subnodelist }
method album ( Str $albumname ) { $self->getnode( $albumname ) }

with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

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
