package Filesys::Virtual::Phanfare::Node::Attribute;
use Moose;
use MooseX::Method::Signatures;

has 'value' => ( isa => 'Str', is=>'rw', );

# Size of attribute
#
method size { length $self->value }

1;
