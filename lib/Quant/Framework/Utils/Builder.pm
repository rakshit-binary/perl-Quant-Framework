package Quant::Framework::Utils::Builder;
use 5.010;

use strict;
use warnings;

sub build_dividend {
    my ($symbol, $chronicle_r, $chronicle_w) = @_;

    return Quant::Framework::Dividend->new({
            symbol  => $symbol,
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w,
        });
}


