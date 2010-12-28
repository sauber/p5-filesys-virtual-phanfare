package WWW::Phanfare::Class::Album;
use Moose;
use MooseX::Method::Signatures;
#use WWW::Phanfare::Class::Section;

has album_id => ( is=>'ro', isa=>'Int', required=>1 );
has album_name => ( is=>'ro', isa=>'Str', required=>1 );

method sectionid {
  my $sectionlist = $self->api->GetAlbum(
    target_uid => $self->uid,
    album_id   => $self->album_id,
  );
  #my $sl = $sectionlist->{album}{sections}{section};
  #$sl = [ $sl ] unless 'ARRAY' eq ref $sl; # There is only one section
  ##x('sectionlist', $sl);
  #my %node =
  #  map { $_->{section_id} => $_->{section_name} }
  #  @$sl;
  #x('sectionid', \%node);
  #return %node;
  $self->_idnamepair( $sectionlist->{album}{sections}{section}, 'section' );
}

method subnodetype { 'WWW::Phanfare::Class::Album' }
method subnodelist { $self->_idnamestrings({ $self->sectionid }) }

method sectionlist { $self->subnodelist }
#method section ( Str $sectionname ) { $self->getnode( $sectionname ) }

with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Account - Album Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
