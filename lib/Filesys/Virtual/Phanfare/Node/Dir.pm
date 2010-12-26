package Filesys::Virtual::Phanfare::Node::Dir;
use Moose::Role;

our $BLOCKSIZE = 1024;

requires 'size';
requires 'getnode';
#requires 'uid';
##requires 'gid';

sub stat {
  my $self = shift;
  return (
    0 + $self,                  # dev
    42,         # ino
    042555,                     # mode
    1,                          # nlink
    0,              # uid
    0,              # gid
    0,                          # rdev
    1024                ,       # size
    0,                          # atime
    0,                          # mtime
    time,                       # ctime
    $BLOCKSIZE,                 # blksize
    ceil($self->size/$BLOCKSIZE),     # blocks
  );
}

=head1 NAME

Filesys::Virtual::Phanfare::Node::Dir - Dir Node

=head1 SUBROUTINES/METHODS
  
=head2 new
    
Create object

=head2 stat

posix stat values for a dir.

=head1 SEE ALSO

L<Filesys::Virtual::Phanfare>

=cut


1;
