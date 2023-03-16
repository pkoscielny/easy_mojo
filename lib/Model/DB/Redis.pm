package Model::DB::Redis;

use strict;
use warnings;

use Redis;
use Carp 'confess';

use Model::DB::Util;

use base qw( Exporter );
our @EXPORT_OK = qw/
    get_redis_connection
/;
our @EXPORT = @EXPORT_OK;


# Make and cache all connections to Redis databases.

my $db_config = get_db_config('redis');

while (my ($dsn, $rh_config) = each %$db_config) {
    get_redis_connection($dsn, $rh_config);
}

my %conn_cache;
sub get_redis_connection {
    my ($dsn, $rh_config) = @_;

    return $conn_cache{ $dsn } if exists $conn_cache{ $dsn };

    $conn_cache{ $dsn } = eval {
        Redis->new(%$rh_config);
    };
    if ($@) {
        confess "Connect to Redis failed: $@";
        return undef;
    }

    return $conn_cache{ $dsn };
}



1;