package Algorithm::Simpath::GridMaker;
use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(create_edges);

sub create_edges($$) {
    my ($cols, $rows) = @_;
    my $width  = $cols + 1;
    my $height = $rows + 1;

    my @edges;
    for my $n (0 .. $width + $height - 1) {
        for my $x (0 .. $n) {
            my $y = $n - $x;
            $x < $width && $y < $height or next;
            push @edges, ["$x,$y", ($x + 1) . ",$y"] if $x + 1 < $width;
            push @edges, ["$x,$y", "$x," . ($y + 1)] if $y + 1 < $height;
        }
    }

    \@edges;
}

1;
__END__

=head1 NAME

Algorithm::Simpath::GridMaker -

=head1 SYNOPSIS

  use Algorithm::Simpath;
  use Algorithm::Simpath::GridMaker;

  my $edges = Algorithm::Simpath::GridMaker::create_edges(5, 5);
  my $zdd = solve(
      start => '0,0', goal  => '5,5', edges => $edges
  );
  print $zdd->count, "\n"; # 1262816

=head1 DESCRIPTION

Algorithm::Simpath::GridMaker is

=head1 AUTHOR

hiratara E<lt>hiratara {at} cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
