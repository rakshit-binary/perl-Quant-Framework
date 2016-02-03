#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;
use Test::Exception;
use Test::NoWarnings;
use Date::Utility;

use Quant::Framework::CorporateAction;
use Quant::Framework::Utils::Test;
use Data::Chronicle::Writer;
use Data::Chronicle::Reader;
use Data::Chronicle::Mock;

my ($chronicle_r, $chronicle_w) = Data::Chronicle::Mock::get_mocked_chronicle();

is(Quant::Framework::CorporateAction->new(
        symbol => 'FPGZ',
        chronicle_reader    => $chronicle_r,
        chronicle_writer    => $chronicle_w
    )->document, undef, 'document is not present');

my $old_date = Date::Utility->new()->minus_time_interval("15m");
my $int = Quant::Framework::Utils::Test::create_doc('corporate_action', {
        symbol        => 'QWER',
        chronicle_reader    => $chronicle_r,
        chronicle_writer    => $chronicle_w,
        actions       => {
            "62799500" => {
                "monitor_date" => "2014-02-07T06:00:07Z",
                "type" => "ACQUIS",
                "monitor" => 1,
                "description" =>  "Acquisition",
                "effective_date" =>  "15-Jul-14",
                "flag" => "N"
            },
        },
        recorded_date => $old_date,
    }
);

ok $int->save, 'save without error';

lives_ok {
    my $new = Quant::Framework::CorporateAction->new(symbol => 'QWER',
        chronicle_reader    => $chronicle_r,
        chronicle_writer    => $chronicle_w);

    ok $new->document;
    is $new->document->{actions}->{62799500}->{type}, "ACQUIS";
    is $new->document->{actions}->{62799500}->{effective_date}, "15-Jul-14";
} 'successfully retrieved saved document';

lives_ok {
    my $int = Quant::Framework::Utils::Test::create_doc('corporate_action', {
            chronicle_reader    => $chronicle_r,
            chronicle_writer    => $chronicle_w,
            symbol        => 'QWER',
            actions       => {
                "32799500" => {
                    "monitor_date" => "2015-02-07T06:00:07Z",
                    "type" => "DIV",
                    "monitor" => 1,
                    "description" =>  "Divided Stocks",
                    "effective_date" =>  "15-Jul-15",
                    "flag" => "N"
                },
            }
        }
    );

    ok $int->save, 'save again without error';

    my $old_corp_action = Quant::Framework::CorporateAction->new(
        chronicle_reader    => $chronicle_r,
        chronicle_writer    => $chronicle_w,
        symbol      => 'QWER',
        for_date    => $old_date);

    is $old_corp_action->document->{actions}->{62799500}->{type}, "ACQUIS";
} 'successfully reads older corporate actions';
