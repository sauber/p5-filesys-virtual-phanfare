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
    warn "*** Caching $cachestring\n";
    my $super = "SUPER::$method";
    $result = $self->$super( @_ );
    #warn "*** result is " . Dumper $result;
    $CACHE->freeze( $cachestring, $result );

    # Delete cached parent results when creating new objects
    # *** Caching NewAlbum,target_uid,9497612,album_name,Test2,album_start_date,1999-01-01T00:00:00,album_end_date,1999-12-31T23:59:59
    # *** Reusing GetAlbumList,target_uid,9497612
    my $parent;
    if ( $method eq 'NewAlbum' ) {
      $parent = join ',', 'GetAlbumList', @_[0..1];
    } elsif ( $method eq 'NewSection' ) {
      $parent = join ',', 'GetAlbum', @_[0..3];
    }
    if ( $parent ) {
      warn "*** Expiring $parent\n";
      $CACHE->remove( $parent );
      # Also take the opportunity to remove all expired objects
      # to reduce overall size of cache.
      # XXX: Need to happen regularly even when there are only Get requests.
      $CACHE->purge();
    }
  } else {
    warn "*** Reusing $cachestring\n";
  }
  return $result;
}

# Make sure not caught by AUTOLOAD
sub DESTROY {}

=head1 NAME

=cut

1;
