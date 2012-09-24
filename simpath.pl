use strict;
use warnings;
use Simpath;

sub count($); sub count($) {
    my $node = shift;
    return 0 unless $node;
    return 1 unless ref $node;
    $node->{count} //= count($node->{low}) + count($node->{high});
}

my $zdd = solve(9, 9);
print +(count $zdd), "\n";
