package Test::Mojo::App;

use strict;
use warnings;

use Mojo::Base 'Test::Mojo';
use List::Util 'any';
use Carp 'confess';

#TODO: move keys_to_skip to yaml config. 
my @keys_to_skip = qw(mtime audit);


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


# Reimplement 'test' method and add new feature: exit when test failed.
# It is useful if you have a lot of tests, many failed  and you want to fix them one by one.
sub test {
    my ($self, $name, @args) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 3;
    my $result = $self->success(!!$self->handler->($name, @args));

    exit if $ENV{MOJO_TEST_EXIT} and not $self->success;

    return $result;
}


1;