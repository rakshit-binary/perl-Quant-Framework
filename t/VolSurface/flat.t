use Test::Most;
use Test::FailWarnings;
use JSON qw(decode_json);

use Quant::Framework::Utils::Test;
use Quant::Framework::VolSurface::Flat;

my $ul = Quant::Framework::Utils::Test::create_underlying_config('R_50');
my ($chronicle_r, $chronicle_w) = Data::Chronicle::Mock::get_mocked_chronicle();

subtest "looks flat" => sub {
    plan tests => 630;

    my $volsurface = Quant::Framework::VolSurface::Flat->new({
        underlying_config => $ul,
        chronicle_reader => $chronicle_r,
        chronicle_writer => $chronicle_w,
      });
    for (0 .. 29) {
        my $days = rand(365);
        is(
            $volsurface->get_spread({
                    sought_point => 'atm',
                    day          => $days
                }
            ),
            0.07,
            $days . ' days ATM spread is flat.'
        );
        for (0 .. 19) {
            my $strike = rand(20000);
            is(
                $volsurface->get_volatility({
                        days   => $days,
                        strike => $strike
                    }
                ),
                0.5,
                '.. with a flat vol at a strike of ' . $strike
            );
        }
    }
};

done_testing;
