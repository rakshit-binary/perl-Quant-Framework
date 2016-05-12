package Quant::Framework::Utils::Symbol;

=head1 NAME

Quatn::Framework::Utils::Symbol

=head1 DESCRIPTION

This is a data-only module to store rather static data related to a symbol/underlying
(e.g. Currency, Stocks, Indices, ...)

=cut

use strict;
use warnings;
use 5.010;

use Moose;

has symbol_name => (
    is      => 'ro',
    isa     => 'Str',
    required=> 1,
);

has system_symbol => (
    is      => 'ro',
    isa     => 'Str',
);

has market_name => (
    is      => 'ro',
    isa     => 'Str',
);

has market_asset_type => (
    is      => 'ro',
    isa     => 'Str',
);

has submarket_name => (
    is      => 'ro',
    isa     => 'Str',
);

has submarket_asset_type => (
    is      => 'ro',
    isa     => 'Str',
);

has volatility_surface_type => (
    is      => 'ro',
    isa     => 'Str',
);

has uses_implied_rate => (
    is      => 'ro',
    isa     => 'Bool',
);

has spot_price => (
    is      => 'ro',
    isa     => 'Num',
);

has spot_epoch => (
    is      => 'ro',
    isa     => 'Int',
);

has asset_symbol => (
    is      => 'ro',
    isa     => 'Quant::Framework::Utils::Symbol',
);

has quoted_currency_symbol => (
    is      => 'ro',
    isa     => 'Quant::Framework::Utils::Symbol',
);

