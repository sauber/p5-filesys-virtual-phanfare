package WWW::Phanfare::Class::CacheAPI;
use Cache::Memory;
use Carp;
use Data::Dumper;

use base qw( WWW::Phanfare::API );
our $AUTOLOAD;

#sub new {
#  my $that  = shift;
#  my $class = ref($that) || $that;
#  my $self  = { @_ };
#  bless $self, $class;
#  return $self;
#}

our $CACHE = Cache::Memory->new(
  namespace       => 'WWW::Phanfare::Class',
  default_expires => '30 sec',
);

sub AUTOLOAD {
  my $self = shift;
  croak "$self is not an object" unless ref($self);

  my $method = $AUTOLOAD;
  $method =~ s/.*://;   # strip fully-qualified portion
  croak "method not defined" unless $method;

  my $cachestring = join ',', $method, @_;
  my $result = $CACHE->thaw( $cachestring );
  unless ( $result ) {
    #warn "*** Caching $cachestring\n";
    my $super = "SUPER::$method";
    $result = $self->$super( @_ );
    #warn "*** result is " . Dumper $result;
    $CACHE->freeze( $cachestring, $result );
  } else {
    #warn "*** Reusing $cachestring";
  }
  return $result;
}

# Make sure not caught by AUTOLOAD
sub DESTROY {}

=head1 NAME

=cut

1;
