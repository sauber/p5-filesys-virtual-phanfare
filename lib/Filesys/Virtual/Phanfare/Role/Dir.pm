package Filesys::Virtual::Phanfare::Role::Dir;
use Moose::Role;
use POSIX qw(ceil);
use Devel::Size qw(size);

our $BLOCKSIZE = 1024;

requires 'getnode';
#has 'uid' => ( is=>'ro', isa=>'Int', required=>1 );
#has 'gid' => ( is=>'ro', isa=>'Int', required=>1 );

sub stat {
  my $self = shift;
  my $size = size($self);
  #my $size = 26565;
  #warn "*** stat $self size $size\n";
  return (
    0 + $self,                  # dev
    42,         # ino
    042755,                     # mode
    1,                          # nlink
    $self->uid,              # uid
    $self->gid,              # gid
    0,                          # rdev
    $size                ,       # size
    $self->atime,                          # atime
    $self->mtime,                          # mtime
    $self->ctime,                       # ctime
    $BLOCKSIZE,                 # blksize
    ceil($size/$BLOCKSIZE),     # blocks
  );
}

sub list {
  my $self = shift;
  return $self->nodelist();
}

#    -r  File is readable by effective uid/gid.
#    -w  File is writable by effective uid/gid.
#    -x  File is executable by effective uid/gid.
#    -o  File is owned by effective uid.

#    -R  File is readable by real uid/gid.
#    -W  File is writable by real uid/gid.
#    -X  File is executable by real uid/gid.
#    -O  File is owned by real uid.

#    -e  File exists.
#    -z  File has zero size.
#    -s  File has nonzero size (returns size).

#    -f  File is a plain file.
#    -d  File is a directory.
#    -l  File is a symbolic link.
#    -p  File is a named pipe (FIFO), or Filehandle is a pipe.
#    -S  File is a socket.
#    -b  File is a block special file.
#    -c  File is a character special file.
#    -t  Filehandle is opened to a tty.

#    -u  File has setuid bit set.
#    -g  File has setgid bit set.
#    -k  File has sticky bit set.

#    -T  File is a text file.
#    -B  File is a binary file (opposite of -T).

#    -M  Age of file in days when script started.
#    -A  Same for access time.
#    -C  Same for inode change time.

sub test {
  my $self = shift;
  my $testname = shift;

  #warn "*** Running test $testname on $self\n";

  return 1 if $testname =~ /[rRe]/;     # Readable by all and exists
  return 0 if $testname =~ /[wxoWXO]/;  # No write, execute or owned
  #return 0 if $testname =~ /[z]/;       # Not zero size XXX
  #return 1 if $testname =~ /[s]/;       # size of file XXX
  return 1 if $testname =~ /[d]/;       # It's a dir
  return 0 if $testname =~ /[flpSbct]/; # Not any other type
  return 0 if $testname =~ /[ugk]/;     # setuid/setgid/sticky bit
  return 0 if $testname =~ /[T]/;       # Textfile
  return 0 if $testname =~ /[B]/;       # Binary
  return 0 if $testname =~ /[MAC]/;     # Age XXX
  return $self->size if $testname =~ /[s]/;
  return ( $self->size ? 0 : 1 ) if $testname =~ /[z]/;
}

# Create a sub directory
#
sub mkdir {
  my $self = shift;
  my $dirname = shift;

  #my $class = 'WWW::Phanfare::Class::';
  #warn sprintf "*** Create in dir %s subdir %s\n", $self->nodename, $dirname;
  if ( $self->can('create') ) {
    $self->create($dirname);
    # XXX: Expire self and parent from cache to make results immediately visible
    return 1;
  } else {
    return undef;
  }
}

with 'Filesys::Virtual::Phanfare::Role::Node';

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
