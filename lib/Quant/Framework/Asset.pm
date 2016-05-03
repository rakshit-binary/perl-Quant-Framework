package Quant::Framework::Asset;

=head1 NAME

Quant::Framework::Asset

=head1 DESCRIPTION

Assets have a symbol and rates. Example assets are currencies, indices, stocks
and commodities.

=cut

use Moose;
use Quant::Framework::Dividend;

use Data::Chronicle::Reader;
use Data::Chronicle::Writer;
use Date::Utility;

=head2 symbol

Represents symbol of the asset.

=cut

has symbol => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has for_date => (
    is      => 'ro',
    isa     => 'Maybe[Date::Utility]',
    default => undef,
);

=head2 chronicle_reader and chronicle_writer

Used to work with Chronicle storage data.

=cut

has chronicle_reader => (
    is  => 'ro',
    isa => 'Data::Chronicle::Reader',
);

has chronicle_writer => (
    is  => 'ro',
    isa => 'Data::Chronicle::Writer',
);

=head2 rate_for
Returns dividend rates
=cut

sub rate_for {
    my ($self, $tiy) = @_;

    my $dividend = Quant::Framework::Dividend->new(
        symbol           => $self->symbol,
        for_date         => $self->for_date,
        chronicle_reader => $self->chronicle_reader,
        chronicle_writer => $self->chronicle_writer,
    );

    my $rate = $dividend->rate_for($tiy);

    return $rate;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
