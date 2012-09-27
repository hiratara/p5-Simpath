use strict;
use warnings;
use Algorithm::Simpath;
use Test::More;

sub count($); sub count($) {
    my $node = shift;
    return 0 unless $node;
    return 1 unless ref $node;
    $node->{count} //= count($node->{low}) + count($node->{high});
}

{
    my $zdd = solve(
        start => 'A',
        goal  => 'C',
        edges => [[qw(A B)], [qw(C A)], [qw(D A)], [qw(B D)], [qw(B C)], [qw(C D)]],
    );
    is +($zdd->count), 5;
}

{
    my $zdd = solve(
        start => 'A',
        goal  => 'C',
        edges => [[qw(A B)], [qw(B C)], [qw(C A)], [qw(D A)], [qw(C D)], [qw(B D)]],
    );
    is +($zdd->count), 5;
}

done_testing;
