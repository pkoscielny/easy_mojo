package App::Controller::REST::V1::Bar;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::DB::Bravo::Bar;
has model => 'Model::DB::Bravo::Bar';


sub custom_action1 {
    my ($self) = @_;

    my $id = $self->param('id');
    my $name= $self->param('name');
    $self->response(data => {id => $id, name => $name});
}

sub custom_action2 {
    my ($self) = @_;

    $self->response(data => {test => 'custom_action2'});
}


1;
