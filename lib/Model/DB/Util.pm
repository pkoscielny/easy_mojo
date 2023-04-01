package Model::DB::Util;

use strict;
use warnings;

use Cwd;
use YAML::XS;
use Carp 'confess';
use File::Copy;
use Data::Dumper;
use List::Util qw( none );
use Dotenv -load => 'config/.env';

use base qw( Exporter );
our @EXPORT_OK = qw/
    get_db_config
    prepare_test_db_env
    prepare_test_db_from_cache
    cache_test_db
/;
our @EXPORT = @EXPORT_OK;

my $test_db_path = 'db_test';
my $config_file = 'config/model/db.yml';
my %supported_db_types = (
    orm   => [qw/ pg mysql mariadb informix oracle sqlite /],  # https://metacpan.org/pod/Rose::DB
    redis => [qw/ redis /],
    # ...
);


sub get_db_config {
    my ($db_type) = @_;

    my $drivers = [];
    if ($db_type) {
        $drivers = $supported_db_types{ $db_type } or confess "Not supported model db config: $db_type";
    } 
    else {
        push @$drivers, map { @$_ } values %supported_db_types;
    }

    my $db_config_path = Cwd::realpath() ."/$config_file";
    my $db_config_yaml = YAML::XS::LoadFile($db_config_path);
    my $db_config_env = _get_db_config_env();

    my $db_config = {};
    while (my ($dsn, $rh_config) = each %$db_config_yaml) {
        next if none { $rh_config->{driver} eq $_ } @$drivers;

        # Fields validation.
        _validate_fields($rh_config);

        # Get config from env variables and add/override YAML variables:
        my $rh_config_env = $db_config_env->{$dsn} || {};
        while (my ($key, $val) = each %$rh_config_env) {
            $rh_config->{$key} = $val;
        }

        print "DB DSN: $dsn: ". Dumper $rh_config if $ENV{MOJO_DB_DEBUG};
        $db_config->{ $dsn } = $rh_config;
    }

    return $db_config;
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


sub _validate_fields {
    my ($rh) = @_;

    foreach my $field (qw(
        driver  
    )) {
        confess "'$field' field is required" if not exists $rh->{$field};
    }

    return 1;
}


# Prepare env variables for tests.
sub prepare_test_db_env {

    sub _prepare_env {
        my ($dsn, $param, $value) = @_;

        $ENV{"MOJO_DB__${dsn}__${param}"} = $value;
    }

    my %env_generators = (
        sqlite => sub {
            my ($dsn, $rh_config) = @_;
            my $db_name = (split '/', $rh_config->{database})[-1];
            my $test_database = "$test_db_path/$db_name";
            _prepare_env($dsn, 'database', $test_database);
            _prepare_env($dsn, 'domain', 'test');
        }, 
        pg => sub { 
            my ($dsn, $rh_config) = @_;
            my $test_database = 'test_'. $rh_config->{database};
            _prepare_env($dsn, 'database', $test_database);
            _prepare_env($dsn, 'domain', 'test');
        },
        mysql => sub { confess "Implementation for mysql test env generator required" },
        # ...
    );

    my $db_config = get_db_config();
    while (my ($dsn, $rh_config) = each %$db_config) {

        my $driver = $rh_config->{driver};

        # Run test env generator for specific driver.
        $env_generators{$driver}->($dsn, $rh_config) if exists $env_generators{$driver};
    }

}


sub prepare_test_db_from_cache {

    # For SQLite.
    my $cache_path = "$test_db_path/cache";
    if (-e $cache_path) {
        copy($_, $test_db_path) or confess "Copy failed: $!" for glob "$cache_path/*.db";
    }

}


sub cache_test_db {

    # For SQLite.
    my $cache_path = "$test_db_path/cache";
    mkdir $cache_path or confess "Make dir $cache_path failed: $!" unless -e $cache_path;
    copy($_, $cache_path) or confess "Copy failed: $!" for glob "$test_db_path/*.db";

}


1;
