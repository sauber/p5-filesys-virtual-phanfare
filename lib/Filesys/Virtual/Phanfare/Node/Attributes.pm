package Filesys::Virtual::Phanfare::Node::Attributes;
use Moose::Role;
use Filesys::Virtual::Phanfare::Node::Attribute;


# Get or set list of attributes
# input and output is hashref
#
sub attributes {
  my $self = shift;
  my $data = shift;

  if ( $data ) {
    # Delete all previous attributes
    delete $self->{_attr};

    # Set new attributes
    while ( my($key,$value) = each %$data ) {
      # XXX: For now only handle strings
      next if ref $value;
      $self->{_attr}{$key} = Filesys::Virtual::Phanfare::Node::Attribute->new( value => $value );
    }
  } else {
    # Read all attribute values
    #warn "*** reading attributes for $self\n";
    return {
      map { $_ => $self->{_attr}{$_}->value }
      keys %{ $self->{_attr} }
    }
  }
}

# Get or set an attributes
#
sub attribute {
  my($self, $key, $value) = @_;

  if ( $value ) {
    $self->{_attr}{$key} = Filesys::Virtual::Phanfare::Node::Attribute->new( value => $value );
  }
  return $self->{_attr}{$key}; # Object reference
}

1;
