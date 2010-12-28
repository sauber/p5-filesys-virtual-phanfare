package WWW::Phanfare::Class::Album;
use Moose;
use MooseX::Method::Signatures;
#use WWW::Phanfare::Class::Section;

has album_id => ( is=>'ro', isa=>'Int', required=>1 );
has album_name => ( is=>'ro', isa=>'Str', required=>1 );

method subnodelist { 'Main Section' }
method subnodetype { 'WWW::Phanfare::Class::Album' }

with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Account - Album Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
