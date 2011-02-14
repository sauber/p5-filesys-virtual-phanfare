package WWW::Phanfare::Class::Role::Branch;
use Moose::Role;
use MooseX::Method::Signatures;

requires 'subnodetype';
requires 'subnodelist';

# List of new subnodes created locally and not yet uploaded
has extranode => ( isa=>'HashRef[Int]', is=>'rw', default=>sub {{}} );

# Create a named subnode
#
method buildnode ( Str $nodename ) {
  my $type = $self->subnodetype;
  my $node = $type->new( parent => $self, nodename=>$nodename );

  # Add to list of temporary nodes, if it does not exist yet
  unless ( grep $nodename, $self->subnodelist, keys %{ $self->extranode } ) {
    warn "*** Creating temp node $nodename in $self->nodename\n";
    $self->extranode->{$nodename} = $node;
  }

  return $node;
}

method subnodemake ( Str $nodename, HashRef $args? ) {
   $self->subnodetype->new( nodename => $nodename, parent=>$self, %$args );
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

WWW::Phanfare::Class::Role::Branch - Node wtih sub nodes.

=cut

1;
