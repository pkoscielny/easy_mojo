package Model::DB::Util;

use strict;
use warnings;

use Cwd;
use YAML::XS;
use Data::Dumper;

use base qw( Exporter );
our @EXPORT_OK = qw/
    get_db_config
/;
our @EXPORT = @EXPORT_OK;


sub get_db_config {
    # my (%params) = @_;

    my $db_config_path = Cwd::realpath() . '/config/model/db.yml';
    my $db_config_yaml = YAML::XS::LoadFile($db_config_path);
    my $db_config_env = _get_db_config_env();

    while (my ($dsn, $rh_config) = each %$db_config_yaml) {

        # Fields validation.
        _validate_fields($rh_config);

        # Get config from env variables and add/override YAML variables:
        my $rh_config_env = $db_config_env->{$dsn} || {};
        while (my ($key, $val) = each %$rh_config_env) {
            $rh_config->{$key} = $val;
        }

        print "DB DSN: $dsn: ". Dumper $rh_config if $ENV{MOJO_DB_DEBUG};
    }

    return $db_config_yaml;
}


# Returns rh: dsn --> set of config elements like port, host, username, password, etc.
sub _get_db_config_env {
    my @db_env_vars = grep { index($_, 'MOJO_DB__') >= 0 } keys %ENV;

    my $db_config = {};
    foreach my $var (@db_env_vars) {
        if (my ($dsn, $element) = $var =~ /^MOJO_DB__([^_]+)__(.+)$/) {
            my $value = $ENV{$var};
            # $db_config->{lc $dsn}{lc $element} = $value;
            $db_config->{$dsn}{$element} = $value;
        }
    }

    return $db_config;
}


#TODO: add more fields if needed.
sub _validate_fields {
    my ($rh) = @_;

    foreach my $field (qw(
        driver  
        database  
        domain
    )) {
        die "'$field' field is required" if not exists $rh->{$field};
    }

    return 1;
}


1;