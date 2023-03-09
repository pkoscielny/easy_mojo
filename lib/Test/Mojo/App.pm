package Test::Mojo::App;

use strict;
use warnings;

use Mojo::Base 'Test::Mojo';
use List::Util 'any';
use Carp 'confess';


#TODO: move keys_to_skip to yaml config. 
my @keys_to_skip = qw(mtime audit);

#TODO: implement stopping alter failed first test.


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


1;