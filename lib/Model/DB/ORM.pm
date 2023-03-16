package Model::DB::ORM;

# Based on Rose DB best practices:
# https://metacpan.org/pod/Rose::DB::Tutorial
# https://metacpan.org/dist/Rose-DB-Object/view/lib/Rose/DB/Object/Tutorial.pod

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::DB::ORM;'

use strict;
use warnings;

use base qw(Rose::DB);
our @ISA = qw(Rose::DB);

use Model::DB::Util;

__PACKAGE__->use_private_registry;


my $db_config = get_db_config('orm');

my ($default_domain, $default_type);
while (my ($dsn, $rh_config) = each %$db_config) {

    $default_type = $dsn;
    $default_domain = $rh_config->{domain};
    __PACKAGE__->register_db(
        type => $dsn, 
        %$rh_config,
    );
}


__PACKAGE__->default_domain($default_domain); 
__PACKAGE__->default_type($default_type); 


1;
