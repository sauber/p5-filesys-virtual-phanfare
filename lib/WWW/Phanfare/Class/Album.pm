package WWW::Phanfare::Class::Album;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Section;

#has album_id => ( is=>'ro', isa=>'Int', lazy_build=>1 );

# Find out id of this album
#
#method _build_album_id {
#  $self->parent->albumid($self->nodename);
#}

#method buildattributes {
#  $self->setattributes( $self->albuminfo ) ;
#}

method _info {
  $self->api->GetAlbum(
    target_uid => $self->uid,
    album_id   => $self->id,
  )->{album};
}

method _idnames {
  $self->_idnamepair( $self->_info->{sections}{section}, 'section' );
}

sub childclass { 'WWW::Phanfare::Class::Section' }

# Create this as new node on Phanfare
# XXX: If parent node was a temp node, it can now be made permanent.
#
method _write { 
  my $year = $self->parent->name;
  $self->api->NewAlbum(
     target_uid       => $self->uid,
     album_name       => $self->name,
     album_start_date => $self->parent->start_date,
     album_end_date   => $self->parent->end_date,
  );
  #warn sprintf "*** Created new album %s on Phanfare\n", $self->name;
}

method _delete {
  my $res = $self->api->DeleteAlbum(
     target_uid => $self->uid,
     album_id   => $self->id,
  );
  use Data::Dumper;
  warn "*** Album _delete result: " . Dumper $res;
  return $res;
}

# Write an attribute
#
method _update ( Str $field, Str $value ) {
  $self->api->UpdateAlbum(
     target_uid      => $self->uid,
     album_id        => $self->id,
     field_to_update => $field,
     field_value     => $value,
  );
}

with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Album - Album Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
