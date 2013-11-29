use inc::Module::Install;
name 'WWW-Tamagoya';
all_from 'lib/WWW/Tamagoya.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
