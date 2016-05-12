package Quant::Framework::RateHelper;
use 5.010;

use strict;
use warnings;

use Moose;

=head2 for_date

The date for which we wish data

=cut

has for_date => (
    is      => 'ro',
    isa     => 'Maybe[Date::Utility]',
    default => undef,
);

has chronicle_reader => (
    is      => 'ro',
    isa     => 'Data::Chronicle::Reader',
);

has chronicle_writer => (
    is      => 'ro',
    isa     => 'Data::Chronicle::Writer',
);

has symbol => (
    is      => 'ro',
    isa     => 'Quant::Framework::Utils::Symbol',
);

has _asset => (
    is      => 'ro',
    lazy_build    => 1,
);


=head2 asset

Return the asset object depending on the market type.

=cut

sub _build__asset {
    my $self = shift;

    return unless $self->symbol->asset_symbol;
    my $type =
          $self->symbol->submarket_asset_type eq 'currency'
        ? $self->symbol->submarket_asset_type
        : $self->symbol->market_asset_type;
    my $which = $type eq 'currency' ? 'Quant::Framework::Currency' : 'Quant::Framework::Asset';

    return $which->new({
        symbol           => $self->symbol->asset_symbol,
        for_date         => $self->for_date,
        chronicle_reader => $self->chronicle_reader,
        chronicle_writer => $self->chronicle_writer,
    });
}

=head2 dividend_rate_for

Get the dividend rate for this underlying over a given time period (expressed in timeinyears.)

=cut

sub dividend_rate_for {
    my ($self, $tiy) = @_;

    die 'Attempting to get interest rate on an undefined currency for ' . $self->symbol_name
        unless (defined $self->symbol->asset_symbol);

    my %zero_rate = (
        smart_fx  => 1,
        smart_opi => 1,
    );

    my $rate;

    if ($self->symbol->market_name eq 'volidx') {
        my $div = build_dividend($self->symbol->symbol_name, $self->chronicle_reader, $self->chronicle_writer);
        my @rates = values %{$div->rates};
        $rate = pop @rates;
    } elsif ($zero_rate{$self->symbol->submarket_name}) {
        $rate = 0;
    } else {
        # timeinyears cannot be undef
        $tiy ||= 0;
        if ($self->symbol->asset_symbol->uses_implied_rate) {
            $rate = $self->asset->rate_implied_from($self->rate_to_imply_from, $tiy);
        } else {
            $rate = $self->asset->rate_for($tiy);
        }
    }
    return $rate;
}



=head2 interest_rate_for

Get the interest rate for this underlying over a given time period (expressed in timeinyears.)

=cut

sub interest_rate_for {
    my ($self, $tiy) = @_;

    # timeinyears cannot be undef
    $tiy ||= 0;

    # list of markets that have zero rate
    my %zero_rate = (
        volidx => 1,
    );

    my $rate;
    if ($zero_rate{$self->market_name}) {
        $rate = 0;
    } elsif ($self->uses_implied_rate($self->quoted_currency_symbol)) {
        $rate = $self->quoted_currency->rate_implied_from($self->rate_to_imply_from, $tiy);
    } else {
        $rate = $self->quoted_currency->rate_for($tiy);
    }

    return $rate;
}


sub dividend_adjustments_for_period {
    my ($self, $args) = @_;

    my $applicable_dividends =
        ($self->market->prefer_discrete_dividend)
        ? $self->get_discrete_dividend_for_period($args)
        : {};

    my ($start, $end) = @{$args}{'start', 'end'};
    my $duration_in_sec = $end->epoch - $start->epoch;

    my ($dS, $dK) = (0, 0);
    foreach my $date (keys %$applicable_dividends) {
        my $adjustment           = $applicable_dividends->{$date};
        my $effective_date       = Date::Utility->new($date);
        my $sec_away_from_action = ($effective_date->epoch - $start->epoch);
        my $duration_in_year     = $sec_away_from_action / (86400 * 365);
        my $r_rate               = $self->interest_rate_for($duration_in_year);

        my $adj_present_value = $adjustment * exp(-$r_rate * $duration_in_year);
        my $s_adj = ($duration_in_sec - $sec_away_from_action) / ($duration_in_sec) * $adj_present_value;
        $dS -= $s_adj;
        my $k_adj = $sec_away_from_action / ($duration_in_sec) * $adj_present_value;
        $dK += $k_adj;
    }

    return {
        barrier => $dK,
        spot    => $dS,
    };
}

