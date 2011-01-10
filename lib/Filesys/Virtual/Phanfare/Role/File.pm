package Filesys::Virtual::Phanfare::Role::File;
use Moose::Role;
use POSIX qw(ceil);

our $BLOCKSIZE = 1024;

#has 'uid' => ( is=>'ro', isa=>'Int', required=>1 );
#has 'gid' => ( is=>'ro', isa=>'Int', required=>1 );

sub _size {
  my $self = shift;
  if ( $self->can('size') ) {
    return $self->size;
  } elsif ( $self->can('value') ) {
    return length $self->value;
  } else {
    0
  }
}

sub stat {
  my $self = shift;
  #warn sprintf "*** stat $self size %s\n", $self->size;
  my @stat = (
    0 + $self,                  # dev
    42,         # ino
    0100444,                     # mode
    1,                          # nlink
    $self->uid,              # uid
    $self->gid,              # gid
    0,                          # rdev
    $self->_size                ,       # size
    $self->atime,                          # atime
    $self->mtime,                          # mtime
    $self->ctime,                       # ctime
    $BLOCKSIZE,                 # blksize
    ceil($self->_size/$BLOCKSIZE)                           # blocks
  );

  #if ( $self->nodename =~ /\..txt/ ) {
  #  use Data::Dumper;
  #  warn sprintf "*** stat %s: %s", $self->nodename, Dumper \@stat;
  #}
  return @stat;
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

  return 1 if $testname =~ /[rRe]/;     # Readable by all and exists
  return 0 if $testname =~ /[wxoWXO]/;  # No write, execute or owned
  #return 0 if $testname =~ /[z]/;       # Not zero size XXX
  #return 1 if $testname =~ /[s]/;       # size of file XXX
  return 1 if $testname =~ /[f]/;       # It's a file
  return 0 if $testname =~ /[dlpSbct]/; # Not any other type
  return 0 if $testname =~ /[ugk]/;     # setuid/setgid/sticky bit
  #return 0 if $testname =~ /[T]/;       # Textfile XXX
  #return 1 if $testname =~ /[B]/;       # Binary XXX
  return 0 if $testname =~ /[MAC]/;     # Age XXX

  return $self->size if $testname =~ /[s]/;
  return ( $self->size ? 0 : 1 ) if $testname =~ /[z]/;
  return ( ref($self)=~/Attribute/ ? 1 : 0 ) if $testname =~ /[T]/; # Textfile
  return ( ref($self)=~/Attribute/ ? 0 : 1 ) if $testname =~ /[B]/; # Binary
}

# Get content of file
sub open_read {
  my $self = shift;

  my $class = 'WWW::Phanfare::Class::';
  my $content = '';
  if ( $self->isa($class . "Attribute" ) ) {
    $content = $self->value;
  } elsif ( $self->isa($class . "Image" ) ) {
    if ( $self->parent->nodename eq 'Caption' ) {
      $content = $self->caption;
    } else {
      #warn sprintf "*** Fetching %s\n", $self->url;
      $content = $self->api->geturl( $self->url );
      #warn sprintf "*** Fetched image size is %s\n", length $content;
      $self->size( length $content );
    }
  }
  #$content .= "\n";
  #warn sprintf "*** Content size is %s\n", length $content;
  open( my $fh, '<', \$content );
  #warn "*** create file handler $fh\n";
  return $fh;
}


with 'Filesys::Virtual::Phanfare::Role::Node';

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
