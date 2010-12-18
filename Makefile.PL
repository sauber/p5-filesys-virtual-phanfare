use inc::Module::Install;

name     'Filesys-Virtual-Phanfare';
all_from 'lib/Filesys/Virtual/Phanfare.pm';
author   q{Soren Dossing <netcom@sauber.net>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

