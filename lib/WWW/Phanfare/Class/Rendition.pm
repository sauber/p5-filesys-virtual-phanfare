package WWW::Phanfare::Class::Rendition;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Image;

method subnodetype { 'WWW::Phanfare::Class::Image' }
method subnodelist { qw(IMG1.jpg IMG2.png) } # XXX: Todo

method imagelist { $self->subnodelist }
#method image ( Str $imagename ) { $self->getnode( $imagename ) }
method image ( Str $imagename ) { $self->getnode( $imagename ) }

with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Rendition - Rendition Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
