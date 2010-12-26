package Filesys::Virtual::Phanfare::Node::File;
use Moose::Role;
use POSIX qw(ceil);

our $BLOCKSIZE = 1024;

has 'uid' => ( is=>'ro', isa=>'Int', required=>1 );
has 'gid' => ( is=>'ro', isa=>'Int', required=>1 );

sub size {
  my $self = shift;
  length $self->value;
}

sub stat {
  my $self = shift;
  #warn "*** stat $self\n";
  return (
    0 + $self,                  # dev
    42,         # ino
    "0100444",                     # mode
    1,                          # nlink
    $self->uid,              # uid
    $self->gid,              # gid
    0,                          # rdev
    $self->size                ,       # size
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

=head2 size

Calculate size of file.

=head1 SEE ALSO

L<Filesys::Virtual::Phanfare>

=cut


1;
