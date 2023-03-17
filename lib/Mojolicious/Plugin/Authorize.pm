package Mojolicious::Plugin::Authorize;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

# Put here any authorization methods for REST resources.

sub register {
    my ($self, $app, $conf) = @_;

    $app->helper(authorize_params   => \&authorize_params);
    $app->helper(authorize_resource => \&authorize_resource);
}


sub authorize_params {
    my ($self) = @_;
}


sub authorize_resource {
    my ($self) = @_;
}


1;