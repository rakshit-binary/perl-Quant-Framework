package Quant::Framework::Utils::Test;

=head1 NAME

BOM::Test::Data::Utility::UnitTestCouchDB

=head1 DESCRIPTION

To be used by an RMG unit test. Changes the names of our CouchDB databases
for the duration of the test run, so that data added and modified by
the test doesn't clash with data being used by other code running on the
server.

=head1 SYNOPSIS

  use BOM::Test::Data::Utility::UnitTestCouchDB qw(:init);

=cut

use 5.010;
use strict;
use warnings;

use File::ShareDir ();
use YAML::XS qw(LoadFile);
use Quant::Framework::CorporateAction;
use Data::Chronicle::Writer;
use Data::Chronicle::Reader;
use Data::Chronicle::Mock;

=head2 create doc()

    Create a new document in the test database

    params:
    $yaml_couch_db  => The name of the entity in the YAML file (eg. promo_code)
    $data_mod       => hasref of modifictions required to the data (optional)

=cut

sub create_doc {
    my ($yaml_couch_db, $data_mod) = @_;

    my $save = 1;
    if (exists $data_mod->{save}) {
        $save = delete $data_mod->{save};
    }

    # get data to insert
    state $fixture = LoadFile(File::ShareDir::dist_file('Quant-Framework', 'test_data.yml'));

    my $data    = $fixture->{$yaml_couch_db}{data};

    die "Invalid yaml db name: $yaml_couch_db" if not defined $data;

    # modify data?
    for (keys %$data_mod) {
        $data->{$_} = $data_mod->{$_};
    }

    # use class to create the Couch doc
    my $class_name = $fixture->{$yaml_couch_db}{class_name};
    my $obj        = $class_name->new($data);

    if ($save) {
        $obj->save;
    }

    return $obj;
}

1;
