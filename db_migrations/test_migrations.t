#!/usr/bin/perl

# carton exec 'perl db_migrations/test_migrations.t'
# MOJO_DB_DEBUG=1 carton exec 'perl db_migrations/test_migrations.t'

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';

###################
## Configuration ##
###################

use Test::More tests => 5;
use Test::NoWarnings;

use Model::DB::Util;

# Prepare connections to test databases.
prepare_test_db_env();


###################
##     Tests     ##
###################

# Some SQL queries may cause errors when run multiple times.
# Therefore, it is a good practice to run migrations twice.

my $output = `perl bin/run_migrations.pl --test --verbose 2>&1`;
_check_output($output, "Testing migrations run");

# What if someone wrote a bad rollback? 
# Better is to know about it earlier during unit tests run, not just on production.
$output = `perl bin/run_migrations.pl --test --rollback_to_tag version_0.1 --verbose 2>&1`;
_check_output($output, "Testing migrations rollback to initial state");

$output = `perl bin/run_migrations.pl --test --verbose 2>&1`;
_check_output($output, "Testing migrations run - again");

$output = `perl bin/run_migrations.pl --test --rollback_to_tag version_0.1 --verbose 2>&1`;
_check_output($output, "Testing migrations rollback to initial state - again");

sub _check_output {
    my ($output, $message) = @_;

    my ($is_bad) = $output =~ /(Unexpected error running Liquibase:.*)/s;
    ok !$is_bad, $message;
    die $is_bad if $is_bad;
}


1;