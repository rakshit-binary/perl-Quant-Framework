package Quant::Framework::Utils::Types;

use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw(Int Num Str);
use Moose::Util::TypeConstraints;

subtype 'qf_date_object', as 'Date::Utility';
coerce 'qf_date_object', from 'Str', via { Date::Utility->new($_) };

=head2 bom_timestamp

A valid ISO8601 timestamp, restricted specifically to the YYYY-MM-DDTHH:MI:SS format. Optionally, "Z", "UTC", or "GMT" can be appended to the end. No other time zones are supported.

bom_timestamp can be coerced from C<Date::Utility>

=cut

subtype 'qf_timestamp', as Str, where {
    if (/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(Z|GMT|UTC)?$/) {
        my $date = try {
            DateTime->new(
                year      => $1,
                month     => $2,
                day       => $3,
                hour      => $4,
                minute    => $5,
                second    => $6,
                time_zone => 'GMT'
            );
        };
        return $date ? 1 : 0;
    } else {
        return 0;
    }
}, message {
    "Invalid timestamp $_, please use YYYY-MM-DDTHH:MM:SSZ format";
};

coerce 'qf_timestamp', from 'qf_date_object', via { $_->datetime_iso8601 };
