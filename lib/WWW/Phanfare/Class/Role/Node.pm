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
}

# Get list of subnodes and attributes for this node
#
method nodelist {
  my     @list;
  push   @list, $self->subnodelist   if $self->can('subnodelist');
  push   @list, $self->attributelist if $self->can('attributelist');
  return @list;
}

=head1 NAME

=cut

1;
