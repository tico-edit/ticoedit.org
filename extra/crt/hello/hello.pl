#!/usr/bin/env perl
# hello.pl: a friendly greeting from tico.

use strict;
use warnings;

my @names = @ARGV ? @ARGV : ('world');

foreach my $name (@names) {
    print "Hello, $name!\n";
}
