package Model::DB;

# Based on Rose DB best practices:
# https://metacpan.org/pod/Rose::DB::Tutorial
# https://metacpan.org/dist/Rose-DB-Object/view/lib/Rose/DB/Object/Tutorial.pod

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::DB;'

use strict;
use warnings;

use base qw(Rose::DB);
our @ISA = qw(Rose::DB);

use Cwd;
use YAML::XS;
use Data::Dumper;

__PACKAGE__->use_private_registry;

my $db_config_path = Cwd::realpath() . '/config/model/db.yml';
my $db_config_yaml = YAML::XS::LoadFile($db_config_path);
my $db_config_env = _get_db_config_env();

my ($default_domain, $default_type);
while (my ($dsn, $rh_config) = each %$db_config_yaml) {

    # Fields validation.
    _validate_fields($rh_config);

    # Get config from env variables and add/override YAML variables:
    my $rh_config_env = $db_config_env->{$dsn} || {};
    $rh_config = { %$rh_config, %$rh_config_env };

    print "DB DSN: $dsn: ". Dumper $rh_config if $ENV{MOJO_DB_DEBUG};

    $default_type = $dsn;
    $default_domain = $rh_config->{domain};
    __PACKAGE__->register_db(
        type => $dsn, 
        %$rh_config,
    );
}


__PACKAGE__->default_domain($default_domain); 
__PACKAGE__->default_type($default_type); 


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