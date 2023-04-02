#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Getopt::Long;
use Pod::Usage;

use Model::DB::Util;

# Getting script arguments.
my %args;
GetOptions(
    't|test'    => \$args{test},
    'f|force'   => \$args{force},
    'v|verbose' => \$args{verbose},
    'help|?'    => \$args{help},
);
pod2usage(1) and exit if $args{help};


prepare_test_db_env() if $args{test};


my $dbh = get_admin_dbh('pg');
my $db_config = get_db_config('orm');
my @pg_configs = grep { $_->{driver} eq 'pg' } values %$db_config;

foreach my $rh_config (@pg_configs) {
    my $db_name = $rh_config->{database};

    if ($args{force}) {
        print "Drop database if exists: $db_name\n" if $args{verbose};
        $dbh->do("DROP DATABASE IF EXISTS $db_name") or die $dbh->errstr;
    }

    if ($dbh->selectcol_arrayref("SELECT COUNT(*) FROM pg_database WHERE datname = '$db_name'")->[0]) {
        print "Database exists: $db_name\n" if $args{verbose};
    } else {
        print "Create database: $db_name\n" if $args{verbose};
        $dbh->do("CREATE DATABASE $db_name") or die $dbh->errstr;
    }
}

$dbh->disconnect or warn $dbh->errstr;

1;


__END__

=pod

=head1 NAME

 generate_pg_db.pl

=head1 SYNOPSIS

 Script for generating PostgreSQL databases based on config/model/db.yml configuration.
  
=head1 EXAMPLES

 $ perl bin/generate_sqlite_db.pl
 $ perl bin/generate_sqlite_db.pl --help
 $ perl bin/generate_sqlite_db.pl --test --force -v

=head1 OPTIONS

=over 2

=item --test|t

 Create a test Postgres databases.

=item --force|f

 Remove old database if exists (regenerate).

=item --verbose|v

 Turn on verbosity mode

=item --help|-h|-?

 Prints this help

=back

=head1 AUTHOR

 Pawel Koscielny (pkoscielny)

=cut
