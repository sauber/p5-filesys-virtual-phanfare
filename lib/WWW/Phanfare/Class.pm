package WWW::Phanfare::Class;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::CacheAPI;
use WWW::Phanfare::API;
use WWW::Phanfare::Class::Account;

has 'api_key'       => ( is=>'ro', isa=>'Str', required=>1 );
has 'private_key'   => ( is=>'ro', isa=>'Str', required=>1 );
has 'email_address' => ( is=>'ro', isa=>'Str' );
has 'password'      => ( is=>'ro', isa=>'Str' );
sub childclass { 'WWW::Phanfare::Class::Account' }

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

  #use Data::Dumper;
  #warn '*** Class _build_account: ' . Dumper $session;

  warn sprintf "*** Error: Could not login: %s\n", $session->{code_value}
    unless $session->{stat} eq 'ok';

  # Create account object with session data
  #my $account = WWW::Phanfare::Class::Account->new(
  my $type = $self->childclass;
  my $account = $type->new(
    uid => $session->{session}{uid},
    gid => $session->{session}{public_group_id},
    parent => $self,
    name => '',
    id => 0,
  );
  $account->setattributes( $session->{session} );
  #my %attr = %{ $session->{session} };
  ## Can only handle scalar attributes for now
  #%attr = map { ref $attr{$_} ? () : ($_=>$attr{$_}) } keys %attr;
  #$account->setattributes( %attr );
  return $account;
} 

# Initialize API  
has api => (
  isa        => 'WWW::Phanfare::API',
  is         => 'rw',
  lazy_build => 1,
);
sub _build_api {
  my $self = shift;

  # Create an API Agent
  #WWW::Phanfare::API->new(
  WWW::Phanfare::Class::CacheAPI->new(
    api_key     => $self->api_key,
    private_key => $self->private_key,
  );
}


# Get a subnode, by name of name.id
#
method get ( Str $name ) {
  #for my $node ( $self->list ) {
  #return $node if $name eq $node->name .'.'. $node->id;
  #return $node if $name eq $node->name;
  #}
  $self->account->list;
}

sub AUTOLOAD {
  my $self = shift @_;
  our $AUTOLOAD;

  my $name = $AUTOLOAD;
  $name =~ s/.*:://;

  return $self->get($name);
}



=head1 NAME

WWW::Phanfare::Class - Object interface to Phanfare library

=cut

1;
