package WWW::Phanfare::Class::Rendition;
use Moose;
use MooseX::Method::Signatures;
#use WWW::Phanfare::Class::Image;

has section_id   => ( is=>'ro', isa=>'Int', required=>1 );
has section_name => ( is=>'ro', isa=>'Str', required=>1 );

method subnodetype { 'WWW::Phanfare::Class::Rendition' } # XXX: Image
method subnodelist { qw(IMG1.jpg IMG2.png) } # XXX: Todo

method imagelist { $self->subnodelist }
#method image ( Str $sectionname ) { $self->getnode( $sectionname ) }

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
