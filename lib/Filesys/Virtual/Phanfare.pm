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

# Is requested file op on account, site, album, section, rendition or image?
# Run file operation on node
#
method opnode ( Str $operation, Str $path, ArrayRef $args ) {
  my $pathfromroot = $self->_path_from_root( $path );
  my($account,$site,$album,$section,$rendition,$image)
    = split '/', $pathfromroot;

  # Determine which node to do operation on
  my $node;
  if ( $image ) {
    $node = $self->account->getnode($site)->getnode($album)->getnode($section)->getnode->($rendition)->getnode($image);
  } elsif ( $rendition ) {
    $node = $self->account->getnode($site)->getnode($album)->getnode($section)->getnode->($rendition);
  } elsif ( $section ) {
    $node = $self->account->getnode($site)->getnode($album)->getnode($section);
  } elsif ( $album ) {
    $node = $self->account->getnode($site)->getnode($album);
  } elsif ( $site ) {
    $node = $self->account->getnode($site);
  } else {
    $node = $self->account;
  }

  # Perform the operation if node exists and has the capability
  if ( $node ) {
    if ( $node->can($operation) ) {
      #warn "fsop $operation $node @$args\n";
      return $node->$operation(@$args) if $node and $node->can($operation);
    } else {
      #warn "fsop $node $node @$args not implemented\n";
    }
  } else {
    #warn "fsop $operation $path does not exist\n";
  }
  return undef;
}

=head2 File operations

Implemented functions

=over

=item modtime

=item size

=item delete

=item mkdir

=item rmdir

=item list

=item list_details

=item stat

=item test

=item open_read

=item close_read

=item open_write

=item close_write

=back

=cut

sub modtime      { shift->opnode('modtime',      shift, [     ]) }
sub size         { shift->opnode('size',         shift, [     ]) }
sub delete       { shift->opnode('delete',       shift, [     ]) }
sub mkdir        { shift->opnode('mkdir',        shift, [shift]) }
sub rmdir        { shift->opnode('rmdir',        shift, [     ]) }
sub list         { shift->opnode('list',         shift, [     ]) }
sub list_details { shift->opnode('list_details', shift, [     ]) }
sub stat         { shift->opnode('stat',         shift, [     ]) }
sub test         { shift->opnode('test',         pop  , [shift]) }
sub open_read    { shift->opnode('open_read',    shift, [ @_  ]) }
#sub close_read   { shift->opnode('close_read',   shift, [     ]) }
sub close_read   { close shift }
sub open_write   { shift->opnode('open_write',   shift, [shift]) }
#sub close_write  { shift->opnode('close_write',  shift, [     ]) }
sub close_write  { close shift }

#=head2 test
#
#File test
#
#=cut
#
#sub test {
#  my $self = shift;
#  my $test = shift;
#
#  return 1;
#}

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
