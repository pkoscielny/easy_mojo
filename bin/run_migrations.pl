#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

use Model::DB::Util;

# Getting script arguments.
my %args;
GetOptions(
    't|test'              => \$args{test},
    'r|rollback_to_tag=s' => \$args{rollback_to_tag},
    'v|verbose'           => \$args{verbose},
    'help|?'              => \$args{help},
);
pod2usage(1) and exit if $args{help};


# Bunch of setting for tests.
my $contexts = '';
if ($args{test}) {
    prepare_test_db_env();

    $contexts = " --contexts='!data'";
} 

my $hide_stderr = $args{verbose} ? '' : '2>/dev/null';
my $action = $args{rollback_to_tag} ? "rollback --tag=$args{rollback_to_tag}" : 'update';
my $db_config = get_db_config('orm');
print "db config: ", Dumper $db_config if $args{verbose};

my %generate_url_by_driver = (
    sqlite => sub { "jdbc:sqlite:/easy_mojo/$_[0]{database}" },
    pg => sub { "jdbc:postgresql://$_[0]{host}/$_[0]{database}?user=$_[0]{username}&password=$_[0]{password}" },
    mysql => sub {},  # TODO: add support for mysql if needed.
);

while (my ($dsn, $rh_config) = each %$db_config) {
    my $url_generator = $generate_url_by_driver{ $rh_config->{driver} } or next;
    my $jdbc_url = $url_generator->($rh_config);

    my $cmd = qq{
        liquibase \\
            --url='$jdbc_url' \\
            --classpath=/easy_mojo/db_migrations/$dsn \\
            --changelog-file=changelog.xml \\
            $action $contexts $hide_stderr
    };
    print $cmd if $args{verbose};
    system $cmd and die "Liquibase died: $dsn";
}




1;


__END__

=pod

=head1 NAME

 run_migrations.pl

=head1 SYNOPSIS

 Script for running migrations on databases taken from config/model/orm.yml configuration.
  
=head1 EXAMPLES

 $ perl bin/run_migrations.pl
 $ perl bin/run_migrations.pl --help
 $ perl bin/run_migrations.pl --rollback_to_tag version_0.1
 $ perl bin/run_migrations.pl --test --verbose
 $ perl bin/run_migrations.pl --test --rollback_to_tag version_0.1

=head1 OPTIONS

=over 2

=item --test|t

 Run migrations for test databases.

=item --rollback_to_tag|r

 Run rollback to a specific tag.

=item --verbose|v

 Turn on verbosity mode

=item --help|-h|-?

 Prints this help

=back

=head1 AUTHOR

 Pawel Koscielny (pkoscielny)

=cut
