package WWW::Phanfare::Class::Site;
use Moose;
use MooseX::Method::Signatures;
use WWW::Phanfare::Class::Year;

#has extrayear => ( isa=>'HashRef[Int]', is=>'rw', default=>sub {{}} );

# List of years in start dates
#
method subnodelist {
  my $albumlist = $self->api->GetAlbumList(target_uid=>$self->uid)->{albums}{album};;
  #use Data::Dumper;
  my $years = $self->extranode;
  #warn "*** yearid extra years : " . Dumper $years;
  my %year = map { $_=>1 } keys %$years;
  #warn "*** yearid extra years : " . Dumper \%year;
  #my %year;
  for my $album ( @$albumlist ) {
    my $num = substr $album->{album_start_date}, 0, 4;
    ++$year{$num};
  }
  return keys %year;
}

method subnodetype { 'WWW::Phanfare::Class::Year' };
#method subnodelist { $self->yearid }
#method subnodemake ( Int $nodename ) { $self->subnodetype->new( nodename => $nodename ) }

method yearlist { $self->subnodelist }
method year ( Str $yearname ) { $self->getnode( $yearname ) }

# Create a year that does not yet have albums
#
#method create ( Int $nodename ) {
#  #my $years = $self->extranode();
#  # ++$years->{$nodename};
#  #use Data::Dumper;
#  warn "*** create extra years : $nodename\N";
#  #$self->extrayear( $years );
#  $self->extranode->{$nodename} = $self->buildnode( nodename => $nodename );
#}

# Delete year that has no albums
#
#method delete ( Int $nodename ) {
#  #use Data::Dumper;
#  my $years = $self->extrayear();
#  #warn "*** delete extra years : " . Dumper $years;
#  delete $years->{$nodename};
#  #warn "*** delete extra years : " . Dumper $years;
#  $self->extrayear( $years );
#}

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
