package Filesys::Virtual::Phanfare::Node::Attribute;
use Moose;
use MooseX::Method::Signatures;

has 'value' => ( isa => 'Str', is=>'rw', );

# Size of attribute
#
method size { length $self->value }

=head1 NAME

Filesys::Virtual::Phanfare::Node::Attribute - Node Attribute

=head1 SUBROUTINES/METHODS
  
=head2 new
    
Create object

=head1 SEE ALSO

L<Filesys::Virtual::Phanfare>

=cut

1;
