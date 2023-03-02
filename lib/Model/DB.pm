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


__PACKAGE__->use_private_registry;

my $db_config_path = Cwd::realpath() . '/config/model/db.yml';
my $db_config = YAML::XS::LoadFile($db_config_path);


my ($default_domain, $default_type);
while (my ($dsn, $rh_config) = each %$db_config) {
    next if $rh_config->{disabled};

    # Fields validation.
    validate_fields($rh_config);

    $default_type = $dsn;
    $default_domain = $rh_config->{domain};
    __PACKAGE__->register_db(
        type => $dsn, 
        %$rh_config,
    );
}


__PACKAGE__->default_domain($default_domain); 
__PACKAGE__->default_type($default_type); 


#TODO: add more fields if needed.
sub validate_fields {
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