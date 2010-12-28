package Filesys::Virtual::Phanfare::Node::Attribute;
use Moose;
use MooseX::Method::Signatures;

has 'value' => ( isa => 'Str', is=>'rw', );

# Size of attribute
#
method size { length $self->value }

method open_read {
  my $content = $self->value . "\n";
  open( my $fh, '<', \$content );
  warn "*** create file hander $fh\n";
  return $fh;
}

method close_read {
  my ($fh) = @_;
  warn "*** close_read fh: $fh\n";
  return close $fh;
}

with 'Filesys::Virtual::Phanfare::Role::Leaf';

=head1 NAME

Filesys::Virtual::Phanfare::Node::Attribute - Node Attribute

=head1 SUBROUTINES/METHODS
  
=head2 new
    
Create object

=head1 SEE ALSO

L<Filesys::Virtual::Phanfare>

=cut

1;
