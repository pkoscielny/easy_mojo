package Mojolicious::Plugin::Authenticate;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

# Put here any authentication methods.

sub register {
    my ($self, $app, $conf) = @_;

    $app->helper(authenticate_user => \&authenticate_user);

    # $app->hook(
    #     before_dispatch => sub {
    #         my ($app) = @_;
    #     }
    # );
}


sub authenticate_user {
    my ($self) = @_;
}


1;