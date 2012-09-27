use strict;
use warnings;
use Test::More;
use Algorithm::Simpath;
use Algorithm::Simpath::GridMaker;

my $edges = Algorithm::Simpath::GridMaker::create_edges(5, 5);
my $zdd = solve(
    start => '0,0', goal  => '5,5', edges => $edges,
);
is $zdd->count, 1262816;

done_testing;
