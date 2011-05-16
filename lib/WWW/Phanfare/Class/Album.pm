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

#method buildnode ( $nodename ) {
#method _build_list {
#  my %node = $self->section_nameids;
#  #my($id,$name) = $self->idnamematch( \%node, $nodename );
#  my $type = $self->childclass;
#  return [
#    $type->new(
#    parent       => $self,
#    name     => $nodename,
#    section_id   => $id,
#    #section_name => $name,
#  );
#}

#method subnodetype { 'WWW::Phanfare::Class::Section' }
sub childclass { 'WWW::Phanfare::Class::Section' }
#method subnodelist { $self->idnamestrings({ $self->section_nameids }) }

#method sectionlist { $self->subnodelist }
#method section ( Str $sectionname ) { $self->getnode( $sectionname ) }

# Create a section of album
#method create ( Str $nodename ) {
#  $self->api->NewSection(
#     target_uid => $self->uid,
#     album_id => $self->album_id,
#     section_name => $nodename,
#  )
#}

# Create this as new node on Phanfare
# XXX: If parent node was a temp node, it can now be made permanent.
#
method write { 
  my $year = $self->parent->name;
  $self->api->NewAlbum(
     target_uid => $self->uid,
     album_name => $self->name,
     album_start_date => sprintf("%04s-01-01T00:00:00", $year),
     album_end_date   => sprintf("%04s-12-31T23:59:59", $year),
  );
  warn sprintf "*** Created new album %s on Phanfare\n", $self->name;
}

#method delete ( Str $nodename ) {
#  my %node = $self->section_nameids;
#  my($id,$name) = $self->idnamematch( \%node, $nodename );
#  $self->api->DeleteSection(
#     target_uid => $self->uid,
#     album_id => $self->album_id,
#     section_id => $id,
#  );
#}


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
