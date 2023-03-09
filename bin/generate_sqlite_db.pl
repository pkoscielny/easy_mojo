#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Getopt::Long;
use Pod::Usage;

use Model::DB::Util;
use Test::Mojo::App;

# Getting script arguments.
my %args;
GetOptions(
    't|test'    => \$args{test},
    'f|force'   => \$args{force},
    'v|verbose' => \$args{verbose},
    'help|?'    => \$args{help},
);
pod2usage(1) and exit if $args{help};


Test::Mojo::App->prepare_test_env() if $args{test};

my $db_config = get_db_config();
my @sqlite_configs = grep { $_->{driver} eq 'sqlite' } values %$db_config;

foreach my $rh_config (@sqlite_configs) {
    my $full_path = $rh_config->{database};
    print "full db path: $full_path\n" if $args{verbose};

    unlink $full_path if -e $full_path and $args{force};

    system "sqlite3 $full_path 'VACUUM;'";
}


1;


__END__

=pod

=head1 NAME

 generate_sqlite_db.pl

=head1 SYNOPSIS

 Script for generating local SQLite databases based on db.yml configuration.
  
=head1 EXAMPLES

 $ perl bin/generate_sqlite_db.pl
 $ perl bin/generate_sqlite_db.pl --help
 $ perl bin/generate_sqlite_db.pl --dir='db_test' -v

=head1 OPTIONS

=over 2

=item --test|t

 Generate test databases.

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
