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
      $self->{_attr}{$key} = Filesys::Virtual::Phanfare::Node::Attribute->new(
        value => $value,
        uid => $self->uid,
        gid => $self->gid,
      );
    }
  } else {
    # Read all attribute values
    #warn "*** reading attributes for $self\n";
    return {
      map { $_ => $self->{_attr}{$_}->value }
      $self->attributelist
    }
  }
}

# Get or set an attributes
#
sub attribute {
  my($self, $key, $value) = @_;

  if ( $value ) {
    $self->{_attr}{$key} = Filesys::Virtual::Phanfare::Node::Attribute->new(
      value => $value,
      uid => $self->uid,
      gid => $self->gid,
    );
  }
  return $self->{_attr}{$key}; # Object reference
}

# List of attribute names
#
sub attributelist {
  my $self = shift;
  keys %{ $self->{_attr} };
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
