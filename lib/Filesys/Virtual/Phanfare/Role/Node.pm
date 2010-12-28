package Filesys::Virtual::Phanfare::Role::Node;
use Moose::Role;
use MooseX::Method::Signatures;

# All nodes in the tree must have a parent
#
has parent => (
  is => 'ro',
  required => 1,
  isa => 'Filesys::Virtual::Phanfare::Role::Node',
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
method gid   { $self->parent->gid   }
method agent { $self->parent->agent }

# If this node has subnodes or attributes, scan them for a match
#
method getnode ( Str $nodename ) {
  return $self->buildnode($nodename)
    if $self->can('subnodelist')
    and grep /^$nodename$/, $self->subnodelist;
    
  return $self->attribute($nodename)
    if $self->can('attributelist')
    and grep /^$nodename$/, $self->attributelist;
}

# Get list of subnodes and attributes for this node
#
method nodelist {
  my     @list;
  push   @list, $self->subnodelist   if $self->can('subnodelist');
  push   @list, $self->attributelist if $self->can('attributelist');
  return @list;
}

with 'Filesys::Virtual::Phanfare::Role::File';

1;
