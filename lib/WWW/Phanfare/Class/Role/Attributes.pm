package WWW::Phanfare::Class::Role::Attributes;
use Moose::Role;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Attribute;

has '_attr' => (
  is => 'rw',
  isa => 'HashRef[WWW::Phanfare::Class::Attribute]',
);

# Set list of attributes
#
method setattributes ( HashRef $data ) {
  my %attr;
  while ( my($key,$value) = each %$data ) {
    # XXX: For now only handle strings
    next if ref $value;
    $attr{$key} = WWW::Phanfare::Class::Attribute->new(
      value => $value,
      parent => $self,
      nodename => $key,
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
    $attr->{$key} = WWW::Phanfare::Class::Attribute->new(
      value => $value,
      parent => $self,
      nodename => $key,
    );
    $self->_attr( $attr );
  }

  # Get value
  return $self->_attr->{$key}; # Object reference
}

# List of attribute names
#
method attributelist {
  return () unless $self->_attr;
  keys %{ $self->_attr };
}

=head1 NAME

WWW::Phanfare::Class::Role::Attributes - Node Attributes

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

L<WWW::Phanfare::Class>

=cut

1;
