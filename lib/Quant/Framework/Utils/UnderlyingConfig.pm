package Quant::Framework::Utils::Symbol;

=head1 NAME

Quant::Framework::Utils::Symbol

=head1 DESCRIPTION

This is a data-only module to store rather static data related to a symbol/underlying
(e.g. Currency, Stocks, Indices, ...)

=cut

use strict;
use warnings;
use 5.010;

use Moose;

has symbol => (
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

has market_prefer_discrete_dividend => (
    is      => 'ro',
);

has quanto_only => (
    is      => 'ro',
);

has submarket_name => (
    is      => 'ro',
    isa     => 'Str',
);

has rate_to_imply_from => (
    is         => 'ro',
    isa        => 'Str',
);

has submarket_asset_type => (
    is      => 'ro',
    isa     => 'Str',
);

has volatility_surface_type => (
    is      => 'ro',
    isa     => 'Str',
);

has exchange_name => (
    is      => 'ro',
    isa     => 'Str',
);

has locale => (
    is      => 'ro',
    isa     => 'Str',
);

has uses_implied_rate => (
    is      => 'ro',
    isa     => 'Bool',
);

has spot  => (
    is      => 'ro',
);

has asset => (
    is      => 'ro',
    isa     => 'Quant::Framework::Utils::UnderlyingConfig',
);

has quoted_currency => (
    is      => 'ro',
    isa     => 'Quant::Framework::Utils::UnderlyingConfig',
);

has extra_vol_diff_by_delta => ...
has market_convention => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        return {
            delta_style            => 'spot_delta',
            delta_premium_adjusted => 0,
        };
    },
);
