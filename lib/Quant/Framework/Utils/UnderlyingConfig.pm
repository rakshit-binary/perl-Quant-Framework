package Quant::Framework::Utils::UnderlyingConfig;

=head1 NAME

Quant::Framework::Utils::UnderlyingConfig

=head1 DESCRIPTION

This is a data-only module to store rather static data related to a symbol/underlying
(e.g. Currency, Stocks, Indices, ...)

=cut

use strict;
use warnings;
use 5.010;

use Moose;

=head2 symbol

Symbol name

=cut

has symbol => (
    is      => 'ro',
    isa     => 'Str',
    required=> 1,
);

=head2 system_symbol

Internal symbol name

=cut

has system_symbol => (
    is      => 'ro',
    isa     => 'Str',
);

=head2 market_name

Name of the market

=cut

has market_name => (
    is      => 'ro',
    isa     => 'Str',
);

=head2 market_asset_type

Asset type of this market

=cut

has market_asset_type => (
    is      => 'ro',
    isa     => 'Str',
);

=head2 market_prefer_discrete_dividend

Whether discrete dividend is preferred for this underlying

=cut

has market_prefer_discrete_dividend => (
    is      => 'ro',
);

=head2 quanto_only

Specifies if this underlying is quanto-only

=cut

has quanto_only => (
    is      => 'ro',
);

=head2 submarket_name

Name of the submarket

=cut

has submarket_name => (
    is      => 'ro',
    isa     => 'Str',
);

=head2 rate_to_imply_from

Name of the underlying to imply rates from

=cut

has rate_to_imply_from => (
    is         => 'ro',
    isa        => 'Str',
);

=head2 submarket_asset_type

Asset type for submarket of this underlying

=cut

has submarket_asset_type => (
    is      => 'ro',
    isa     => 'Str',
);

=head2 volatility_surface_type

Type of volatility surface (moneyness, delta, flat)

=cut

has volatility_surface_type => (
    is      => 'ro',
    isa     => 'Str',
);

=head2 exchange_name

Name of the exchange

=cut

has exchange_name => (
    is      => 'ro',
    isa     => 'Str',
);

=head2 local

Locale code, used to generate some descriptions in TradingCalendar

=cut

has locale => (
    is      => 'ro',
    isa     => 'Str',
);

=head2 uses_implied_rate

Whether this underlying uses implied rate

=cut

has uses_implied_rate => (
    is      => 'ro',
    isa     => 'Bool',
);

=head2 spot

Spot price at the time of construction of this object

=cut

has spot  => (
    is      => 'ro',
);

=head2 asset

UnderlyingConfig of the asset of this underlying

=cut

has asset => (
    is      => 'ro',
    isa     => 'Quant::Framework::Utils::UnderlyingConfig',
);

=head2 quoted_currency

Quoted currency of the underlying

=cut

has quoted_currency => (
    is      => 'ro',
    isa     => 'Quant::Framework::Utils::UnderlyingConfig',
);

=head2 extra_vol_diff_by_delta

Extra volatility difference

=cut

has extra_vol_diff_by_delta => (
    is      => 'ro',
);

=head2 market_convention

Market convention settings

=cut

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


1;
