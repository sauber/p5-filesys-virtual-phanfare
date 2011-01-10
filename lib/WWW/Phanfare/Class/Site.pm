package WWW::Phanfare::Class::Site;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Year;

has extrayear => ( isa=>'HashRef[Int]', is=>'rw', default=>sub {{}} );

# List of years in start dates
#
method yearid {
  my $albumlist = $self->api->GetAlbumList(target_uid=>$self->uid)->{albums}{album};;
  #use Data::Dumper;
  my $years = $self->extrayear();
  #warn "*** yearid extra years : " . Dumper $years;
  my %year = map { $_=>1 } keys %$years;
  #warn "*** yearid extra years : " . Dumper \%year;
  for my $album ( @$albumlist ) {
    my $num = substr $album->{album_start_date}, 0, 4;
    ++$year{$num};
  }
  return keys %year;
}

method subnodetype { 'WWW::Phanfare::Class::Year' };
method subnodelist { $self->yearid }

method yearlist { $self->subnodelist }
method year ( Str $yearname ) { $self->getnode( $yearname ) }

method create ( Int $nodename ) {
  my $years = $self->extrayear();
  ++$years->{$nodename};
  #use Data::Dumper;
  #warn "*** create extra years : " . Dumper $years;
  $self->extrayear( $years );
}

method delete ( Int $nodename ) {
  #use Data::Dumper;
  my $years = $self->extrayear();
  #warn "*** delete extra years : " . Dumper $years;
  delete $years->{$nodename};
  #warn "*** delete extra years : " . Dumper $years;
  $self->extrayear( $years );
}

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
