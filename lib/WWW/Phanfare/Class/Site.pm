package WWW::Phanfare::Class::Site;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Year;

# List of years in start dates
#
method _idnames {
  my $albumlist = $self->api->GetAlbumList(target_uid=>$self->uid)->{albums}{album};;
  $albumlist = [ $albumlist ] unless ref $albumlist eq 'ARRAY';

  # List year only once
  my %year;
  for my $album ( @$albumlist ) {
    my $num = substr $album->{album_start_date}, 0, 4;
    ++$year{$num};
  }
  return [ map {{ id=>$_, name=>$_ }} keys %year ];
}

sub childclass { 'WWW::Phanfare::Class::Year' };

with 'WWW::Phanfare::Class::Role::Branch';

=head1 NAME

WWW::Phanfare::Class::Site - Site Node

=head1 SUBROUTINES/METHODS

=head2 subnodetype

Class type of sub nodes.

=head2 subnodelist

Names of subnodes.

=head1 SEE ALSO

L<WWW::Phanfare::Class>

=cut
