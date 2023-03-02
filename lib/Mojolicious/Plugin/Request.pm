package Mojolicious::Plugin::Request;

use strict;
use warnings;

use base 'Mojolicious::Plugin';


sub register {
    my ($self, $app) = @_;

    # Taken from: https://gist.github.com/kraih/6602913
    # It doesn't work for NON-blocking operactions.
    $app->helper(
        stop => sub { die "MOJO_STOP_PROCESSING_REQUEST\n" }
    );

    $app->hook(
        around_dispatch => sub {
            my ($next) = @_;

            return if eval { $next->(); 1 };
            die $@ unless $@ eq "MOJO_STOP_PROCESSING_REQUEST\n";
        }
    );
}


1;