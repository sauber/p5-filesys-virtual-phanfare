package WWW::Phanfare::Class::Section;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Rendition;

#has section_id   => ( is=>'ro', isa=>'Int', required=>1 );
#has section_name => ( is=>'ro', isa=>'Str', required=>1 );

#method subnodetype { 'WWW::Phanfare::Class::Rendition' }
sub childclass { 'WWW::Phanfare::Class::Rendition' }
method _idnames {
  map $_=>$_,
    qw(Full WebLarge Web WebSmall Thumbnail ThumbnailSmall Caption )
}

#method renditionlist { $self->subnodelist }
#method rendition ( Str $renditionname ) { $self->getnode( $renditionname ) }

method _sectioninfo {
   $self->_treesearch(
     $self->parent->_albuminfo->{sections}{section},
     [ { section_name => $self->name } ],
   );
}

# Extract section attributes from albuminfo
#
method buildattributes {
  #my $sections = $self->api->GetAlbum(
  #  target_uid => $self->uid,
  #  album_id   => $self->parent->album_id,
  #)->{album}{sections}{section};
  ##$sections = [ $sections ] unless 'ARRAY' eq ref $sections;
  ## Find the matching section
  #for my $section ( @$sections ) {
  #  if ( $section->{section_name} eq $self->{section_name} ) {
  #    $self->setattributes( $section );
  #    last;
  #  }
  #}
  #$self->setattributes( $self->sectioninfo );
  $self->setattributes( $self->sectioninfo );
    
}

# Create this as new node on Phanfare
method write {  
  $self->api->NewSection(
    target_uid   => $self->uid,
    album_id     => $self->parent->id,
    section_name => $self->name,
  );
  warn "*** Created new section $self->name on Phanfare\n";
}

with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Section - Section Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
