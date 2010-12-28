package WWW::Phanfare::Class::Site;
use Moose;
use MooseX::Method::Signatures;
#use WWW::Phanfare::API;
#use Carp;
#use Filesys::Virtual::Phanfare::Node::Album;

#has 'uid'      => ( is=>'rw', isa=>'Int', required=>1 );
#has 'gid'      => ( is=>'rw', isa=>'Int', required=>1 );
#has '_agent'   => ( is=>'ro', isa=>'WWW::Phanfare::API', required=>1 );
#has 'albumlist' => ( is=>'ro', isa=>'ArrayRef', lazy_build=>1 );

# List of available sites
#sub _build_albumlist {
#  my $self = shift;
#
#  #my $sitename = $self->attribute('primary_site_name')->value;
#  my $albumlist = $self->{_agent}->GetAlbumList(target_uid=>$self->{uid});
#  return [ 
#    map "$_->{album_name}.$_->{album_id}",
#    @{ $albumlist->{albums}{album} }
#  ];
#}

# Size of account dir
#method size {
  # XXX: something more reasonable...
#  int rand 1024*64;
#}

# And attribute or a site
#method getnode ( Str $nodename ) {
#  if ( grep $nodename, $self->attributelist ) {
#    return $self->attribute( $nodename );
#  #} elsif ( grep $nodename, @{ $self->sitelist } ) {
#  #  $self->{_site}{$nodename} ||= Filesys::Virtual::Phanfare::Node::Site->new(
#  #    sitename => $nodename
#  #  );
#  #  return $self->{_site}{$nodename};
#  } else {
#    return undef;
#  }
#}

# List of sites and properties
#
#method list {
#  return (
#    @{ $self->albumlist },
#    keys %{ $self->attributes }
#  );
#}

method subnodetype { 'WWW::Phanfare::Class::Album' };
method subnodelist { 'Sample: Skiing' };
with 'WWW::Phanfare::Class::Role::Branch';
with 'WWW::Phanfare::Class::Role::Attributes';

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
