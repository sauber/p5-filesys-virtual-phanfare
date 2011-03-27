package WWW::Phanfare::Class::Role::Branch;
use Moose::Role;
use MooseX::Method::Signatures;

requires 'subnodetype';
requires 'subnodelist';

# Operations on a tree, manage itself and subnodes with CRUD type methods
#   create - Create a node
#     new - create this node
#     build - node already on phanfare
#     add - node not yet on phanfare, upload immediately or store as temp
#   read - List available nodes
#     get - list attributes for this node
#     list - nodes already on phanfare
#     pending - nodes not yet on phanfare
#   update - Change attributes
#     set - set attributes for this node
#     ... - nodes on phanfare
#     ... - nodes not on phanfare
#   delete - remove node
#     ... - delete this node
#     remove - remove from phanfare
#     cancel - remove from extranode
#   

# List of new subnodes created locally and not yet uploaded
# This only applies to:
#   Year, because years are properties of albums
#   Image, because they can be appended to until complete
has extranode => ( isa=>'HashRef', is=>'rw', default=>sub {{}} );

# List of extranode names
#
method pending { keys %{ $self->extranode } }

# Delete an extranode
#
method cancel ( Str $nodename ) { delete $self->extranode->{$nodename} }

# Create a named subnode
#
method buildnode ( Str $nodename ) {
  my $type = $self->subnodetype;
  my $node = $type->new( parent => $self, nodename=>$nodename );
  # XXX: Should use subnodemake instead
  #my $node = $self->subnodemake( nodename=>$nodename );

  # Add to list of temporary nodes, if it does not exist yet
  my @existingnodes = ( $self->subnodelist, keys %{ $self->extranode } );
  #use Data::Dumper;
  #warn "*** buildnode Creating node $nodename in ". $self->nodename ."\n";
  #warn "*** buildnode subnodelist: " . Dumper [ $self->subnodelist ];
  #warn "*** buildnode extranode: " . Dumper [ keys %{ $self->extranode } ];
  #warn "*** buildnode existingnodes: " . Dumper \@existingnodes;
  unless ( grep $_ eq $nodename, $self->subnodelist, keys %{ $self->extranode } ) {
    #warn "*** buildnode Creating temp node $nodename in ". $self->nodename ."\n";
    $self->extranode->{$nodename} = $node;
    #use Data::Dumper;
    #warn "*** buildnode extranode". Dumper $self->extranode;
  }

  return $node;
}

sub create { shift->buildnode( @_ ) }

# Delete an extranode
# XXX: If node is not an extranode, then delete data recursively in agent
method delete ( Str $nodename ) {
  delete $self->extranode->{$nodename};
}

method subnodemake ( Str $nodename, HashRef $args? ) {
  $self->subnodetype->new( nodename => $nodename, parent=>$self, %$args );
  #my $type = $self->subnodetype;
  #my $node = $type->new( parent=>$self, nodename=>$nodename );
  #return $node;
}

#method getnode ( Str $nodename ) { $self->buildnode( $nodename ) }

# Extract id=>name pairs from a data structure
#
method idnamepair ( Ref $data, Str $label, HashRef $filter? ) {
  # If data only has one element we get a hashref. Convert it to array.
  $data = [ $data ] unless 'ARRAY' eq ref $data; 
  my($key,$value) = each %$filter if $filter;
  #warn "*** Use filter $key=$value\n";
  # Pairs of id=>name
  map { $_->{"${label}_id"} => $_->{"${label}_name"} }
    grep {
      if ( $key and $value and $_->{$key} ) {
        1 if $_->{$key} =~ /^$value/;
      } else {
        1
      }
    }
    @$data;
}

# Get list of names from hashref.
# If multiple ID's have same name, then append ID
#
method idnamestrings ( HashRef $data ) {
  my %names;
  while ( my($id,$name) = each %$data ) {
    push @{ $names{$name} }, $id;
  }
  my @namestrings;
  while ( my($name,$id) = each %names) {
    if ( @$id == 1 ) {
      # There is only one ID for this name
      push @namestrings, $name;
    } else {
      # There is multiple ID for this name
      for my $i ( @$id ) {
        push @namestrings, "$name.$i";
      }
    }
  }
  return @namestrings;
}

# Given a nodename, find the id and name that matches
#
method idnamematch ( HashRef $data, Str $nodename ) {
  while ( my($id,$name) = each %$data ) {
    if (
      "$name.$id" eq $nodename or $name eq $nodename or "$id" eq "$nodename"
    ) {
      return ($id,$name);
    }
  }
}

with 'WWW::Phanfare::Class::Role::Node';

=head1 NAME

WWW::Phanfare::Class::Role::Branch - Node with sub nodes.

=cut

1;
