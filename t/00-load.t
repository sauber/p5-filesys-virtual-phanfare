#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Filesys::Virtual::Phanfare' ) || print "Bail out!
";
}

diag( "Testing Filesys::Virtual::Phanfare $Filesys::Virtual::Phanfare::VERSION, Perl $], $^X" );
