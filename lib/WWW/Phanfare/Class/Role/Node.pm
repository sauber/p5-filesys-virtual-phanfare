package WWW::Phanfare::Class::Role::Node;
use Moose::Role;
use MooseX::Method::Signatures;

# For debug
sub x {
  use Data::Dumper;
  warn Data::Dumper->Dump([$_[1]], ["*** $_[0]"]);
}

# All nodes in the tree must have a parent
#
has parent => (
  is => 'ro',
  required => 1,
  isa => 'WWW::Phanfare::Class::Role::Node',
);

# Name of node
#
has nodename => (
  is => 'ro',
  required => 1,
  isa => 'Str',
);

# Get attributes and agent from parent
method uid   { $self->parent->uid   }
#method gid   { $self->parent->gid   }
method api { $self->parent->api }

# If this node has subnodes or attributes, scan them for a match
#
method getnode ( Str $nodename ) {
  return $self->buildnode($nodename)
    if $self->can('subnodelist')
    and grep /^$nodename$/, $self->subnodelist;
    
  return $self->attribute($nodename)
    if $self->can('attributelist')
    and grep /^$nodename$/, $self->attributelist;

  # Can a new node be created?
  return $self->buildnode($nodename)
    if $self->can('create');
}

# Get list of subnodes and attributes for this node
#
method nodelist {
  my     @list;
  push   @list, $self->subnodelist   if $self->can('subnodelist');
  push   @list, $self->attributelist if $self->can('attributelist');
  return @list;
}

# Search through a data tree parsed from xml to find substructures or attributes
#
method treesearch ( Ref $tree, ArrayRef $path ) {
  my @part = @$path;
  my $node = $tree;
  for my $part ( @$path ) {
    if ( ref $part eq 'HASH' ) {
      # Pick element from list
      my($key,$value) = each %$part;
      $node = [ $node ] unless ref $node eq 'ARRAY';
      my $notfound = {};
      for my $subnode ( @$node ) {
        my $treevalue = $subnode->{$key};
        # Take path off filenames
        $treevalue = $self->basename($treevalue) if $key eq 'filename';
        # Just compare first part of the string for cases with .id appended
        $treevalue = substr $treevalue, 0, length $value;
        #warn sprintf "*** Compare %s to %s\n", $value, $treevalue;
        if ( $value eq $treevalue ) {
          #warn "***   It matches\n";
          $node = $subnode;
          undef $notfound;
          last;
        }
      }
      $node = $notfound if $notfound;
    } else {
      # Pick attribute
      $node = $node->{$part};
    }
  }
  return $node;
}

# Translate a full path filename to basename
#   Example: C:\Dir1\IMG_1234.JPG => IMG_1234.JPG
#
method basename ( Str $filename ) {
  #my $filename = shift;
  my $basename = ( split /[\/\\]/, $filename)[-1]; # Remove dir path
  if ( $self->nodename eq 'Caption' ) {
    # Caption uses .txt extension
    $basename =~ s/(.*)\..+?$/$1\.txt/ or $basename .= '.txt';
  }
  #warn "Node filename $filename -> basename $basename\n";
  return $basename;
}


=head1 NAME

=cut

1;
