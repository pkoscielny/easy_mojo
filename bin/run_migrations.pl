#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

use Model::DB::Util;
use Test::Mojo::App;

# Getting script arguments.
my %args;
GetOptions(
    't|test'    => \$args{test},
    'v|verbose' => \$args{verbose},
    'help|?'    => \$args{help},
);
pod2usage(1) and exit if $args{help};


# Bunch of setting for tests.
my $contexts = '';
if ($args{test}) {
    Test::Mojo::App->prepare_test_env();

    $contexts = " --contexts='!data'";
} 

my $db_config = get_db_config();
print "db config: ", Dumper $db_config if $args{verbose};

while (my ($dsn, $rh_config) = each %$db_config) {
    my $cmd = qq{
        docker run --rm \\
            -v $Bin/..:/easy_mojo liquibase_with_mysql:4.19 \\
            --url='jdbc:sqlite:/easy_mojo/$rh_config->{database}' \\
            --classpath=/easy_mojo/db_migrations/$dsn \\
            --changelog-file=changelog.xml \\
            update $contexts
    };
    print $cmd if $args{verbose};

    system $cmd;
}


1;


__END__

=pod

=head1 NAME

 run_migrations.pl

=head1 SYNOPSIS

 Script for running migrations on databases taken from db.yml configuration.
  
=head1 EXAMPLES

 $ perl bin/run_migrations.pl
 $ perl bin/run_migrations.pl --help
 $ perl bin/run_migrations.pl --test --verbose

=head1 OPTIONS

=over 2

=item --test|t

 Run migrations for test databases.

=item --verbose|v

 Turn on verbosity mode

=item --help|-h|-?

 Prints this help

=back

=head1 AUTHOR

 Pawel Koscielny (pkoscielny)

=cut
