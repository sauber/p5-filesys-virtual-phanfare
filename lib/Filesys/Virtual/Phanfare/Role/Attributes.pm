package Filesys::Virtual::Phanfare::Role::Attributes;
use Moose::Role;
use Filesys::Virtual::Phanfare::Node::Attribute;
use MooseX::Method::Signatures;

has '_attr' => (
  is => 'rw',
  isa => 'HashRef[Filesys::Virtual::Phanfare::Node::Attribute]',
);

# Set list of attributes
#
method setattributes ( HashRef $data ) {
  my %attr;
  while ( my($key,$value) = each %$data ) {
    # XXX: For now only handle strings
    next if ref $value;
    $attr{$key} = Filesys::Virtual::Phanfare::Node::Attribute->new(
      value => $value,
      parent => $self,
    );
  }
  $self->_attr( \%attr );
  return $self;
}

# Get or set an attributes
#
method attribute ( Str $key, Str $value? ) {
  # Set value
  if ( $value ) {
    my $attr = $self->_attr || {};
    $attr->{$key} = Filesys::Virtual::Phanfare::Node::Attribute->new(
      value => $value,
      parent => $self,
    );
    $self->_attr( $attr );
  }

  # Get value
  return $self->_attr->{$key}; # Object reference
}

# List of attribute names
#
method attributelist {
  keys %{ $self->_attr };
}

=head1 NAME

Filesys::Virtual::Phanfare::Node::Attributes - Node Attributes

=head1 SUBROUTINES/METHODS
  
=head2 new
    
Create object.

=head2 attribute

Get named attribute object.

=head2 attributes

Get hashref of all attribute key/value pairs

=head2 attributelist

List of all attribute keys.

=head1 SEE ALSO

L<Filesys::Virtual::Phanfare>

=cut


1;
