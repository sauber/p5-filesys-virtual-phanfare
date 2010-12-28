package WWW::Phanfare::Class::Role::Branch;
use Moose::Role;
use MooseX::Method::Signatures;

requires 'subnodetype';
requires 'subnodelist';

# List of names of subnodes
#
#has subnodelist => (
#  is => 'rw',
#  isa => 'ArrayRef',
#  auto_deref => 1,
#);

# Create a named subnode
#
method buildnode ( Str $nodename ) {
  my $type = $self->subnodetype;
  $type->new( parent => $self, nodename=>$nodename );
}

#method getnode ( Str $nodename ) { $self->buildnode( $nodename ) }

with 'WWW::Phanfare::Class::Role::Node';

=head1 NAME

WWW::Phanfare::Class::Role::Branch - Node wtih sub nodes.

=cut

1;
