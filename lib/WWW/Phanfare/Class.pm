package WWW::Phanfare::Class;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::API;
use WWW::Phanfare::Class::Account;
use WWW::Phanfare::Class::Site;

has 'api_key'       => ( is=>'ro', isa=>'Str', required=>1 );
has 'private_key'   => ( is=>'ro', isa=>'Str', required=>1 );
has 'email_address' => ( is=>'ro', isa=>'Str' );
has 'password'      => ( is=>'ro', isa=>'Str' );

# Initialize account
has 'account' => (
  is         => 'ro',
  isa        => 'WWW::Phanfare::Class::Account',
  lazy_build => 1,
);
sub _build_account {
  my $self = shift;

  my $api = $self->api;

  # Login to create session
  my $session;
  if ( $self->email_address and $self->password ) {
    $session = $api->Authenticate(
      email_address => $self->email_address,
      password      => $self->password,
    );
  } else {
    $session = $api->AuthenticateGuest();
  }

  # Create account object with session data
  my $account = WWW::Phanfare::Class::Account->new(
    uid => $session->{session}{uid},
    gid => $session->{session}{public_group_id},
    parent => $self,
    nodename => '',
  );
  $account->setattributes( $session->{session} );
  return $account;
} 

# Initialize API  
has 'api' => (
  isa        => 'WWW::Phanfare::API',
  is         => 'ro',
  lazy_build => 1,
);
sub _build_api {
  my $self = shift;

  # Create an API Agent
  WWW::Phanfare::API->new(
    api_key     => $self->api_key,
    private_key => $self->private_key,
  );
}

method sitelist { $self->account->sitelist }
method site ( Str $sitename ) { $self->account->site( $sitename ) }

# XXX: For now assume there is only one site
method albumlist { $self->site($self->sitelist)->albumlist }
method album ( Str $albumname ) {
  $self->site($self->sitelist)->album( $albumname )
}

=head1 NAME

WWW::Phanfare::Class - Object interface to Phanfare library

=cut

1;
