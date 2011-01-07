package WWW::Phanfare::Class;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::CacheAPI;
#use WWW::Phanfare::API;
use WWW::Phanfare::Class::Account;
use WWW::Phanfare::Class::Site;

has 'api_key'       => ( is=>'ro', isa=>'Str', required=>1 );
has 'private_key'   => ( is=>'ro', isa=>'Str', required=>1 );
has 'email_address' => ( is=>'ro', isa=>'Str' );
has 'password'      => ( is=>'ro', isa=>'Str' );
method subnodetype { 'WWW::Phanfare::Class::Account' }

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
  #warn '*** _build_account' . Dumper $session;

  # Create account object with session data
  #my $account = WWW::Phanfare::Class::Account->new(
  my $type = $self->subnodetype;
  my $account = $type->new(
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
  is         => 'rw',
  lazy_build => 1,
);
sub _build_api {
  my $self = shift;

  # Create an API Agent
  WWW::Phanfare::Class::CacheAPI->new(
    api_key     => $self->api_key,
    private_key => $self->private_key,
  );
}



# SITES
method sitelist { $self->account->sitelist }
method site ( Str $sitename ) { $self->account->site( $sitename ) }

# ALBUMDS
# XXX: For now assume there is only one site
method albumlist { $self->site($self->sitelist)->albumlist }
method album ( Str $albumname ) {
  $self->site($self->sitelist)->album( $albumname )
}

# SECTIONS
method sectionlist ( Str $albumname ){
  $self->album( $albumname )->sectionlist
}
method section ( Str $albumname, Str $sectionname ) {
  $self->album( $albumname )->section( $sectionname );
}

# RENDITIONS
method renditionlist ( Str $albumname, Str $sectionname ) {
  $self->album( $albumname )->section( $sectionname )->renditionlist;
}
method rendition ( Str $albumname, Str $sectionname, Str $renditionname ) {
  my $section = $self->album( $albumname )->section( $sectionname );
  $section->rendition( $renditionname );
}

# IMAGES
method imagelist ( Str $albumname, Str $sectionname, $renditionname ) {
  my $section = $self->album( $albumname )->section( $sectionname );
  $section->rendition( $renditionname )->imagelist;
}
method image ( Str $albumname, Str $sectionname, $renditionname, Str $imagename ) {
  my $section = $self->album( $albumname )->section( $sectionname );
  $section->rendition( $renditionname )->image( $imagename );
}

=head1 NAME

WWW::Phanfare::Class - Object interface to Phanfare library

=cut

1;
