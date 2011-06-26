use inc::Module::Install;

name     'Filesys-Virtual-Phanfare';
all_from 'lib/Filesys/Virtual/Phanfare.pm';
author   q{Soren Dossing <netcom@sauber.net>};
license  'perl';

test_requires 'Test::More';
test_requires 'Test::Pod::Coverage';
test_requires 'Pod::Coverage::Moose';
#test_requires 'Fuse::Filesys::Virtual';
#test_requires 'Fuse';
test_requires 'YAML::Syck';

requires 'WWW::Phanfare::Class' => 0.01;
requires 'Filesys::Virtual::Plain';
requires 'MooseX::Method::Signatures';
requires 'Devel::Size';
requires 'Cache::Memory';
requires 'Date::Parse';

auto_install;

WriteAll;

