use 5.014;
use strict;
use warnings;
use ExtUtils::MakeMaker;

BEGIN {
    eval "use File::ShareDir::Install;";
    $@ and die $@;
}

use File::ShareDir::Install;
install_share dist => "share";

WriteMakefile(
    NAME             => 'Quant::Framework',
    AUTHOR           => q{Binary.com <support@binary.com>},
    VERSION_FROM     => 'lib/Quant/Framework.pm',
    ABSTRACT_FROM    => 'lib/Quant/Framework.pm',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.014,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Moose' => 0,
        'YAML::XS' => 0,
        'File::ShareDir' => 0,
        'Test::More' => 0,
        'Test::CheckManifest' => 1.29,
        'Test::Exception' => 0,
        'Test::NoWarnings' => 0,
        'Date::Utility' => 0,
        'Data::Chronicle::Writer' => 0,
        'Data::Chronicle::Reader' => 0,
        'Data::Chronicle::Mock' => 0,
    },
    PREREQ_PM => {
        'Moose' => 0,
        'YAML::XS' => 0,
        'File::ShareDir' => 0,
        'Date::Utility' => 0,
        'Data::Chronicle::Writer' => 0,
        'Data::Chronicle::Reader' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Quant-Framework-*' },
);

{
    package MY;
    use File::ShareDir::Install qw(postamble);
}
