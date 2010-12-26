package Filesys::Virtual::Phanfare;

use warnings;
use strict;
use POSIX qw(ceil);
use Carp;
#use WWW::Phanfare::API;
use Filesys::Virtual::Phanfare::Node::Account;
use Filesys::Virtual::Plain;
#use base qw( Filesys::Virtual Class::Accessor::Fast );
use base qw( Filesys::Virtual Moose::Object );
#__PACKAGE__->mk_accessors(qw( cwd root_path home_path host ));

use Moose;
use MooseX::Method::Signatures;

#extends 'Filesys::Virtual';

has 'cwd' => ( is => 'rw', isa => 'Str', default => '/' );
has 'root_path' => ( is => 'ro', isa => 'Str', default => '' );
has 'home_path' => ( is => 'ro', isa => 'Str', default => '/' );
#has 'host' => ( is => 'ro' );
has 'api_key' => ( is => 'ro' );
has 'private_key' => ( is => 'ro' );
has 'email_address' => ( is => 'ro' );
has 'password' => ( is => 'ro' );
has 'account' => ( isa=>'Filesys::Virtual::Phanfare::Node::Account', is=>'ro', lazy_build => 1 );
sub _build_account {
  my $self = shift;

  return Filesys::Virtual::Phanfare::Node::Account->new(
    api_key       => $self->api_key,
    private_key   => $self->private_key,
    email_address => $self->email_address,
    password      => $self->password,
  );
  # XXX: clear password
}

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

=head2 list

Directory listing.

=cut

sub list {
  my $self = shift;
  my $patharg = shift;
  my $path = $self->_path_from_root( $patharg );

  #warn sprintf "*** list patharg  : %s\n", $patharg;
  #warn sprintf "*** list path     : %s\n", $path;
  #warn sprintf "*** list root_path: %s\n", $self->root_path;
  #warn sprintf "*** list home_path: %s\n", $self->home_path;
  #warn sprintf "*** list cwd      : %s\n", $self->cwd;
  #warn sprintf "*** list resolve  : %s\n", $self->_resolve_path($patharg);
  #warn "*** list path: $path\n";
  my($top,$site,$album,$section,$rendition,$image) = split '/', $path;

  if ( $image ) {
  } elsif ( $rendition ) {
  } elsif ( $section ) {
  } elsif ( $album ) {
  } elsif ( $site ) {
    #my %dir = $self->_albumlist;
    #return ".", "..", keys %dir;
  } else {
    #my %dir = $self->account->list;
    #x 'list', \%dir;
    #return ".", keys %dir;
    return $self->account->list;
  }
}

=head2 stat

File stat

=cut

sub stat {
  my $self = shift;
  my $path = $self->_path_from_root( shift );
  #warn "*** stat path: $path\n";
  my($top,$site,$album,$section,$rendition,$image) = split '/', $path;
  if ( $image ) {
  } elsif ( $rendition ) {
  } elsif ( $section ) {
  } elsif ( $album ) {
    #my %node = $self->_albumlist;
    #return unless $node{$album};
    #return $self->_dirstat;
  } elsif ( $site ) {
    #my %node = $self->_sitelist;
    #return unless $node{$site};
    #if ( ref $node{$site} ) {
    #  return $self->_dirstat;
    #} else {
    #  return $self->_filestat($node{$site});
    #}
    return $self->account->getnode($site)->stat;
  } else {
    return $self->account->stat;
  }
  return;
}

#=head2 open_read
#
#Open a file for reading
#
#=cut
#
#sub open_read {
#  my $self = shift;
#  my $path = $self->_path_from_root( shift );
#  warn "*** open_read path: $path\n";
#  my($top,$site,$album,$section,$rendition,$image) = split '/', $path;
#  if ( $image ) {
#  } elsif ( $rendition ) {
#  } elsif ( $section ) {
#  } elsif ( $album ) {
#  } elsif ( $site ) {
#    my %node = $self->_sitelist;
#    return unless $node{$site};
#    if ( not ref $node{$site} ) {
#      my $content = $node{$site} . "\n";
#      open( my $fh, '<', \$content );
#      warn "*** create file hander $fh\n";
#      return $fh;
#    }
#  } else {
#  }
#  return;
#}


#=head2 close_read
#
#File close
#
#=cut
#
#sub close_read {
#  my $self = shift;
#  my ($fh) = @_;
#  warn "*** close_read fh: $fh\n";
#  return close $fh;
#}

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
