use inc::Module::Install;

name     'Filesys-Virtual-Phanfare';
all_from 'lib/Filesys/Virtual/Phanfare.pm';
author   q{Soren Dossing <netcom@sauber.net>};
license  'perl';

test_requires 'Test::More';
test_requires 'Test::Pod::Coverage';
test_requires 'Fuse::Filesys::Virtual';
test_requires 'Fuse';
test_requires 'Test::Virtual::Filesystem';

requires 'WWW::Phanfare::API';
requires 'Filesys::Virtual::Plain';
requires 'MooseX::Method::Signatures';

auto_install;

WriteAll;

