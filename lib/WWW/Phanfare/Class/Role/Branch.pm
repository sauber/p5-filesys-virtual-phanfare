package WWW::Phanfare::Class::Role::Branch;
use Moose::Role;
use MooseX::Method::Signatures;

sub xx {
  use Data::Dumper;
  warn Data::Dumper->Dump([$_[1]], ["*** $_[0]"]);
}

#requires 'subnodetype';
#requires 'subnodelist';
requires 'childclass';
requires '_idnames';

# List of subnodes
has '_nodes' => (
  traits  => ['Array'],
  is      => 'rw',
  isa     => 'ArrayRef[Ref]',
  #default => sub { [] },
  lazy_build => 1,
  handles => {
    list    => 'elements',
    _add     => 'push',
    _del     => 'delete',
    #map_options    => 'map',
    #filter_options => 'grep',
    #find_option    => 'first',
    #get_option     => 'get',
    #join_options   => 'join',
    #count_options  => 'count',
    #has_options    => 'count',
    #has_no_options => 'is_empty',
    #sorted_options => 'sort',
    _indexget => 'accessor',
    _clear => 'clear',
  },
);

# Build a list of subnodes.
# Names and ID's come from required _idnames method.
# If ID eq name, then there is no ID
#
method _build__nodes {
  my $type = $self->childclass;
  my @nodes;
  my $idname = $self->_idnames;
  #xx "Branch _build__nodes $self build $type", $idname unless ref $idname eq 'ARRAY';
  for my $item ( @$idname ) {
    my $id = $item->{id};
    my $name = $item->{name};
    #warn "*** build node type $type name $name id $id\n";
    my $node = $type->new(
      parent => $self,
      name => $name,
      ( $name ne $id ? ( id=>$id ) : () ),
    );
    # We already know all the attributes
    $node->setattributes( $item->{attr} )
      if $item->{attr} and $node->can('setattributes');
    # Object can build attributes by itself
    $node->_buildattributes if $node->can('_buildattributes');
    push @nodes, $node;
  }
  return \@nodes;
}

method _rebuild {
  #warn sprintf "*** Rebuilding nodes in %s %s\n", $self->parent->childclass, $self->name;
  #sleep 3;
  my $nodes = $self->_build__nodes;
  #warn sprintf "*** Branch _rebuild count of new nodes %s\n", scalar @$nodes;
  use Data::Dumper;
  #warn "*** Branch _rebuild: " . $nodes;
  #$self->_nodes( $self->_build__nodes );
  #$self->_nodes = $nodes;
  $self->_nodes( $nodes );
}


# Names of subnodes.
# If names are duplicates, then append ID.
#
method names {
  my %name_count;
  ++$name_count{$_->name} for $self->list;
  return map {
    $name_count{$_->name} > 1
      ? $_->name .'.'. $_->id
      : $_->name
  } $self->list;
}

# Get a subnode, by name of name.id
#
method get ( Str $name ) {
  #warn "*** branch get node $name\n";
  my $index = $self->_index( $name );
  return unless defined $index;
  return $self->_indexget( $index );
}

# Index number of matching node
#
method _index ( Str $name ) {
  my $i = 0;
  for my $node ( $self->list ) {
    return $i if $node->id and $name eq $node->name .'.'. $node->id;
    return $i if               $name eq $node->name;
    ++$i;
  }
  return undef;
}

sub AUTOLOAD {
  my $self = shift @_;
  our $AUTOLOAD;

  my $name = $AUTOLOAD;
  $name =~ s/.*:://;

  #warn "*** branch autoload node $name\n";
  die caller if $name eq 'nodename';
  return $self->get($name);
}

# Create new child object and add to list.
# Let object write itself to phanfare if possible
# 
method add ( Str $name, Str $value?, Str $date? ) {
  my $type = $self->childclass;
  my $node = $type->new( parent=>$self, name=>$name );
  $node->value( $value ) if $value;
  $node->attribute( 'image_date', $date ) if $date;
  if ( $node->can( '_write' ) ) {
    #warn "*** Node add $name write\n";
    $node->_write or return;
    #$self->clear__nodes; # Need read from Phanfare to learn id
    #delete $self->{_nodes};
    #$self->_nodes = [];
    $self->_rebuild;
    #xx "Node add clear__nodes", $self->_nodes;
    #warn "** Branch add delete nodes\n";
    return $self; # success
  } else {
    #warn "*** Node add $name _add\n";
    $self->_add( $node );
  }
}

