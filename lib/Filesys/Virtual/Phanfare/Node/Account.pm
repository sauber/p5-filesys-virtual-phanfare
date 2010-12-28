package Filesys::Virtual::Phanfare::Node::Account;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::API;
use Carp;
use Filesys::Virtual::Phanfare::Node::Site;

has 'agent' => ( is=>'rw', required=>1, isa=>'WWW::Phanfare::API' );
has 'uid'   => ( is=>'rw', required=>1, isa=>'Int' );
has 'gid'   => ( is=>'rw', required=>1, isa=>'Int' );
#has 'sitelist' => ( is=>'ro', isa=>'HashRef', lazy_build=>1 );
has subnodetype => ( is=>'ro', isa=>'Str', default => 'Filesys::Virtual::Phanfare::Node::Site' );

# We have just one subnode - the primary site name
# XXX: Can we access other sites somehow?
#
method subnodelist {
  $self->attribute('primary_site_name')->value;
}

# List of available sites
#method _build_nodes {
#  my $sitename = $self->attribute('primary_site_name')->value;
#  return {
#    $sitename => Filesys::Virtual::Phanfare::Node::Site->new(
#      parent => $self,
#    )
#  };
#  #return [ $sitename ];
#}

# When object is created, log into Phanfare right away
# XXX: Don't have new method - instead use builder
method login ( Str :$api_key, Str :$private_key, Str :$email_address?, Str :$password? ) {
  # Create new Phanfare API agent
  my $agent;
  if ( $api_key and $private_key ) {
    $agent = WWW::Phanfare::API->new(
      api_key     => $api_key,
      private_key => $private_key,
    );
  } else {
    croak "api_key and private_key are required for Phanfare API";
  }
  $self->agent( $agent );

  # Authenticate as user or guest
  my $session;
  if ( $email_address and $password ) {
    $session = $agent->Authenticate(
      email_address => $email_address,
      password      => $password,
    );
    $self->uid( $session->{session}{uid} );
    $self->gid( $session->{session}{public_group_id} );
  } else {
    $session = $agent->AuthenticateGuest();
  }
  $self->attributes( $session->{session} );

  return $self;
}

# Size of account dir
#method size {
#  # XXX: something more reasonable...
#  int rand 1024*64;
#}

# And attribute or a site
#method getnode ( Str $nodename ) {
#  #warn "*** account getnode: $nodename\n";
#  if ( grep /^$nodename$/, $self->attributelist ) {
#    #warn "*** $nodename is an attribute\n";
#    return $self->attribute( $nodename );
#  } elsif ( grep /^$nodename/, keys %{ $self->sitelist } ) {
#    #warn "*** $nodename is in sitelist\n";
#    $self->{_site}{$nodename} ||= Filesys::Virtual::Phanfare::Node::Site->new(
#      sitename => $nodename,
#      uid => $self->uid,
#      gid => $self->gid,
#      _agent => $self->_agent,
#    );
#    return $self->{_site}{$nodename};
#  } else {
#    #warn "*** $nodename is unknown\n";
#    return undef;
#  }
#}

# List of sites and properties
#
#method list {
#  return (
#    keys %{ $self->sitelist   },
#    keys %{ $self->attributes },
#  );
#}

with 'Filesys::Virtual::Phanfare::Role::Branch';
with 'Filesys::Virtual::Phanfare::Role::Attributes';

1;

=head1 NAME

Filesys::Virtual::Phanfare::Node::Account - Account Node

=head1 SUBROUTINES/METHODS

=head2 new

Create object

=head1 SEE ALSO

L<Filesys::Virtual::Phanfare>

=cut
