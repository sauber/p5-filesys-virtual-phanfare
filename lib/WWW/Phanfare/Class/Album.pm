package WWW::Phanfare::Class::Album;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Section;

has album_id => ( is=>'ro', isa=>'Int', required=>1 );
#has album_name => ( is=>'ro', isa=>'Str', required=>1 );

method buildattributes {
  $self->setattributes( $self->albuminfo ) ;
}

method albuminfo {
  $self->api->GetAlbum(
    target_uid => $self->uid,
    album_id   => $self->album_id,
  )->{album};
}

method section_nameids {
  $self->_idnamepair( $self->albuminfo->{sections}{section}, 'section' );
}

method buildnode ( $nodename ) {
  my %node = $self->section_nameids;
  my($id,$name) = $self->_idnamematch( \%node, $nodename );
  my $type = $self->subnodetype;
  $type->new(
    parent       => $self,
    nodename     => $nodename,
    section_id   => $id,
    #section_name => $name,
  );
}

method subnodetype { 'WWW::Phanfare::Class::Section' }
method subnodelist { $self->_idnamestrings({ $self->section_nameids }) }

method sectionlist { $self->subnodelist }
method section ( Str $sectionname ) { $self->getnode( $sectionname ) }

# Create a section of album
method create ( Str $nodename ) {
  $self->api->NewSection(
     target_uid => $self->uid,
     album_id => $self->album_id,
     section_name => $nodename,
  )
}

method delete ( Str $nodename ) {
  my %node = $self->section_nameids;
  my($id,$name) = $self->_idnamematch( \%node, $nodename );
  $self->api->DeleteSection(
     target_uid => $self->uid,
     album_id => $self->album_id,
     section_id => $id,
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
