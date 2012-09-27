package Algorithm::Simpath;
use strict;
use warnings;
our $VERSION = '0.01';
use Exporter qw(import);
our @EXPORT = qw(solve);

sub low_node($$) {
    my ($node, $grid_edge) = @_;

    {mate => $node->{mate}};
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
        my $target = $node->{mate}{$_};
        if ($_ eq $start_grid_node) {
            defined $target && $target eq $end_grid_node or return;
            $has_route = 1;
            next;
        }
        if ($_ eq $end_grid_node) {
            defined $target && $target eq $start_grid_node or return;
            $has_route = 1;
            next;
        }
        return if defined $target; # Mustn't contain unwanted routes
    }
    return $has_route;
}

sub node_id($) {
    my $node = shift;
    my $mate = $node->{mate};
    join "\t", map {"$_-" . ($mate->{$_} // '')} sort keys %$mate;
}

sub solve(@) {
    my %params = @_;
    my $start      = delete $params{start} // die "no start";
    my $goal       = delete $params{goal}  // die "no goal";
    my @grid_edges = @{delete $params{edges} // []};

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
__END__

=head1 NAME

Algorithm::Simpath -

=head1 SYNOPSIS

  use Algorithm::Simpath;

=head1 DESCRIPTION

Algorithm::Simpath is

=head1 AUTHOR

hiratara E<lt>hiratara {at} cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
