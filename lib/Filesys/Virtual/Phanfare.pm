package Filesys::Virtual::Phanfare;

use warnings;
use strict;
use Carp;
use WWW::Phanfare::API;
use base qw( Filesys::Virtual );

=head1 NAME

Filesys::Virtual::Phanfare - Virtual Filesystem for Phanfare library

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

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

=head2 new

Initialize new virtual filesystem

=cut

sub new {
  my $that  = shift;
  my %args = @_;

  my $class = ref($that) || $that;
  my $self = {};
  bless $self, $class;

  # Create new Phanfare API agent
  my $agent;
  if ( $args{api_key} and $args{private_key} ) {
    $agent = WWW::Phanfare::API->new(
      api_key     => $args{api_key},
      private_key => $args{private_key},
    );
  } else {
    croak "api_key and private_key are required for Phanfare API";
  }
  $self->{_phanfare} = $agent;

  # Authenticate as user or guest
  if ( $args{email_address} and $args{password} ) {
    my $session = $agent->Authenticate(
      email_address => $args{email_address},
      password      => $args{password},
    );
    $self->{_target_uid} = $session->{session}{uid};
  } else {
    $agent->AuthenticateGuest();
  }

  return $self;
}

=head2 list

Directory listing.

=cut

sub list {
  my $self = shift;
  my $path = $self->_path_from_root( shift );

  return 'library';
}

=head2 function2

=cut

sub function2 {
}

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

1; # End of Filesys::Virtual::Phanfare
