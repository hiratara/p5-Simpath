use strict;
use warnings;
use Algorithm::Simpath;
use Test::More;

is_deeply Algorithm::Simpath::high_node(
    {mate => {A => "B", B => "A", C => "D", D => "C"}}, ["B", "C"]
), {mate => {A => "D", B => undef, C => undef, D => "A"}};

is_deeply Algorithm::Simpath::low_node(
    {mate => {A => "B", B => "A", C => "D", D => "C"}}, ["B", "C"]
), {mate => {A => "B", B => "A", C => "D", D => "C"}};

is_deeply Algorithm::Simpath::high_node(
    {mate => {A => "B", B => "A",}}, ["B", "C"]
), {mate => {A => "C", B => undef, C => "A"}};
is_deeply Algorithm::Simpath::low_node(
    {mate => {A => "B", B => "A",}}, ["B", "C"]
), {mate => {A => "B", B => "A", C => "C"}};

is_deeply Algorithm::Simpath::high_node(
    {mate => {A => undef, B => "D", C => undef, D => "B"}}, ["B", "D"]
), undef, "Loop detected";
is_deeply Algorithm::Simpath::low_node(
    {mate => {A => undef, B => "D", C => undef, D => "B"}}, ["B", "D"]
), {mate => {A => undef, B => "D", C => undef, D => "B"}};

is_deeply Algorithm::Simpath::high_node(
    {mate => {A => undef, B => "D", C => undef, D => "B"}}, ["D", "A"]
), undef, "cross route detected";
is_deeply Algorithm::Simpath::low_node(
    {mate => {A => undef, B => "D", C => undef, D => "B"}}, ["D", "A"]
), {mate => {A => undef, B => "D", C => undef, D => "B"}};

ok Algorithm::Simpath::has_one_route(
    {mate => {"A" => "D", C => undef, D => "A"}},
    "A" => "D",
);
ok ! Algorithm::Simpath::has_one_route(
    {mate => {"A" => "B", B => "A", D => "D"}},
    "A" => "B",
), "It contains unwanted routes.";
ok ! Algorithm::Simpath::has_one_route(
    {mate => {"A" => "D", C => undef, D => "A"}},
    "C" => "A",
), "Route isn't terminated.";
ok ! Algorithm::Simpath::has_one_route(
    {mate => {}},
    "C" => "A",
), "Has no route.";

is Algorithm::Simpath::node_id(
    {mate => {"A" => "D", C => undef, D => "A"}}
), "A-D	C-	D-A", "Route isn't terminated.";

done_testing;
