package WWW::Phanfare::Class::Image;
use Moose;
use MooseX::Method::Signatures;

# XXX: Probably all are required
has filename     => ( is=>'ro', isa=>'Str', required=>0 );
has caption      => ( is=>'ro', isa=>'Str', required=>0 );
has image_date   => ( is=>'ro', isa=>'Str', required=>0 );
has is_video     => ( is=>'ro', isa=>'Int', required=>0 );
has hidden       => ( is=>'ro', isa=>'Int', required=>0 );
has filesize     => ( is=>'ro', isa=>'Int', required=>0 );
has width        => ( is=>'ro', isa=>'Int', required=>0 );
has heigh        => ( is=>'ro', isa=>'Int', required=>0 );
has created_date => ( is=>'ro', isa=>'Str', required=>0 );
has media_type   => ( is=>'ro', isa=>'Str', required=>0 );
has quality      => ( is=>'ro', isa=>'Str', required=>0 );
has url          => ( is=>'ro', isa=>'Str', required=>0 );

with 'WWW::Phanfare::Class::Role::Leaf';
#with 'WWW::Phanfare::Class::Role::Attributes';

=head1 NAME

WWW::Phanfare::Class::Image - Image Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
