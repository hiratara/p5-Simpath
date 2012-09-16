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

    my $has_route;
    for (keys %{$node->{mate}}) {
        if ($_ eq $start_grid_node) {
            $node->{mate}{$_} eq $end_grid_node or return;
            $has_route = 1;
            next;
        }
        if ($_ eq $end_grid_node) {
            $node->{mate}{$_} eq $start_grid_node or return;
            $has_route = 1;
            next;
        }
        defined $node->{mate}{$_} and return; # Mustn't contain unwanted routes
    }
    return $has_route;
}

sub node_id($) {
    my $node = shift;
    my $mate = $node->{mate};
    join "\t", map {"$_-" . ($mate->{$_} // '')} sort keys %$mate;
}

sub solve($$) {
    my ($col_width, $col_height) = @_;
    my $width = $col_width + 1;
    my $height = $col_height + 1;

    my $start = "0,0";
    my $goal = sprintf "%d,%d", $width - 1, $height - 1;
    my @grid_edges = grid_edges $width, $height;
    my %route_left;
    for (@grid_edges) {
        $route_left{$_}++ for @$_;
    }

    my $top_node = {mate => {}, low => undef, high => undef};
    my @active_nodes = ($top_node);
    for my $grid_edge (@grid_edges) {
        my @done_grid_nodes;
        for (@$grid_edge) {
            --$route_left{$_} or push @done_grid_nodes, $_;
        }

        my %next_nodes_map;
        for my $node (@active_nodes) {
            # calc low and high node
            my $low_node = low_node $node, $grid_edge;
            my $high_node = high_node $node, $grid_edge;

            # free used mate
            delete $node->{mate};

            # delete mate which isn't frontier
            my $child_node = sub {
                my $new_node = shift;
                defined $new_node or return undef;

                my $new_mate = $new_node->{mate};
                for (@done_grid_nodes) {
                    if ($_ eq $start || $_ eq $goal) {
                        return undef unless defined $new_mate->{$_} &&
                                            $new_mate->{$_} ne $_;
                    } elsif (defined $new_mate->{$_} &&
                        $new_mate->{$_} ne $_
                    ) {
                        return undef; # won't be connected forever
                    }

                    delete $new_node->{mate}{$_};
                }

                return 1 if has_one_route $new_node, $start => $goal;

                $next_nodes_map{node_id $new_node} //= $new_node;
            };
            $node->{low} = $child_node->($low_node);
            $node->{high} = $child_node->($high_node);
        }
        @active_nodes = values %next_nodes_map;
    }

    return $top_node;
}

1;
