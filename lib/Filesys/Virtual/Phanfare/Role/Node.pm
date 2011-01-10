package Filesys::Virtual::Phanfare::Role::Node;

use Moose::Role;
use MooseX::Method::Signatures;
use Date::Parse;

#require 'atime';
#require 'mtime';
#require 'ctime';
#require 'size';

# Inode number is $self converted to integer
#
has inode => ( is=>'ro', isa=>'Int', lazy_build=>1 );
method _build_inode { return 0+$self }

# Files/Dirs need gid
#
method gid { $self->parent->gid }

# Convert Phanfare time to unixtime
# Phanfare time is always UTC
#
sub phanfaretime {
  # 2011-01-04T06:55:25
  str2time shift, "UTC";
}

# Convert unix time to phanfare time
#
sub timephanfare {
  my @t = gmtime shift;
  sprintf "%04s-02%-%02sT%02s:%02s:%02",
     $t[5]+1900, $t[4]+1, $t[3],
     $t[2], $t[1], $t[0];
}

method atime { time }

method mtime {
  my $epoch = time;
  my $class = 'WWW::Phanfare::Class::';
  if ( $self->isa($class . 'Account') ) {
  } elsif ( $self->isa($class . 'Site') ) {
  } elsif ( $self->isa($class . 'Year') ) {
    $epoch = str2time sprintf "%04s-01-01T00:00:00", $self->nodename;
    #warn sprintf "*** mtime for year %s is %s\n", $self->nodename, $epoch;
  } elsif ( $self->isa($class . 'Album') ) {
    $epoch = phanfaretime $self->attribute('album_start_date')->value;
    #warn sprintf "*** mtime for album %s date %s is %s\n", $self->nodename, $self->attribute('album_start_date')->value, $epoch;
  } elsif ( $self->isa($class . 'Section') ) {
    $epoch = phanfaretime $self->parent->attribute('album_last_modified')->value;
  } elsif ( $self->isa($class . 'Rendition') ) {
    $epoch = phanfaretime $self->parent->parent->attribute('album_last_modified')->value;
  } elsif ( $self->isa($class . 'Image') ) {
    #$epoch = phanfaretime $self->parent->parent->parent->attribute('album_last_modified')->value;
    $epoch = phanfaretime $self->imageinfo->{image_date};
  }
  #warn "*** mtime for $self is $epoch\n";
  return $epoch;
}

method ctime {
  my $epoch = time;
  my $class = 'WWW::Phanfare::Class::';
  if ( $self->isa($class . 'Account') ) {
  } elsif ( $self->isa($class . 'Site') ) {
  } elsif ( $self->isa($class . 'Year') ) {
    $epoch = str2time sprintf "%04s-01-01T00:00:00", $self->nodename;
  } elsif ( $self->isa($class . 'Album') ) {
    $epoch = phanfaretime $self->attribute('album_creation_date')->value;
  } elsif ( $self->isa($class . 'Section') ) {
    $epoch = phanfaretime $self->parent->attribute('album_creation_date')->value;
  } elsif ( $self->isa($class . 'Rendition') ) {
    $epoch = phanfaretime $self->parent->parent->attribute('album_creation_date')->value;
  } elsif ( $self->isa($class . 'Image') ) {
    $epoch = phanfaretime $self->renditioninfo->{created_date};
  }
  #warn "*** ctime for $self is $epoch\n";
  return $epoch;
}



#has parent => ( is=>'ro', isa=>'Any' );

#with 'WWW::Phanfare::Class::Role::Node';

=head1 DESCRIPTION

Extends Phanfare Class Node role with an inode.

=cut

1;
