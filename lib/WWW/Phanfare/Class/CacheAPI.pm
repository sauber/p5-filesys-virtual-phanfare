package WWW::Phanfare::Class::CacheAPI;
use Cache::Memory;
use Carp;
use Data::Dumper;

use base qw( WWW::Phanfare::API );
our $AUTOLOAD;

our $CACHE = Cache::Memory->new(
  namespace       => 'WWW::Phanfare::Class',
  default_expires => '30 sec',
);

sub geturl {
  my($self,$url,$post) = @_;

  my $cachestring = join ',', 'geturl', grep $_, $url, $post;
  my $result = $CACHE->get( $cachestring );
  unless ( $result ) {
    #warn "*** Caching $cachestring\n";
    my $super = "SUPER::geturl";
    $result = $self->$super( $url, $post );
    $CACHE->set( $cachestring, $result );
  } else {
    #warn "*** Reusing $cachestring\n";
  }
  return $result;
}

sub AUTOLOAD {
  my $self = shift;
  croak "$self is not an object" unless ref($self);

  my $method = $AUTOLOAD;
  $method =~ s/.*://;   # strip fully-qualified portion
  croak "method not defined" unless $method;

  # No caching at all
  my $super = "SUPER::$method";
  warn "*** calling $super @_\n";
  return $self->$super( @_ );

  $CACHE->purge();
  my $cachestring = join ',', $method, @_;
  my $result = $CACHE->thaw( $cachestring );
  unless ( $result ) {
    warn "*** cacheAPI Caching $cachestring\n";
    #warn "*** CacheAPI caching for $method\n";
    my $super = "SUPER::$method";
    $result = $self->$super( @_ );
    #warn "*** result is " . Dumper $result;
    #$CACHE->freeze( $cachestring, $result ) unless $method eq 'NewImage';
    #$CACHE->freeze( $cachestring, $result ) unless substr $method, 0, 3 eq 'New';

    # Delete cached parent results when creating/deleting objects
    # *** Caching NewAlbum,target_uid,9497612,album_name,Test2,album_start_date,1999-01-01T00:00:00,album_end_date,1999-12-31T23:59:59
    # *** Reusing GetAlbumList,target_uid,9497612
    my $parent;
    if ( $method eq 'NewAlbum' or $method eq 'DeleteAlbum' ) {
      $parent = join ',', 'GetAlbumList', @_[0..1];
    } elsif ( $method eq 'NewSection' or $method eq 'DeleteSection' ) {
      $parent = join ',', 'GetAlbum', @_[0..3];
    }
    if ( $parent ) {
      warn "*** CacheAPI Expiring $parent\n";
      $CACHE->remove( $parent );
      # Also take the opportunity to remove all expired objects
      # to reduce overall size of cache.
      # XXX: Need to happen regularly even when there are only Get requests.
      $CACHE->purge();
    }
  } else {
    warn "*** CacheAPI Reusing $cachestring\n";
    #warn "*** CacheAPI reusing cache for $method\n";
  }
  return $result;
}

# Make sure not caught by AUTOLOAD
sub DESTROY {}

=head1 NAME

=head1 SUBROUTINES/METHODS

=head2 geturl

Cache results of direct url fetch method.

=cut

1;
