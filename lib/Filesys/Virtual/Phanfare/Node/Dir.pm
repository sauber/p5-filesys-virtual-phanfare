package Filesys::Virtual::Phanfare::Node::Dir;
use Moose::Role;

our $BLOCKSIZE = 1024;

requires 'size';
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

1;
