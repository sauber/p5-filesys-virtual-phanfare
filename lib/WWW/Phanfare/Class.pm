package WWW::Phanfare::Class;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::CacheAPI;
use WWW::Phanfare::Class::Account;

has 'api_key'       => ( is=>'ro', isa=>'Str', required=>1 );
has 'private_key'   => ( is=>'ro', isa=>'Str', required=>1 );
has 'email_address' => ( is=>'ro', isa=>'Str' );
has 'password'      => ( is=>'ro', isa=>'Str' );
sub childclass { 'WWW::Phanfare::Class::Account' }
#has list => ( is=>'ro'. isa=>'ArrayRef[WWW::Phanfare::Class::Account]', default=>sub{ shift->account->list } );
#has name => ( is=>'ro', isa=>'Str' );
#has id => ( is=>'ro', isa=>'Str' );

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
  my $type = $self->childclass;
  my $account = $type->new(
    uid => $session->{session}{uid},
    gid => $session->{session}{public_group_id},
    parent => $self,
    name => '',
    id => 0,
  );
  #$account->setattributes( %{ $session->{session} } );
  my %attr = %{ $session->{session} };
  # Can only handle scalar attributes for now
  %attr = map { ref $attr{$_} ? () : ($_=>$attr{$_}) } keys %attr;
  $account->setattributes( %attr );
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
  WWW::Phanfare::Class::CacheAPI->new(
    api_key     => $self->api_key,
    private_key => $self->private_key,
  );
}

#method names {
#  return 'sites';
#}

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


## SITES
#method sitelist { $self->account->sitelist }
#method site ( Str $sitename ) { $self->account->site( $sitename ) }
#
## YEARS
## XXX: For now assume there is only one site
#method yearlist { $self->site($self->sitelist)->yearlist }
#method year ( Str $yearname ) {
#  $self->site($self->sitelist)->year( $yearname )
#}
#
## ALBUMS
#method albumlist ( Int $year ) { $self->year( $year )->albumlist }
#method album ( Int $year, Str $albumname ) {
#  $self->year($year)->album( $albumname )
#}
#
## SECTIONS
#method sectionlist ( Int $year, Str $albumname ){
#  $self->year($year)->album( $albumname )->sectionlist
#}
#method section ( Int $year, Str $albumname, Str $sectionname ) {
#  $self->year($year)->album( $albumname )->section( $sectionname );
#}
#
## RENDITIONS
#method renditionlist ( Int $year, Str $albumname, Str $sectionname ) {
#  $self->year($year)->album( $albumname )->section( $sectionname )->renditionlist;
#}
#method rendition ( Int $year, Str $albumname, Str $sectionname, Str $renditionname ) {
#  my $section = $self->year($year)->album( $albumname )->section( $sectionname );
#  $section->rendition( $renditionname );
#}
#
## IMAGES
#method imagelist ( Int $year, Str $albumname, Str $sectionname, $renditionname ) {
#  my $section = $self->year($year)->album( $albumname )->section( $sectionname );
#  $section->rendition( $renditionname )->imagelist;
#}
#method image ( Int $year, Str $albumname, Str $sectionname, $renditionname, Str $imagename ) {
#  my $section = $self->year($year)->album( $albumname )->section( $sectionname );
#  $section->rendition( $renditionname )->image( $imagename );
#}

=head1 NAME

WWW::Phanfare::Class - Object interface to Phanfare library

=cut

1;
