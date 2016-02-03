#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Quant::Framework' ) || print "Bail out!\n";
}

diag( "Testing Quant::Framework $Quant::Framework::VERSION, Perl $], $^X" );
