package WWW::Phanfare::Class::Rendition;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Image;

#has extraimage => ( isa=>'HashRef', is=>'rw', default=>sub {{}} );

# list of image IDs
#method image_ids {
#  my $images = $self->parent->sectioninfo->{images}{imageinfo};
#  return () unless $images;
#  $images = [ $images ] unless 'ARRAY' eq ref $images;
#  return map $_->{image_id}, @$images;
#}

#method childclass { 
#  $self->name eq 'Caption'
#    ? 'WWW::Phanfare::Class::Caption'
#    : 'WWW::Phanfare::Class::Image'
#}

sub childclass { 'WWW::Phanfare::Class::Image' }

# List of image filenames. They might be full path
#
method _idnames {
  my $images = $self->parent->_info->{images}{imageinfo};
  return {} unless $images;
  $images = [ $images ] unless 'ARRAY' eq ref $images;
  #use Data::Dumper;
  #warn 'Rendition subnodelist: ', Dumper [ map $_->{filename}, @$images ];
  #my @fullpath = ( map $_->{filename}, @$images );
  #warn 'Rendition subnodelist fullpath: ', Dumper \@fullpath;
  #my @filename = ( map $self->basename($_), @fullpath );
  #warn 'Rendition subnodelist filename: ', Dumper \@filename;
  #return map $self->basename($_), @fullpath;
  #my @filename;
  #for my $full ( @fullpath ) {
  #  push @filename, $self->_basename($full);
  #}
  #return { map {$_=>$_} @filename };

  return [
    map {{
      id   => $_->{image_id},
      name => $self->_basename( $_->{filename} ),
      obj  => $_,
    }}
    @$images
  ];
}

# Translate a full path filename to basename
#   Example: C:\Dir1\IMG_1234.JPG => IMG_1234.JPG
#
#method basename ( Str $filename ) {
#  #my $filename = shift;
#  my $basename = ( split /[\/\\]/, $filename)[-1]; # Remove dir path
#  if ( $self->nodename eq 'Caption' ) {
#    # Caption uses .txt extension
#    $basename =~ s/(.*)\..+?$/$1\.txt/ or $basename .= '.txt';
#  }
#  #warn "Rendition basename $filename -> $basename\n";
#  return $basename;
#}

#method subnodelist { $self->imageid } # XXX: Todo

#method subnodelist {
  ##my $type = $self->subnodetype;
  ## Create each node to extract its filename
  ##return(
    ##keys %{ $self->extraimage },
    ##map {
    ##  #warn "*** Creating new image subnode id=$_\n";
    ##  my $node = $type->new( image_id => $_, parent => $self );
    ##  #warn sprintf "*** image nodename is %s\n", $node->filename;
    ##  $node->filename;
    ##}
    ##$self->image_ids
  ##);
  #$self->image_filenames
#}

#method buildnode ( $nodename ) {
#  my $type = $self->subnodetype;
#
#  # Object is requested for image being uploaded
#  if ( $self->extraimage->{$nodename} ) {
#    warn "*** Rendition buildnode id=0\n";
#    return $type->new( image_id => 0, parent => $self );
#  }
#  # Build each node until the one with the correct filename is found
#  for my $id ( $self->image_ids ) {
#    warn "*** Rendition buildnode id=$id\n";
#    my $node = $type->new( image_id => $id, parent => $self );
#    return $node if $node->nodename eq $nodename;
#  }
#  warn "*** Rendition could not build $nodename\n";
#}

#method imagelist { $self->subnodelist }
#method image ( Str $imagename ) { $self->getnode( $imagename ) }

# Write a new image
#method create ( Str $nodename, Str $content ) {
#  # Only upload if inside Full dir. Set caption text if in Caption dir.
#  return undef
#    unless $self->nodename eq 'Full' or $self->nodename eq 'Caption';
#  
#  my $contentsize = length $content;
#  use Data::Dumper;
#  warn "*** Rendition $nodename size $contentsize";
#
#  if ( length $content == 0 ) {
#    warn "*** Rendition creating empty image $nodename\n";
#    ++$self->extraimage->{$nodename};
#
#    use Data::Dumper;
#    warn "*** Rendition extra images: " . Dumper $self->extraimage;
#  } else {
#    warn sprintf "*** Rendition NewImage uid %s album %s section %s filename %s size %s\n",
#      $self->uid,
#      $self->parent->parent->album_id,
#      $self->parent->section_id,
#      $nodename,
#      $contentsize;
#
#    delete $self->extraimage->{$nodename};
#    $self->api->NewImage(
#       target_uid => $self->uid,
#       album_id => $self->parent->parent->album_id,
#       section_id => $self->parent->section_id,
#       filename => $nodename,
#       content => $content,
#    );
#  }
#  
#  #open(my $fh, '>', \'');
#  #warn "*** Create write file handler $fh\n";
#  #return $fh;
#
#  # XXX: For now we just provide an empty string to write to;
#  #my $content = '';
#  #return $content;
#}

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
