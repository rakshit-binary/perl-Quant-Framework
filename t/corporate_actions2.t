#!/usr/bin/perl

use strict;
use warnings;

use Test::More (tests => 6);

use Test::Exception;
use Test::NoWarnings;

use Date::Utility;

use Quant::Framework::CorporateAction;
use Quant::Framework::Utils::Test;
use Data::Chronicle::Mock;

my ($chronicle_r, $chronicle_w) = Data::Chronicle::Mock::get_mocked_chronicle();

subtest 'general' => sub {
    plan tests => 5;
    lives_ok { Quant::Framework::CorporateAction->new(symbol => 'FPFP',
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w) } 'creates corporate action object with symbol';
    throws_ok { Quant::Framework::CorporateAction->new } qr/Attribute \(symbol\) is required/, 'throws exception if symbol is not provided';
    lives_ok {
        my $corp = Quant::Framework::CorporateAction->new(symbol => 'UKHBSA',        chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w);
        isa_ok($corp->actions, 'HASH');
        ok !keys %{$corp->actions}, 'empty hash';
    }
    'does not die if no actions are present on db';
};

Quant::Framework::Utils::Test::create_doc('corporate_action',
    {
        chronicle_reader => $chronicle_r,
        chronicle_writer => $chronicle_w
    });

subtest 'save new corporate actions' => sub {
    plan tests => 7;
    my $now = Date::Utility->new;
    lives_ok {
        my $corp = Quant::Framework::CorporateAction->new(symbol => 'FPFP',
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w);
        my $actions = $corp->actions;
        is keys %$actions, 1, 'has only one action';
        my $new_actions = {
            1122334 => {
                effective_date => $now->datetime_iso8601,
                modifier       => 'multiplication',
                value          => 1.456,
                description    => 'Test data 2',
                flag           => 'N'
            }};
        my $new_corp = Quant::Framework::CorporateAction->new(
            symbol        => 'FPFP',
            actions       => $new_actions,
            recorded_date => $now,
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w,
        );
        ok $new_corp->save, 'saves new action';
        my $after_save_corp = Quant::Framework::CorporateAction->new(symbol => 'FPFP',
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w);
        my $new_actions_from_db = $after_save_corp->actions;
        is keys %$new_actions_from_db, 2, 'has two actions';
    }
    'save new action';

    lives_ok {
        my $new_actions = {
            1122334 => {
                effective_date => $now->datetime_iso8601,
                modifier       => 'multiplication',
                value          => 1.456,
                description    => 'Duplicate action',
                flag           => 'N'
            }};
        my $no_dup_corp = Quant::Framework::CorporateAction->new(
            symbol        => 'FPFP',
            actions       => $new_actions,
            recorded_date => $now,
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w,
        );
        ok $no_dup_corp->save, 'try to save duplicate action';
        my $after_save = Quant::Framework::CorporateAction->new(symbol => 'FPFP',
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w);

        my $action = $after_save->actions;
        cmp_ok($action->{1122334}->{description}, "ne", 'Duplicate action', 'did not save duplicate action');
    }
    'No duplicate actions save';
};

subtest 'update existing corporate actions' => sub {
    plan tests => 5;
    lives_ok {
        my $now         = Date::Utility->new;
        my $action_id   = 1122334;
        my $new_actions = {
            $action_id => {
                effective_date => $now->datetime_iso8601,
                modifier       => 'multiplication',
                value          => 1.987,
                description    => 'Update to existing actions',
                flag           => 'U'
            }};
        my $new_corp = Quant::Framework::CorporateAction->new(
            symbol        => 'FPFP',
            actions       => $new_actions,
            recorded_date => $now,
        chronicle_reader => $chronicle_r,
        chronicle_writer => $chronicle_w
        );
        ok $new_corp->save, 'saves new action';
        my $after_save_corp = Quant::Framework::CorporateAction->new(symbol => 'FPFP',
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w);

        my $new_actions_from_db = $after_save_corp->actions;
        is keys %$new_actions_from_db, 2, 'has two actions';
        my $updated_action = $new_actions_from_db->{$action_id};
        is $updated_action->{description}, 'Update to existing actions', 'description is updated';
        is $updated_action->{value}, 1.987, 'value is also updated';
    }
    'update existing action';
};

subtest 'cancel existing corporate actions' => sub {
    plan tests => 4;
    lives_ok {
        my $now         = Date::Utility->new;
        my $action_id   = 1122334;
        my $new_actions = {
            $action_id => {
                effective_date => $now->datetime_iso8601,
                modifier       => 'multiplication',
                value          => 1.987,
                description    => 'Update to existing actions',
                flag           => 'D'
            }};
        my $new_corp = Quant::Framework::CorporateAction->new(
            symbol        => 'FPFP',
            actions       => $new_actions,
            recorded_date => $now,
        chronicle_reader => $chronicle_r,
        chronicle_writer => $chronicle_w
        );
        ok $new_corp->save, 'saves new action';
        my $after_save_corp = Quant::Framework::CorporateAction->new(symbol => 'FPFP',
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w);
        my $new_actions_from_db = $after_save_corp->actions;
        is keys %$new_actions_from_db, 1, 'has one actions';
        ok !$new_actions_from_db->{$action_id}, 'action deleted from db';
    }
    'cancel existing action';
};

subtest 'save critical actions' => sub {
    plan tests => 5;
    lives_ok {
        my $now         = Date::Utility->new;
        my $action_id   = 11223346;
        my $new_actions = {
            $action_id => {
                effective_date  => $now->datetime_iso8601,
                suspend_trading => 1,
                disabled_date   => $now->datetime_iso8601,
                description     => 'Save critical action',
                flag            => 'N'
            }};
        my $new_corp = Quant::Framework::CorporateAction->new(
            symbol        => 'FPFP',
            actions       => $new_actions,
            recorded_date => $now,
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w
        );
        ok $new_corp->save, 'saves critical action';
        my $after_save_corp = Quant::Framework::CorporateAction->new(symbol => 'FPFP',
            chronicle_reader => $chronicle_r,
            chronicle_writer => $chronicle_w);

        my $new_actions_from_db = $after_save_corp->actions;
        is keys %$new_actions_from_db, 2, 'has two actions';
        ok $new_actions_from_db->{$action_id}, 'critical action saved on db';
        ok $new_actions_from_db->{$action_id}->{suspend_trading}, 'suspend_trading';
    }
    'save critical action';
};
