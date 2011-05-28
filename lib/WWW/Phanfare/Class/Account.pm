package WWW::Phanfare::Class::Account;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Site;

#has 'uid'   => ( is=>'rw', isa=>'Int' );
method uid { $self->attribute('uid') }
#has 'gid'   => ( is=>'rw', isa=>'Int' );
has parent => ( is=>'ro', required=>1, lazy_build=>1 );
sub _build_parent { shift }

# We have just one subnode - the primary site name
# XXX: Can we access other sites somehow?
#
#method subnodelist { $self->attribute('primary_site_name')->value }
#method subnodetype { 'WWW::Phanfare::Class::Site' }
sub childclass { 'WWW::Phanfare::Class::Site' }

#method sitelist { $self->subnodelist }
#method site ( Str $sitename ) { $self->getnode( $sitename ) }

method _idnames {
  #my %sites = (
  #  $self->attribute('primary_site_id') => $self->attribute('primary_site_name')
  #);
  #return \%sites;
  return [{
    id => $self->attribute('primary_site_id'),
    name => $self->attribute('primary_site_name'),
  }];
}

#method _build__attr {
#  $self->parent->_info...
#}

with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

1;

=head1 NAME

WWW::Phanfare::Class::Account - Account Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
