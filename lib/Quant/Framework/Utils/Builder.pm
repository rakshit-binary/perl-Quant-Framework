package Quant::Framework::Utils::Builder;
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

has underlying_config => (
    is      => 'ro',
    isa     => 'Quant::Framework::Utils::UnderlyingConfig',
);

sub build_expiry_conventions {
    my $self = shift;

    my $quoted_currency = Quant::Framework::Currency->new({
            symbol           => $self->underlying_config->quoted_currency->symbol,
            for_date         => $self->for_date,
            chronicle_reader => $self->chronicle_reader,
            chronicle_writer => $self->chronicle_writer,
        });

    return Quant::Framework::ExpiryConventions->new({
            chronicle_reader => $self->chronicle_reader,
            is_forex_market  => $self->underlying_config->market_name eq 'forex',
            symbol           => $self->underlying_config->symbol,
            for_date         => $self->for_date,
            asset            => $self->build_asset,
            quoted_currency  => $quoted_currency,
            asset_symbol     => $self->underlying_config->asset->symbol,
            calendar         => $self->build_trading_calendar,
        });
}

sub build_trading_calendar {
    my $self = shift;

    return Quant::Framework::TradingCalendar->new({
            symbol => $self->underlying_config->exchange_name,
            chronicle_reader => $self->chronicle_reader,
            $self->underlying_config->locale ? locale => $self->underlying_config->locale:(),
            for_date => $self->for_date
        });
}

sub build_dividend {
    my $self = shift;

    return Quant::Framework::Dividend->new({
            symbol  => $self->underlying_config->symbol,
            for_date => $self->for_date,
            chronicle_reader => $self->chronicle_r,
            chronicle_writer => $self->chronicle_w,
        });
}

sub build_asset {
    my $self = shift;

    return unless $self->underlying_config->asset_symbol;
    my $type =
          $self->underlying_config->submarket_asset_type eq 'currency'
        ? $self->underlying_config->submarket_asset_type
        : $self->underlying_config->market_asset_type;
    my $which = $type eq 'currency' ? 'Quant::Framework::Currency' : 'Quant::Framework::Asset';

    return $which->new({
        symbol           => $self->underlying_config->asset_symbol,
        for_date         => $self->for_date,
        chronicle_reader => $self->chronicle_r,
        chronicle_writer => $self->chronicle_w,
    });
}

sub build_currency {
    return Quant::Framework::Currency->new({
        symbol           => $self->underlying_config->asset_symbol,
        for_date         => $self->for_date,
        chronicle_reader => $self->chronicle_r,
        chronicle_writer => $self->chronicle_w,
    });
}

=head2 dividend_rate_for

Get the dividend rate for this underlying over a given time period (expressed in timeinyears.)

=cut

sub dividend_rate_for {
    my ($self, $tiy) = @_;

    die 'Attempting to get interest rate on an undefined currency for ' . $self->underlying_config->symbol
        unless (defined $self->underlying_config->asset_symbol);

    my %zero_rate = (
        smart_fx  => 1,
        smart_opi => 1,
    );

    my $rate;

    if ($self->underlying_config->market_name eq 'volidx') {
        my $div = build_dividend($self->underlying_config->symbol_name, $self->for_date, $self->chronicle_reader, $self->chronicle_writer);
        my @rates = values %{$div->rates};
        $rate = pop @rates;
    } elsif ($zero_rate{$self->underlying_config->submarket_name}) {
        $rate = 0;
    } else {
        # timeinyears cannot be undef
        $tiy ||= 0;
        my $asset = build_asset($self->symbol, $self->for_date, $self->chronicle_reader, $self->chronicle_writer);

        if ($self->underlying_config->asset_symbol->uses_implied_rate) {
            $rate = $asset->rate_implied_from($self->rate_to_imply_from, $tiy);
        } else {
            $rate = $asset->rate_for($tiy);
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

    my $quoted_currency = build_currency($self->underlying_config->quoted_currency_symbol, 
        $self->for_date, $self->chronicle_reader, $self->chronicle_writer);

    my $rate;
    if ($zero_rate{$self->underlying_config->market_name}) {
        $rate = 0;
    } elsif ($self->underlying_config->quoted_currency_symbol->uses_implied_rate) {
        $rate = $quoted_currency->rate_implied_from($self->underlying_config->rate_to_imply_from, $tiy);
    } else {
        $rate = $quoted_currency->rate_for($tiy);
    }

    return $rate;
}

sub get_discrete_dividend_for_period {
    my ($self, $args) = @_;

    my ($start, $end) =
        map { Date::Utility->new($_) } @{$args}{'start', 'end'};

    my %valid_dividends;
    my $discrete_points = build_dividend($self->underlying_config->asset_symbol, $self->for_date, $self->chronicle_reader, $self->chronicle_writer)->discrete_points;

    if ($discrete_points and %$discrete_points) {
        my @sorted_dates =
            sort { $a->epoch <=> $b->epoch }
            map  { Date::Utility->new($_) } keys %$discrete_points;

        foreach my $dividend_date (@sorted_dates) {
            if (    not $dividend_date->is_before($start)
                and not $dividend_date->is_after($end))
            {
                my $date = $dividend_date->date_yyyymmdd;
                $valid_dividends{$date} = $discrete_points->{$date};
            }
        }
    }

    return \%valid_dividends;
}

sub dividend_adjustments_for_period {
    my ($self, $args) = @_;

    my $applicable_dividends =
        ($self->underlying_config->market_prefer_discrete_dividend)
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
