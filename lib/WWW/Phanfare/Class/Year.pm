package WWW::Phanfare::Class::Year;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Album;

method _fetch {
  $self->api->GetAlbumList(target_uid=>$self->uid);
}

# List of album_id=>album_name pairs
#
method _idnames {
  #my $albumlist = $self->_info;
  $self->_idnamepair(
    $self->_fetch->{albums}{album},
    'album',
    { album_start_date=>$self->name },
  );
}

sub childclass { 'WWW::Phanfare::Class::Album' };

# A year can only be deleted if there are no albums in that year
#
method _delete {
  return if $self->list;
  return 1;
}

method start_date { sprintf("%04s-01-01T00:00:00", $self->name) }
method end_date   { sprintf("%04s-12-31T23:59:59", $self->name) }

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
