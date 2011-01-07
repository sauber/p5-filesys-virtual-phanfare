package Filesys::Virtual::Phanfare::Role::Top;

use Moose::Role;
use MooseX::Method::Signatures;

# Inode number is $self converted to integer
#has inode => ( is=>'ro', isa=>'Int', lazy_build=>1 );
#method _build_inode { return 0+$self }

# Files/Dirs need gid
#method gid { $self->parent->gid }
has gid => ( is=>'rw', isa=>'Int' );

#has parent => ( is=>'ro', isa=>'Any' );

with 'Filesys::Virtual::Phanfare::Role::Dir';

=head1 DESCRIPTION

Extends Phanfare Class Node role with an inode.

=cut

1;
