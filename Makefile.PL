use inc::Module::Install;
name 'Algorithm-Simpath';
all_from 'lib/Algorithm/Simpath.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
