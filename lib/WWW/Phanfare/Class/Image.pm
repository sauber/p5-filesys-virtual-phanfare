package WWW::Phanfare::Class::Image;
use Moose;
use MooseX::Method::Signatures;

has image_id     => ( is=>'ro', isa=>'Int', required=>1 );

has nodename     => ( is=>'ro', isa=>'Str', required=>0, lazy_build=>1 );
method _build_nodename { $self->filename }
#method nodename { $self->filename }

has filename     => ( is=>'ro', isa=>'Str', required=>0, lazy_build=>1 );
method _build_filename {
  my $basename = ( split /[\/\\]/, $self->imageinfo->{filename})[-1];
  if ( $self->parent->nodename eq 'Caption' ) {
    # Caption uses .txt extension
    $basename =~ s/(.*)\..+?$/$1\.txt/ or $basename .= '.txt';
  }
  return $basename;
}

has caption      => ( is=>'ro', isa=>'Str', required=>0, lazy_build=>1 );
method _build_caption { $self->imageinfo->{caption} }

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
method _build_size { $self->renditioninfo->{filesize} } 

method imageinfo {
  my $info = $self->treesearch(
    $self->parent->parent->sectioninfo->{images}{imageinfo},
    [ { image_id => $self->image_id } ]
  );
  #use Data::Dumper;
  #warn sprintf "*** imageinfo for id %s: %s", $self->image_id, Dumper $info;
  #warn sprintf "*** imageinfo for id %s: %s ", $self->image_id, $info->{filename};
  return $info;
}

method renditioninfo {
  # Manually created informtion for Caption rendition type
  if ( $self->parent->nodename eq 'Caption' ) {
    my $date = $self->treesearch(
      $self->imageinfo->{renditions}{rendition},
      [ { rendition_type => 'Full' } ]
    )->{created_date};
    return {
      filesize => length $self->caption,
      created_date => $date,
    }
  }
  
  # All other valid rendition types
  return $self->treesearch(
    $self->imageinfo->{renditions}{rendition},
    [ { rendition_type => $self->parent->nodename } ]
  );

  #use Data::Dumper;
  #warn sprintf "*** renditioninfo for id %s rendition %s: %s", $self->image_id, $self->parent->nodename, Dumper $info;
  #unless ( ref $info eq 'HASH' ) {
  #  use Data::Dumper;
  #  warn "*** renditioninfo for $self is not HASH: " . Dumper $info;
  #}
  #return $info;
}

# Get binary image or caption
method value {
  if ( $self->parent->nodename eq 'Caption' ) {
    return $self->caption;
  } else {
    #warn sprintf "*** Fetching %s\n", $self->url;
    my $content = $self->api->geturl( $self->url );
    #warn sprintf "*** Fetched image size is %s\n", length $content;
    # Set size so ls can show accurate value now that it's known
    $self->size( length $content );
    return $content;
  }
}

with 'WWW::Phanfare::Class::Role::Leaf';
#with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Image - Image Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
