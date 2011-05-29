package WWW::Phanfare::Class::Role::Attributes;
use Moose::Role;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Attribute;

#has '_attr' => (
#  is => 'rw',
#  isa => 'HashRef[WWW::Phanfare::Class::Attribute]',
#);

# From http://search.cpan.org/~doy/Moose-2.0006/lib/Moose/Meta/Attribute/Native/Trait/Hash.pm
has '_attr' => (
  traits    => ['Hash'],
  is        => 'ro',
  isa       => 'HashRef[Str]',
  default   => sub { {} },
  #lazy_build => 1,
  handles   => {
    _set_attr     => 'set',
    #get_attribute     => 'get',
    #has_no_options => 'is_empty',
    #num_options    => 'count',
    #delete_option  => 'delete',
    #option_pairs   => 'kv',
    #attribute => 'accessor',
    attributes => 'keys',
  },
);

# Set multiple attributes at once
#
method setattributes ( HashRef $data ) {
  my %attr = map {
    ref $data->{$_}
      ? ()
      : ( $_ => $data->{$_} )
  } keys %$data;
  #use Data::Dumper;
  #warn "*** Attributes set: " . Dumper \%attr;
  $self->_set_attr( %attr );
}

# Get or set an attribute
#
method attribute ( Str $key, Str $value? ) {
  # Read
  return $self->_attr->{$key} unless defined $value;

  # Write
  if ( $self->can('_update') ) {
    #warn "*** Attributes attribute write $key:$value\n";
    defined $self->_update( $key => $value ) or return undef;
    $self->_set_attr( $key => $value );
    #warn "*** Attribes attribute write $key:$value succeeded\n";
  } else {
    #warn "*** Attribes attribute write $key:$value not supported\n";
    return undef;
  }
}

#requires '_build__attr';

# From http://search.cpan.org/~doy/Moose-2.0006/lib/Moose/Manual/MethodModifiers.pod
#after 'options'  => sub { print "Need to upload new attributes to Phanfare\n"; };


# Set list of attributes
#
#method setattributes ( HashRef $data ) {
#  my %attr;
#  while ( my($key,$value) = each %$data ) {
#    # XXX: For now only handle strings
#    next if ref $value;
#    $attr{$key} = WWW::Phanfare::Class::Attribute->new(
#      value => $value,
#      parent => $self,
#      nodename => $key,
#    );
#  }
#  $self->_attr( \%attr );
#  return $self;
#}

# Get or set an attributes
#
#method attribute ( Str $key, Str $value? ) {
#  # Try to build attributes if not already done
#  $self->buildattributes if not $self->_attr and $self->can('buildattributes');
#
#  # Set value
#  if ( $value ) {
#    my $attr = $self->_attr || {};
#    $attr->{$key} = WWW::Phanfare::Class::Attribute->new(
#      value => $value,
#      parent => $self,
#      nodename => $key,
#    );
#    $self->_attr( $attr );
#  }
#
#  # Get value
#  return $self->_attr->{$key}; # Object reference
#}

# List of attribute names
#
#method attributelist {
#  # Try to build attributes if not already done
#  $self->buildattributes if not $self->_attr and $self->can('buildattributes');
#
#  return () unless $self->_attr;
#  keys %{ $self->_attr };
#}

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
