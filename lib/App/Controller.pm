package App::Controller;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use YAML::XS;


#TODO: move this to Mojo plugin Request?
# It will be one point responsible for returned structure.
sub generate_response_structure {
    my ($self, %params) = @_;
    #$self->app->log->debug( Dumper $self->{stash} );

    my %response;
    $response{data} = $params{data};
    $response{meta} = $params{meta} || {};
    $response{message} = $params{message} || '';
    #TODO: implement rest of functionality.

    $self->{stash}{response} = \%response;

    return \%response;
}
 
sub response {
    my ($self, %params) = @_;

    my $rh_response = $self->generate_response_structure(%params);
    my $status = $params{status} // 200;

    #TODO: handle csv format.
    # print "res data: ", Dumper $rh_response;  

    # DefaultHelpers plugin.
    # https://docs.mojolicious.org/Mojolicious/Plugin/DefaultHelpers#respond_to
    $self->respond_to(
        json => {json => $rh_response,       status => $status},
        yaml => {text => Dump($rh_response), status => $status},   #TODO: implement proper YAML content type in header.
        #csv  => sub { $self->reply->table($response->{data}) }, #TODO: add CSV options from mojo config.
        any  => {data => '',                 status => 204},
    );
    $self->stop;
}

#TODO: add other handlers: 401?

# 400 handler - bad request. 
sub response_400 {
    my ($self, $message) = @_;

    my %params;
    $params{status} = 400;
    $params{message} = $message;

    $self->response(%params);
}


# 403 handler - not authorized. 
sub response_403 {
    my ($self, $message) = @_;

    my %params;
    $params{status} = 403;
    $params{message} = $message;

    $self->response(%params);
}


# 404 handler - not found. 
sub response_404 {
    my ($self) = @_;

    my %params;
    $params{status} = 404;

    $self->response(%params);
}


sub response_empty_list {
    my ($self) = @_;

    my %params;
    $params{data} = [];

    $self->response(%params);
}


1;