package Filesys::Virtual::Phanfare::Node::File;
use Moose::Role;
use POSIX qw(ceil);

our $BLOCKSIZE = 1024;

requires 'size';
#requires 'uid';
#requires 'gid';

sub stat {
  my $self = shift;
  return (
    0 + $self,                  # dev
    42,         # ino
    0100444,                     # mode
    1,                          # nlink
    0,              # uid
    0,              # gid
    0,                          # rdev
    1024                ,       # size
    0,                          # atime
    0,                          # mtime
    time,                       # ctime
    $BLOCKSIZE,                 # blksize
    ceil($self->size/$BLOCKSIZE)                           # blocks
  );
}

=head1 NAME

Filesys::Virtual::Phanfare::Node::Account - File Node

=head1 SUBROUTINES/METHODS
  
=head2 new
    
Create object

=head2 stat

posix stat values for a file.

=head1 SEE ALSO

L<Filesys::Virtual::Phanfare>

=cut


1;
