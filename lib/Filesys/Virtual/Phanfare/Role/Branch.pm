package Filesys::Virtual::Phanfare::Role::Branch;
use Moose::Role;
use MooseX::Method::Signatures;

# 
#has nodes (
#  is => 'ro',
#  isa => 'HashRef[Filesys::Virtual::Phanfare::Role::Node]',
#  lazy_build => 1,
#);

# Of what type are subnodes
# #

requires 'subnodetype';

# List of names of subnodes
#
has subnodelist => (
  is => 'rw',
  isa => 'ArrayRef',
  auto_deref => 1,
);

# Create a named subnode
#
method buildnode ( Str $nodename ) {
  my $type = $self->subnodetype;
  $type->new( parent => $self, nodename=>$nodename );
}

with 'Filesys::Virtual::Phanfare::Role::Dir';

1;
