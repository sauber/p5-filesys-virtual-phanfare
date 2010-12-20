package Filesys::Virtual::Phanfare;

use warnings;
use strict;
use POSIX qw(ceil);
use Carp;
use WWW::Phanfare::API;
use Filesys::Virtual::Plain;
use base qw( Filesys::Virtual Class::Accessor::Fast );
__PACKAGE__->mk_accessors(qw( cwd root_path home_path host ));

=head1 NAME

Filesys::Virtual::Phanfare - Virtual Filesystem for Phanfare library

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our $BLOCKSIZE = 1024;
our $AUTOLOAD;

sub AUTOLOAD {
  my $self = shift;

  my $field = $AUTOLOAD;
  $field =~ s/.*:://;
	
  return if $field eq 'DESTROY';

  croak("No such property or method '$AUTOLOAD'");
}


=head1 SYNOPSIS

File access to photos and videos in Phanfare library.

    use Filesys::Virtual::Phanfare;

    my $fs = Filesys::Virtual::Phanfare->new(
      api_key       => 'xxx',
      private_key   => 'yyy',
      email_address => 'my@email',
      password      => 'zzz',
    );

    my @files = $fs->list("/");

=head1 SUBROUTINES/METHODS

=head2 x

debug

=cut

sub x {
 use Data::Dumper;
 warn Data::Dumper->Dump([$_[1]], ["*** $_[0]"]);
}

=head2 new

Initialize new virtual filesystem

=cut

# HACKY - mixin these from the ::Plain class, they only deal with the
# mapping of root_path, cwd, and home_path, so they should be safe
#
*_path_from_root = \&Filesys::Virtual::Plain::_path_from_root;
*_resolve_path   = \&Filesys::Virtual::Plain::_resolve_path;

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
  $self->{_phanfare} = $agent;

  # Authenticate as user or guest
  if ( $args{email_address} and $args{password} ) {
    my $session = $agent->Authenticate(
      email_address => $args{email_address},
      password      => $args{password},
    );
    $self->{_uid} = $session->{session}{uid};
    $self->{_gid} = $session->{session}{public_group_id};
    $self->{_top} = $session->{session};
  } else {
    $agent->AuthenticateGuest();
  }

  return $self;
}

########################################################################
### General
########################################################################

# Standard file stat values
#
sub _filestat {
  my $self = shift;
  my $file = shift;

  my $size = $file ? length($file) : 0;
  return (
    0 + $self,			# dev
    int(rand 8**4),		# ino
    0100444,			# mode
    1,				# nlink
    $self->{_uid},		# uid
    $self->{_gid},		# gid
    0,				# rdev
    $size,			# size
    0,				# atime
    0,				# mtime
    time,			# ctime
    $BLOCKSIZE,			# blksize
    ceil($size/$BLOCKSIZE),	# blocks
  );

}

# Standard dir stat values
#
sub _dirstat {
  my $self = shift;
  my $dir = shift;

  return (
    0 + $self,			# dev
    42,		# ino
    042555,			# mode
    1,				# nlink
    $self->{_uid},		# uid
    $self->{_gid},		# gid
    0,				# rdev
    1024		,	# size
    0,				# atime
    0,				# mtime
    time,			# ctime
    $BLOCKSIZE,			# blksize
    1				# blocks
  );
}



########################################################################
### Site List
########################################################################

# Get list of sites available (dirs) and properties (values)
#
sub _sitelist {
  my $self = shift;

  # Site name and all site properties
  my %dir = (
    $self->{_top}{primary_site_name} => [],
    map {( $_ => $self->{_top}{$_} )}
    grep { ! ref $self->{_top}{$_} }
    keys %{$self->{_top}}
  );
  #x '_sitelist', \%dir;
  return %dir;
}

=head2 list

Directory listing.

=cut

sub list {
  my $self = shift;
  my $path = $self->_path_from_root( shift );

  warn "*** list path: $path\n";
  my($top,$site,$album,$section,$rendition,$image) = split '/', $path;

  if ( $image ) {
  } elsif ( $rendition ) {
  } elsif ( $section ) {
  } elsif ( $album ) {
  } elsif ( $site ) {
  } else {
    my %dir = $self->_sitelist;
    #x 'list', \%dir;
    return ".", keys %dir;
  }
}

=head2 stat

File stat

=cut

sub stat {
  my $self = shift;
  my $path = $self->_path_from_root( shift );
  warn "*** stat path: $path\n";
  my($top,$site,$album,$section,$rendition,$image) = split '/', $path;
  if ( $image ) {
  } elsif ( $rendition ) {
  } elsif ( $section ) {
  } elsif ( $album ) {
  } elsif ( $site ) {
    my %node = $self->_sitelist;
    return unless $node{$site};
    if ( ref $node{$site} ) {
      return $self->_dirstat;
    } else {
      return $self->_filestat($node{$site});
    }
  } else {
    return $self->_dirstat;
  }
  return;
}

=head2 open_read

Open a file for reading

=cut

sub open_read {
  my $self = shift;
  my $path = $self->_path_from_root( shift );
  warn "*** open_read path: $path\n";
  my($top,$site,$album,$section,$rendition,$image) = split '/', $path;
  if ( $image ) {
  } elsif ( $rendition ) {
  } elsif ( $section ) {
  } elsif ( $album ) {
  } elsif ( $site ) {
    my %node = $self->_sitelist;
    return unless $node{$site};
    if ( not ref $node{$site} ) {
      my $content = $node{$site} . "\n";
      open( my $fh, '<', \$content );
      warn "*** create file hander $fh\n";
      return $fh;
    }
  } else {
  }
  return;
}


=head2 close_read

File close

=cut

sub close_read {
  my $self = shift;
  my ($fh) = @_;
  warn "*** close_read fh: $fh\n";
  return close $fh;
}

=head2 test

File test

=cut

sub test {
  my $self = shift;
  my $test = shift;

  return 1;
}

=head1 AUTHOR

Soren Dossing, C<< <netcom at sauber.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-filesys-virtual-phanfare at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Filesys-Virtual-Phanfare>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Filesys::Virtual::Phanfare


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Filesys-Virtual-Phanfare>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Filesys-Virtual-Phanfare>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Filesys-Virtual-Phanfare>

=item * Search CPAN

L<http://search.cpan.org/dist/Filesys-Virtual-Phanfare/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Soren Dossing.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Filesys::Virtual::Phanfare
