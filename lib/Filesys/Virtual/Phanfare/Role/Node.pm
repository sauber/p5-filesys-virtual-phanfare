package Filesys::Virtual::Phanfare::Role::Node;

use Moose::Role;
use MooseX::Method::Signatures;
use Class::MOP;

# Inode number is $self converted to integer
has inode => ( is=>'ro', isa=>'Int', lazy_build=>1 );
method _build_inode { return 0+$self }

# Files/Dirs need gid
method gid { $self->parent->gid }

#has parent => ( is=>'ro', isa=>'Any' );

#with 'WWW::Phanfare::Class::Role::Node';

=head1 DESCRIPTION

Extends Phanfare Class Node role with an inode.

=cut

1;
