package Filesys::Virtual::Phanfare::Role::Dir;
use Moose::Role;
use POSIX qw(ceil);
use Devel::Size qw(size);

our $BLOCKSIZE = 1024;

requires 'getnode';
has 'uid' => ( is=>'ro', isa=>'Int', required=>1 );
has 'gid' => ( is=>'ro', isa=>'Int', required=>1 );

sub stat {
  my $self = shift;
  my $size = size($self);
  #my $size = 26565;
  #warn "*** stat $self size $size\n";
  return (
    0 + $self,                  # dev
    42,         # ino
    042555,                     # mode
    1,                          # nlink
    $self->uid,              # uid
    $self->gid,              # gid
    0,                          # rdev
    $size                ,       # size
    0,                          # atime
    0,                          # mtime
    time,                       # ctime
    $BLOCKSIZE,                 # blksize
    ceil($size/$BLOCKSIZE),     # blocks
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