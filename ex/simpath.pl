use strict;
use warnings;
use Algorithm::Simpath;

sub grid_edges($$) {
    my ($width, $height) = @_;

    my @edges;
    for my $n (0 .. $width + $height - 1) {
        for my $x (0 .. $n) {
            my $y = $n - $x;
            $x < $width && $y < $height or next;
            push @edges, ["$x,$y", ($x + 1) . ",$y"] if $x + 1 < $width;
            push @edges, ["$x,$y", "$x," . ($y + 1)] if $y + 1 < $height;
        }
    }

    @edges;
}

sub count($); sub count($) {
    my $node = shift;
    return 0 unless $node;
    return 1 unless ref $node;
    $node->{count} //= count($node->{low}) + count($node->{high});
}

my $width = ($ARGV[0] // 4) + 1;
my $height = ($ARGV[1] // 4) + 1;

my $start = "0,0";
my $goal = sprintf "%d,%d", $width - 1, $height - 1;

my $zdd = solve(
    start => $start,
    goal => $goal,
    edges => [grid_edges $width, $height],
);
print +(count $zdd), "\n";
