package Filesys::Virtual::Phanfare;

use warnings;
use strict;
#use POSIX qw(ceil);
#use Carp;
#use WWW::Phanfare::API;
use WWW::Phanfare::Class;
use Filesys::Virtual::Plain;
#use base qw( Filesys::Virtual Class::Accessor::Fast );
use base qw( Filesys::Virtual Moose::Object );
#__PACKAGE__->mk_accessors(qw( cwd root_path home_path host ));

use Moose;
use MooseX::Method::Signatures;
use Moose::Util qw( apply_all_roles does_role );
#use Filesys::Virtual::Phanfare::Node;

#extends 'Filesys::Virtual';

has 'cwd' => ( is => 'rw', isa => 'Str', default => '/' );
has 'root_path' => ( is => 'ro', isa => 'Str', default => '' );
has 'home_path' => ( is => 'ro', isa => 'Str', default => '/' );
#has 'host' => ( is => 'ro' );
has 'api_key' => ( is => 'ro', required=>1 );
has 'private_key' => ( is => 'ro', required=>1 );
has 'email_address' => ( is => 'ro' );
has 'password' => ( is => 'ro' );

has 'phanfare' => ( isa=>'WWW::Phanfare::Class', is=>'ro', required=>1, lazy_build => 1 );
sub _build_phanfare {
  my $self = shift;

  return WWW::Phanfare::Class->new(
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
#our $BLOCKSIZE = 1024;
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

# Identify Phanfare node that matches path
#
method phnode ( Str $path ) {
  my($account,$site,$album,$section,$rendition,$image) = split '/', $path;

  return $self->phanfare->image    ($album,$section,$rendition,$image)
                                                                if $image;
  return $self->phanfare->rendition($album,$section,$rendition) if $rendition;
  return $self->phanfare->section  ($album,$section           ) if $section;
  return $self->phanfare->album    ($album                    ) if $album;
  return $self->phanfare->site     ($site                     ) if $site;
  return $self->phanfare->account;
}

# Convert a phanfare node to a filesystem node
# ie. add inode and fs operations
# XXX: Seriously messy below. Need cleanup.
#
method old_fsnode ( Str $path, Ref $phnode ) {
  my $type = 'Filesys::Virtual::Phanfare::Node';
  for my $nodetype (qw(Account Site Album Section Rendition Image Attribute)){
    $type .= "::$nodetype" if $phnode ~~ /$nodetype/;
  }

  my $gid = $self->phanfare->account->attribute('public_group_id')->value;
  #warn "*** gid for $path is $gid\n";
  my $uid = $self->phanfare->account->attribute('uid')->value;
  #warn "*** uid for $path is $uid\n";
  
  # XXX: Keep a cache of already created fsnodes
  #      to make sure same fsnode always uses same inode
  my $node = $type->new(
    uid      => $uid,
    gid      => $gid,
    parent   => $phnode->parent,
    nodename => $phnode->nodename,
  );

  #warn "*** new node created: " .Dumper $node;

  if ( $type =~ /Account/ ) {
    # Clone and convert
    #warn "*** fsnode $phnode clone and converting...\n";
    #warn "***   via $node...\n";
    my $phnode2 = $phnode->meta->clone_object($phnode);
    $node->meta->rebless_instance($phnode2);
    $phnode = $phnode2;
    #warn "***   to $phnode\n";
  } else {
    # Convert phanfare object to fs object
    # Although uid/gid was given at $node init, it needs to be here again
    #warn "*** fsnode $phnode converting...\n";
    #warn "***   via $node...\n";
    $node->meta->rebless_instance($phnode, uid=>$uid, gid=>$gid);
    #warn "***   to $phnode\n";
  }
  return $phnode;
}

method fsnode ( Str $path, Ref $phnode ) {
  #warn sprintf "*** $phnode uid is %s", $phnode->uid;
  if ( does_role($phnode, 'WWW::Phanfare::Class::Role::Leaf') ) {
    if ( does_role($phnode, 'Filesys::Virtual::Phanfare::Role::File') ) {
      warn "*** Already applied File role to $phnode\n";
    } else {
      warn "*** Applying File role to $phnode\n";
      apply_all_roles( $phnode, 'Filesys::Virtual::Phanfare::Role::File' );
     }
  } else {
    if ( does_role($phnode, 'Filesys::Virtual::Phanfare::Role::Dir') ) {
      warn "*** Already applied Dir role to $phnode\n";
    } else {
      if ( $phnode =~ /Account/ ) {
        warn "*** Applying Top role to $phnode\n";
        apply_all_roles( $phnode, 'Filesys::Virtual::Phanfare::Role::Top' );
        my $gid = $self->phanfare->account->attribute('public_group_id')->value;
        $phnode->gid( $gid );
      } else {
        warn "*** Applying Dir role to $phnode\n";
        apply_all_roles( $phnode, 'Filesys::Virtual::Phanfare::Role::Dir' );
      }
    }
  }
  return $phnode;
}

# Is requested file op on account, site, album, section, rendition or image?
# Run file operation on node
#
method opnode ( Str $operation, Str $path, ArrayRef $args ) {
  unless ( length $operation ) {
    return warn "*** fsop NOOP $path @$args\n";
  }
  my $fullpath  = $self->_path_from_root( $path );
  #warn "*** Lookup node for $fullpath\n";
  my $node = $self->fsnode( $fullpath, $self->phnode($fullpath) );
  #warn "***   found $node...\n";
  # Perform the operation if node exists and has the capability
  if ( $node ) {
    if ( $node->can($operation) ) {
      warn "*** fsop $operation $node @$args\n";
      #return $node->$operation(@$args) if $node and $node->can($operation);
      if ( $node and $node->can($operation) ) {
        my @result = $node->$operation(@$args);
        warn "*** result is @result\n";
        return @result;
      }
    } else {
      warn "*** fsop $operation $node @$args not implemented\n";
    }
  } else {
    warn "*** fsop $operation $path does not exist\n";
  }
  return undef;
}

=head2 File operations

Implemented functions, partially, or not at all

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

package Filesys::Virtual::Phanfare::Node::Account;
use Moose;
extends 'WWW::Phanfare::Class::Account';
with 'Filesys::Virtual::Phanfare::Role::Dir';
sub subnodetype { 'Filesys::Virtual::Phanfare::Node::Site' }

package Filesys::Virtual::Phanfare::Node::Site;
use Moose;
extends 'WWW::Phanfare::Class::Site';
with 'Filesys::Virtual::Phanfare::Role::Dir';
sub subnodetype { 'Filesys::Virtual::Phanfare::Node::Album' }

package Filesys::Virtual::Phanfare::Node::Album;
use Moose;
extends 'WWW::Phanfare::Class::Album';
with 'Filesys::Virtual::Phanfare::Role::Dir';
sub subnodetype { 'Filesys::Virtual::Phanfare::Node::Section' }

package Filesys::Virtual::Phanfare::Node::Section;
use Moose;
extends 'WWW::Phanfare::Class::Section';
with 'Filesys::Virtual::Phanfare::Role::Dir';
sub subnodetype { 'Filesys::Virtual::Phanfare::Node::Rendition' }

package Filesys::Virtual::Phanfare::Node::Rendition;
use Moose;
extends 'WWW::Phanfare::Class::Rendition';
with 'Filesys::Virtual::Phanfare::Role::Dir';
sub subnodetype { 'Filesys::Virtual::Phanfare::Node::Image' }

package Filesys::Virtual::Phanfare::Node::Image;
use Moose;
extends 'WWW::Phanfare::Class::Image';
with 'Filesys::Virtual::Phanfare::Role::File';

package Filesys::Virtual::Phanfare::Node::Attribute;
use Moose;
extends 'WWW::Phanfare::Class::Attribute';
with 'Filesys::Virtual::Phanfare::Role::File';

1; # End of Filesys::Virtual::Phanfare

