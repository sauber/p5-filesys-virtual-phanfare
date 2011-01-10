package WWW::Phanfare::Class::Rendition;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Image;

# list of image IDs
method image_ids {
  my $images = $self->parent->sectioninfo->{images}{imageinfo};
  $images = [ $images ] unless 'ARRAY' eq ref $images;
  return map $_->{image_id}, @$images;
}

method subnodetype { 'WWW::Phanfare::Class::Image' }
#method subnodelist { $self->imageid } # XXX: Todo
method subnodelist {
  my $type = $self->subnodetype;
  # Create each node to extract its filename
  return
    map {
      #warn "*** Creating new image subnode id=$_\n";
      my $node = $type->new( image_id => $_, parent => $self );
      #warn sprintf "*** image nodename is %s\n", $node->filename;
      $node->filename;
    }
    $self->image_ids;
}

method buildnode ( $nodename ) {
  my $type = $self->subnodetype;
  # Build each node until the one with the correct filename is found
  for my $id ( $self->image_ids ) {
    #warn "*** Rendition buildnode id=$id\n";
    my $node = $type->new( image_id => $id, parent => $self );
    return $node if $node->nodename eq $nodename;
  }
}

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
