package WWW::Phanfare::Class::Rendition;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Image;

# Get list of images
#   filename
method imageid {
  # Get sections from album
  my $sections = $self->api->GetAlbum(
    target_uid => $self->uid,
    album_id   => $self->parent->parent->album_id,
  )->{album}{sections}{section};
  $sections = [ $sections ] unless 'ARRAY' eq ref $sections;

  # Find the matching section
  my $section;
  for my $s ( @$sections ) {
    if ( $s->{section_name} eq $self->parent->nodename ) {
      $section = $s;
      last;
    }
  }

  # Find images in section
  #x("section", $section);
  my $images = $section->{images}{imageinfo};
  $images = [ $images ] unless 'ARRAY' eq ref $images;
  my @imagenames;
  for my $image ( @$images ) {
    #x('image', $image);
    #warn "*** Imagename $image->{filename}\n";
    my @part = split /[\/\\]/, $image->{filename};
    my $file = $part[-1];
    push @imagenames, $file;
  }
  return @imagenames;
}

method subnodetype { 'WWW::Phanfare::Class::Image' }
method subnodelist { $self->imageid } # XXX: Todo

method imagelist { $self->subnodelist }
method image ( Str $imagename ) { $self->getnode( $imagename ) }

with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Rendition - Rendition Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
