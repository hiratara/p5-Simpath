use strict;
use warnings;
use Test::More;
use Algorithm::Simpath;
use Algorithm::Simpath::GridMaker;

for ([4 => 8512], [5 => 1262816], [6 => 575780564], [7 => 789360053252]) {
    my ($size, $expected) = @$_;
    my $edges = Algorithm::Simpath::GridMaker::create_edges($size, $size);
    my $zdd = solve(
        start => '0,0', goal  => "$size,$size", edges => $edges,
    );
    is $zdd->count, $expected;
}

done_testing;
