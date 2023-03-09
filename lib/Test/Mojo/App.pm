package Test::Mojo::App;

use strict;
use warnings;

use Mojo::Base 'Test::Mojo';
use List::Util 'any';
use Carp 'confess';

use Model::DB::Util;

#TODO: move keys_to_skip to separate config. 
my @keys_to_skip = qw(mtime audit);
my $test_db_path = 'db_test';


# Works like json_is but it can skip some kind of fields like datetime.
sub data_is {
    my ($self,  
        $struct, # structure to check (hashref, arrayref). 
        $path,   # JSON path. Optional parameter.
    ) = @_;

    # Starting path.
    $path //= '/data';

    # Hash.
    if (ref $struct eq 'HASH' and %$struct) {
        while (my ($key, $value) = each %$struct) {
            next if any { $_ eq $key } @keys_to_skip;
            
            $self->data_is($value, "$path/$key");
        }
    }
    # Array.
    elsif (ref $struct eq 'ARRAY' and @$struct) {
        for (my $i=0; $i < scalar @$struct; $i++) {
            $self->data_is($struct->[$i], "$path/$i");
        }
    }
    # Scalar or empty hash or empty array.
    else {
        $self->json_is($path, $struct, $path);
    }

    return $self;
}


sub new {
    my ($class, $name) = @_;
    $name //= 'App';

    my $t = $class->SUPER::new($name);

    # By default speak in JSON.
    $t->ua->on(start => sub {
        my ($ua, $tx) = @_;
        $tx->req->headers->header( 'Accept' => 'application/json' );
    });

    return $t;
}


# Prepare env variables for tests.
sub prepare_test_env {
    my ($class) = @_;

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
        mysql    => sub { confess "Implementation for mysql test env generator required" },
        postgres => sub { confess "Implementation for postgres test env generator required" },
        redis    => sub { confess "Implementation for redis test env generator required" },
        # ...
    );

    my $db_config = get_db_config();
    while (my ($dsn, $rh_config) = each %$db_config) {

        my $driver = $rh_config->{driver};

        # Run test env generator for specific driver.
        $env_generators{$driver}->($dsn, $rh_config) if exists $env_generators{$driver};
    }

}


1;