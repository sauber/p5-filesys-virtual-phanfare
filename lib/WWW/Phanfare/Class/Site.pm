package WWW::Phanfare::Class::Site;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Album;

method subnodetype { 'WWW::Phanfare::Class::Album' };
method subnodelist {
  my $albumlist = $self->api->GetAlbumList(target_uid=>$self->uid);
  return (
    map "$_->{album_name}.$_->{album_id}",
    @{ $albumlist->{albums}{album} }
  );
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
