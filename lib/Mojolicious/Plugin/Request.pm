package Mojolicious::Plugin::Request;

use strict;
use warnings;

use base 'Mojolicious::Plugin';


sub register {
    my ($self, $app, $conf) = @_;

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

    $app->helper(get_param => \&get_param);
}


# Try to get parameter with it's value first from GET params and second from JSON.
# Let say you have a large query exceeding the GET request size limit. In this case you can send these params 
# as JSON in the POST request. 
sub get_param {
    my ($self, 
        $name,   # param name
        %params  # required => 0|1 - if true and there is no param in the request then return response 400 with error token.
    ) = @_;

    $self->{params} //= {};
    # All GET and POST params.
    # https://docs.mojolicious.org/Mojo/Message/Request#params
    # Remember about: "Note that this method caches all data, so it should not be called before the entire request body has been received. 
    # Parts of the request body need to be loaded into memory to parse POST parameters, so you have to make sure it is not excessively large. 
    # There's a 16MiB limit for requests by default."
    unless (exists $self->{params}{req}) {
        my $req_params = $self->tx->req->params->to_hash;
        $req_params    = _handle_square_brackets_params($req_params);
        $self->{params}{req} = $req_params;
    }
    return $self->{params}{req}{$name} if defined $name and exists $self->{params}{req}{$name};
    
    # Params from POST|PUT|PATCH JSON.
    unless (exists $self->{params}{json}) {
        $self->{params}{json} = $self->req->json;
    }
    return $self->{params}{json}{$name} if defined $name and exists $self->{params}{json}{$name};
    
    # If there is no param $name return all params.
    # Join req and POST params together (let's say that the reg is more important).
    unless (exists $self->{params}{all}) {
        $self->{params}{all} = \(%{$self->{params}{json}}, %{$self->{params}{req}});
    }
    return $self->{params}{all} unless $name;
    
    $self->response_400('PARAM_'. uc($name) .'_REQUIRED') if $params{required};
    return undef;


    sub _handle_square_brackets_params {
        my ($req_params) = @_;

        foreach my $param (keys %$req_params) {
            next if index($param, '[]') == -1;

            my $value = delete $req_params->{$param};
            $value = [ split ',', $value ] if $value;

            $param =~ s/\[\]//g;
            $req_params->{$param} = $value;
        }

        return $req_params;
    }
}


1;