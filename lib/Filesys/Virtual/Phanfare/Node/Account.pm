package Filesys::Virtual::Phanfare::Node::Account;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::API;
use Carp;

has 'uid'      => ( is=>'rw', isa=>'Int' );
has 'gid'      => ( is=>'rw', isa=>'Int' );
has '_agent'   => ( is=>'rw', isa=>'WWW::Phanfare::API' );
has 'sitelist' => ( is=>'ro', isa=>'ArrayRef', lazy_build=>1 );

# List of available sites
sub _build_sitelist {
  my $self = shift;

  my $sitename = $self->attribute('primary_site_name')->value;
  #return { $sitename => Filesys::Virtual::Phanfare::Node::Site->new( sitename => $sitename ) };
  return [ $sitename ];
}

# When object is created, log into Phanfare right away
sub new {
  my $that  = shift;
  my %args = @_;

  my $class = ref($that) || $that;
  my $self = {};
  bless $self, $class;

  # Create new Phanfare API agent
  my $agent;
  if ( $args{api_key} and $args{private_key} ) {
    $agent = WWW::Phanfare::API->new(
      api_key     => $args{api_key},
      private_key => $args{private_key},
    );
  } else {
    croak "api_key and private_key are required for Phanfare API";
  }
  $self->_agent( $agent );

  # Authenticate as user or guest
  my $session;
  if ( $args{email_address} and $args{password} ) {
    $session = $agent->Authenticate(
      email_address => $args{email_address},
      password      => $args{password},
    );
    $self->uid( $session->{session}{uid} );
    $self->gid( $session->{session}{public_group_id} );
    #$self->{_top} = $session->{session};
  } else {
    $session = $agent->AuthenticateGuest();
  }
  $self->attributes( $session->{session} );

  return $self;
}

method size {
  # XXX: something more reasonable...
  int rand 1024*64;
}

# List of sites and properties
#
method list {
  return (
    @{ $self->sitelist },
    keys %{ $self->attributes }
  );
}

with 'Filesys::Virtual::Phanfare::Node::Attributes';
with 'Filesys::Virtual::Phanfare::Node::Dir';
