package WWW::Phanfare::Class::Image;
use Moose;
use MooseX::Method::Signatures;

# When writing to image value check if the image data is valid.
# If valid upload immediately.
# If not valid, then the value might be appended to, so wait.

#has image_id     => ( is=>'ro', isa=>'Int', required=>1 );
has image_id     => ( is=>'ro', isa=>'Int', lazy_build=>1 );
method _build_image_id {
  # Image data is stored in section's sectioninfo
  #warn "Image _build_image_id filename: ". $self->nodename ."\n";
  my $info = $self->_treesearch(
    $self->parent->parent->_info->{images}{imageinfo},
    [ { filename => $self->name } ]
  );
  #use Data::Dumper;
  #warn "Image info:" . Dumper $info;
  $info->{image_id};
}

#has nodename     => ( is=>'ro', isa=>'Str', required=>0, lazy_build=>1 );
#method _build_nodename { $self->filename }
#method nodename { $self->filename }

has filename     => ( is=>'ro', isa=>'Str', required=>0, lazy_build=>1 );
method _build_filename {
  my $basename = ( split /[\/\\]/, $self->imageinfo->{filename})[-1];
  #if ( $self->rendition->name eq 'Caption' ) {
  #  # Caption uses .txt extension
  #  $basename =~ s/(.*)\..+?$/$1\.txt/ or $basename .= '.txt';
  #}
  return $basename;
}

method caption ( Str $value? ) {
  # Read
  return $self->imageinfo->{caption} unless defined $value;

  # Write
  return $self->api->UpdateCaption(
    target_uid => $self->uid,
    album_id   => $self->album->id,
    section_id => $self->section->id,
    image_id   => $self->id,
    caption    => $value,
  ) or return undef;
  return $self->imageinfo->{caption} = $value;
}

method hidden ( Bool $value? ) {
  # Read
  return $self->imageinfo->{hidden} unless defined $value;

  # Write
  return $self->api->HideImage(
    target_uid => $self->uid,
    album_id   => $self->album->id,
    section_id => $self->section->id,
    image_id   => $self->id,
    hide       => $value,
  ) or return undef;
  return $self->imageinfo->{hidden} = $value;
}


# XXX: Probably all are required
#has image_date   => ( is=>'ro', isa=>'Str', required=>0 );
#has is_video     => ( is=>'ro', isa=>'Int', required=>0 );
#has hidden       => ( is=>'ro', isa=>'Int', required=>0 );
#has filesize     => ( is=>'ro', isa=>'Int', required=>0 );
#has width        => ( is=>'ro', isa=>'Int', required=>0 );
#has heigh        => ( is=>'ro', isa=>'Int', required=>0 );
#has created_date => ( is=>'ro', isa=>'Str', required=>0 );
#has media_type   => ( is=>'ro', isa=>'Str', required=>0 );
#has quality      => ( is=>'ro', isa=>'Str', required=>0 );

has url          => ( is=>'ro', isa=>'Str', required=>0, lazy_build=>1 );
method _build_url { $self->renditioninfo->{url} } 

# Overwrite size method from Leaf Role
has size         => ( is=>'rw', isa=>'Int', required=>0, lazy_build=>1 );
method _build_size { $self->renditioninfo->{filesize} || 0 } 

method imageinfo {
  return {} if $self->image_id == 0;
  # Image data is stored in section's sectioninfo
  my $info = $self->_treesearch(
    $self->parent->parent->_info->{images}{imageinfo},
    [ { image_id => $self->image_id } ]
  );
  #use Data::Dumper;
  #warn sprintf "*** imageinfo for id %s: %s", $self->image_id, Dumper $info;
  #warn sprintf "*** imageinfo for id %s: %s ", $self->image_id, $info->{filename};
  return $info;
}

method renditioninfo {
  return {} if $self->image_id == 0;
  # Manually created informtion for Caption rendition type
  #if ( $self->rendition->name eq 'Caption' ) {
  #  my $date = $self->_treesearch(
  #    $self->imageinfo->{renditions}{rendition},
  #    [ { rendition_type => 'Full' } ]
  #  )->{created_date};
  #  return {
  #    filesize => length $self->caption,
  #    created_date => $date,
  #  }
  #}
  
  # All other valid rendition types
  return $self->_treesearch(
    $self->imageinfo->{renditions}{rendition},
    [ { rendition_type => $self->rendition->name } ]
  );

  #use Data::Dumper;
  #warn sprintf "*** renditioninfo for id %s rendition %s: %s", $self->image_id, $self->parent->nodename, Dumper $info;
  #unless ( ref $info eq 'HASH' ) {
  #  use Data::Dumper;
  #  warn "*** renditioninfo for $self is not HASH: " . Dumper $info;
  #}
  #return $info;
}

# Get binary image or caption text
method value ( Str $value? ) {
  # Write
  return $self->setvalue( $value ) if $value;

  # Read
  #if ( $self->rendition->name eq 'Caption' ) {
  #  return $self->caption;
  #} else {
    #warn sprintf "*** Fetching %s\n", $self->url;
    my $content = $self->api->geturl( $self->url );
    #warn sprintf "*** Fetched image size is %s\n", length $content;
    # Set size so ls can show accurate value now that it's known
    $self->size( length $content );
    return $content;
  #}
}

# XXX TODO
method setvalue ( Str $value ) {
  if ( $self->rendition->name eq 'Full' ) {
  } else {
  }
  #warn sprintf "*** Wrote %s bytes to value\n", length $value;
}

method album     { $self->parent->parent->parent }
method section   { $self->parent->parent         }
method rendition { $self->parent                 }

method _write {
  if ( $self->rendition->name eq 'Full' ) {
    #warn sprintf "*** Error: Trying to write image in %s rendition\n", $self->rendition->name;
    # XXX: Set time stamp
    return $self->api->NewImage(
      target_uid => $self->uid,
      album_id   => $self->album->id,
      section_id => $self->section->id,
      filename   => $self->name,
      #content    => $self->value,
      #image_date  => ..., # XXX TODO how do pass date in here?
    );
  } else {
    warn sprintf "*** Error: Write image %s in %s rendition failed\n", $self->name, $self->rendition->name;
    return undef;
  }
}

method _delete {
  return unless $self->parent->name eq 'Full';
  $self->api->DeleteImage(
    target_uid => $self->uid,
    album_id => $self->album->id,
    section_id => $self->section->id,
    image_id => $self->id,
  );
}
  

# 'hide' and 'caption' are the only attributes that can be updated
#
method _update ( Str $key, Str $value ) {
  if ( $key eq 'caption' ) {
    return $self->caption( $value );
  } elsif ( $key eq 'hidden' ) {
    return $self->hidden( $value );
  }
  return undef;
}

with 'WWW::Phanfare::Class::Role::Leaf';
with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Image - Image Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
