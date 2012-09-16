package Simpath;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT = qw(solve);

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

sub low_node($$) {
    my ($node, $grid_edge) = @_;

    my %mate = %{$node->{mate}};
    my $next_grid_node = $grid_edge->[1];
    $mate{$next_grid_node} = $next_grid_node unless exists $mate{$next_grid_node};

    {mate => \%mate};
}

sub high_node($$) {
    my ($node, $grid_edge) = @_;

    my %mate = %{$node->{mate}};

    my @grid_nodes;

    # loop detection
    return undef if ($mate{$grid_edge->[0]} // '') eq $grid_edge->[1];

    for my $grid_node ($grid_edge->[0], $grid_edge->[1]) {
        if (! exists $mate{$grid_node}) {
            push @grid_nodes, $grid_node; # That's the new grid node
        } elsif (! defined $mate{$grid_node}) { # Have already connected :/
            return undef;
        } else {
            push @grid_nodes, $mate{$grid_node};
            $mate{$grid_node} = undef; # Connect to new grid node
        }
    }

    $mate{$grid_nodes[0]} = $grid_nodes[1];
    $mate{$grid_nodes[1]} = $grid_nodes[0];

    {mate => \%mate};
}

sub has_one_route($$$) {
    my ($node, $start_grid_node, $end_grid_node) = @_;
    for (keys %{$node->{mate}}) {
        if ($_ eq $start_grid_node) {
            $node->{mate}{$_} eq $end_grid_node or return;
            next;
        }
        if ($_ eq $end_grid_node) {
            $node->{mate}{$_} eq $start_grid_node or return;
            next;
        }
        defined $node->{mate}{$_} and return; # Mustn't contain unwanted routes
    }
    return 1;
}

sub solve($$) {
    my ($width, $height) = @_;

    my @grid_edges = grid_edges $width, $height;

    my @active_nodes = ({mate => {"0,0" => "0,0"}});
    for my $grid_edge (@grid_edges) {
        my @next_nodes;
        for my $node (@active_nodes) {
            # calc low node
            my $low_node = low_node $node, $grid_edge;
            my $high_node = high_node $node, $grid_edge;
        }
        @active_nodes = @next_nodes;
    }
}

1;
