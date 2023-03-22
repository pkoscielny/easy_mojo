package App::Controller::REST;

use strict;
use warnings;

use Mojo::Base 'App::Controller';

use Data::Dumper;

has model => undef;


sub get_related {
    my ($self) = @_;

    my $related = $self->get_param('q.related');

    return $related;
}


sub validate_fields_to_save {
    my ($self, $params) = @_;

    eval {
        $self->model->handle_unwritable_fields($params, die => 1);
    };
    chomp($@) && $self->response_400($@) if $@;
}


sub get_resource {
    my ($self, $id) = @_;

    $id //= $self->param('id');
    my $related = $self->get_related;
    #TODO: implement fetching related objects.

    return $self->model->get_object($id);
}


sub get_resource_list {
    my ($self, %params) = @_;

    my $related = $self->get_related;
    #TODO: select fields
    #TODO: filter by fields/ids
    #TODO: limit
    #TODO: page/offset
    #TODO: fetch related

    return $self->model->get_object_list(%params);
}


sub _get_and_authorize_resource {
    my ($self) = @_;

    my $id = $self->param('id');
    my ($resource, $meta) = $self->get_resource($id);
    $self->response_404 unless $resource;
    $self->log->debug('resource: '. Dumper $resource);

    $self->authorize_resource($resource);

    return ($id, $resource, $meta);
}


###
### REST actions:
###

#TODO: full list implementation:
# meta: items, limit, offset
sub list {
    my ($self) = @_;
    $self->log->info('list');
    
    my $list_params = $self->get_param();
    $self->log->debug('list params: '. Dumper $list_params);

    my ($resource, $meta) = $self->get_resource_list(%$list_params) or $self->response_empty_list;
    
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->response(data => $resource, meta => $meta);
}


sub get {
    my ($self) = @_;
    $self->log->info('get');

    my ($id, $resource, $meta) = $self->_get_and_authorize_resource;
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->response(data => $resource, meta => $meta);
}


sub add {
    my ($self) = @_;
    $self->log->info('add');

    my $params = $self->req->json() or $self->response_400('EMPTY_JSON_PARAMS');
    $self->log->debug('params: '. Dumper $params);

    $self->validate_fields_to_save($params);
    $self->authorize_params($params);

    my ($resource, $meta) = $self->model->add_object($params);
    $self->response_503 unless $resource;
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->response(data => $resource, meta => $meta);
}


sub update {
    my ($self) = @_;
    $self->log->info('update');

    my ($id, $resource, $meta) = $self->_get_and_authorize_resource;

    my $params = $self->req->json() or $self->response_400('EMPTY_JSON_PARAMS');
    $self->log->debug('params: '. Dumper $params);

    $self->validate_fields_to_save($params);
    $self->authorize_params($params);

    ($resource, $meta) = $self->model->update_object($id, $params);
    $self->response_503 unless $resource;
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->response(data => $resource, meta => $meta);
}


sub patch {
    my ($self) = @_;
    $self->log->info('patch');

    $self->update;
}


sub delete {
    my ($self) = @_;
    $self->log->info('delete');

    my ($id, $resource, $meta) = $self->_get_and_authorize_resource;

    ($resource, $meta) = $self->model->delete_object($id);
    $self->response_503 unless $resource;
    $resource = $self->model->filter_out_unreadable_fields($resource);
    
    $self->response(data => $resource, meta => $meta);
}



1;