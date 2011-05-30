#!perl -T

# Test all class methods

use Test::More;
use_ok( 'WWW::Phanfare::Class' );
use lib 't';
use_ok( 'FakeAgent' );

use Data::Dumper;

my $class;
if ( $ENV{SITE} ) {
  # Create test object on live site
  my %config;
  eval '
    use Config::General;
    use File::HomeDir;
    use WWW::Phanfare::API;
    my $rcfile = File::HomeDir->my_home . "/.phanfarerc";
    %config = Config::General->new( $rcfile )->getall;
    die unless $config{api_key}
           and $config{private_key}
           and $config{email_address}
           and $config{password};
  ';
  plan skip_all => "Local config not found: $@" if $@;
  $class = new_ok( 'WWW::Phanfare::Class' => [ %config ] );

} else { 
  # Create an fake test object
  $class = new_ok( 'WWW::Phanfare::Class' => [ 
    api_key       => 'secret',
    private_key   => 'secret',
    email_address => 's@c.et',
    password      => 'secret',
  ] );
  $class->api( FakeAgent->new() );
}

isa_ok( $class, 'WWW::Phanfare::Class' );
ok( my $account = $class->account(), "Class has account" );
ok( my($sitename) = $account->names, "Class has sites" );
ok( my $site = $account->$sitename, "Class has site object" );
ok( my($yearname) = $site->names, "Class has years" );
ok( my $year = $site->$yearname, "Class has year object" );
ok( my($albumname) = $year->names, "Class has an album" );
ok( my $album = $year->$albumname, "Class has album object" );

# Create, read and delete an album
my $newalbum = "New Album";
diag "Existing albums: " . Dumper [ $year->names ];
ok( ! grep(/$newalbum/, $year->names), "Album $newalbum doesn't yet exist" );
$year->add( $newalbum );
diag "Existing albums: " . Dumper [ $year->names ];
ok( grep(/$newalbum/, $year->names), "Album $newalbum now exists" );
diag '*** album list:' . Dumper [$year->names];
$year->remove( $newalbum );
diag '*** album list:' . Dumper [$year->names];
ok( ! grep(/$newalbum/, $year->names), "Album $newalbum no longer exists" );
diag '*** album list:' . Dumper [$year->names];

done_testing(); exit;