# Let child object remove itself from phanfare
# Then remove from list
#
method remove ( Str $name ) {
  my $node = $self->get( $name ) or return undef;
  if ( $node->can( '_delete' ) ) {
    $node->_delete && $self->_del( $self->_index( $name ) );
  }
  #warn "*** branch remove $name failed\n";
}

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
#has extranode => ( isa=>'HashRef', is=>'rw', default=>sub {{}} );

# List of extranode names
#
#method pending { keys %{ $self->extranode } }

# Delete an extranode
#
#method cancel ( Str $nodename ) { delete $self->extranode->{$nodename} }

# Create a named subnode
#
#method buildnode ( Str $nodename ) {
#  my $type = $self->subnodetype;
#  my $node = $type->new( parent => $self, nodename=>$nodename );
#  # XXX: Should use subnodemake instead
#  #my $node = $self->subnodemake( nodename=>$nodename );
#
#  # Add to list of temporary nodes, if it does not exist yet
#  my @existingnodes = ( $self->subnodelist, keys %{ $self->extranode } );
#  #use Data::Dumper;
#  #warn "*** buildnode Creating node $nodename in ". $self->nodename ."\n";
#  #warn "*** buildnode subnodelist: " . Dumper [ $self->subnodelist ];
#  #warn "*** buildnode extranode: " . Dumper [ keys %{ $self->extranode } ];
#  #warn "*** buildnode existingnodes: " . Dumper \@existingnodes;
#  unless ( grep $_ eq $nodename, $self->subnodelist, keys %{ $self->extranode } ) {
#    #warn "*** buildnode Creating temp node $nodename in ". $self->nodename ."\n";
#    $self->extranode->{$nodename} = $node;
#    #use Data::Dumper;
#    #warn "*** buildnode extranode". Dumper $self->extranode;
#  }
#
#  return $node;
#}

#sub create { shift->buildnode( @_ ) }

# Delete an extranode
# XXX: If node is not an extranode, then delete data recursively in agent
#method delete ( Str $nodename ) {
#  delete $self->extranode->{$nodename};
#}

#method subnodemake ( Str $nodename, HashRef $args? ) {
#  $self->subnodetype->new( nodename => $nodename, parent=>$self, %$args );
#  #my $type = $self->subnodetype;
#  #my $node = $type->new( parent=>$self, nodename=>$nodename );
#  #return $node;
#}

#method getnode ( Str $nodename ) { $self->buildnode( $nodename ) }

# Extract id=>name pairs from a data structure
#
method _idnamepair ( Ref $data, Str $label, HashRef $filter? ) {
  # If data only has one element we get a hashref. Convert it to array.
  $data = [ $data ] unless 'ARRAY' eq ref $data; 
  my($key,$value) = each %$filter if $filter;
  #warn "*** Use filter $key=$value\n";
  # Pairs of id=>name
  return [
    #map { $_->{"${label}_id"} => $_->{"${label}_name"} }
    map {{
      id   => $_->{"${label}_id"},
      name => $_->{"${label}_name"},
      attr  => $_,
    }}
    grep {
      if ( $key and $value and $_->{$key} ) {
        1 if $_->{$key} =~ /^$value/;
      } else {
        1
      }
    }
    @$data
  ];
}

# Get list of names from hashref.
# If multiple ID's have same name, then append ID
#
#method idnamestrings ( HashRef $data ) {
#  my %names;
#  while ( my($id,$name) = each %$data ) {
#    push @{ $names{$name} }, $id;
#  }
#  my @namestrings;
#  while ( my($name,$id) = each %names) {
#    if ( @$id == 1 ) {
#      # There is only one ID for this name
#      push @namestrings, $name;
#    } else {
#      # There is multiple ID for this name
#      for my $i ( @$id ) {
#        push @namestrings, "$name.$i";
#      }
#    }
#  }
#  return @namestrings;
#}

# Given a nodename, find the id and name that matches
#
#method idnamematch ( HashRef $data, Str $nodename ) {
#  while ( my($id,$name) = each %$data ) {
#    if (
#      "$name.$id" eq $nodename or $name eq $nodename or "$id" eq "$nodename"
#    ) {
#      return ($id,$name);
#    }
#  }
#}

with 'WWW::Phanfare::Class::Role::Node';

=head1 NAME

WWW::Phanfare::Class::Role::Branch - Node with sub nodes.

=cut

1;
