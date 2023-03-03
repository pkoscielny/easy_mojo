package App::Controller::REST;

use strict;
use warnings;

use Mojo::Base 'App::Controller';

use List::Util qw(any);
use Data::Dumper;


has model => undef;

#TODO: implement other generic actions.
#TODO: Move below subs related to params to separate lib. Plugin Request?

# Try to get parameter with it's value first from GET params and second from POST params.
#TODO: support for array parameters like param[]=1,2,3.
sub get_param {
    my ($self, $name) = @_;

    $self->{params} //= {};

    # All GET and POST params.
    # https://docs.mojolicious.org/Mojo/Message/Request#params
    # Remember about: "Note that this method caches all data, so it should not be called before the entire request body has been received. 
    # Parts of the request body need to be loaded into memory to parse POST parameters, so you have to make sure it is not excessively large. 
    # There's a 16MiB limit for requests by default."
    unless (exists $self->{params}{req}) {
        $self->{params}{req} = $self->tx->req->params->to_hash;
    }
    return $self->{params}{req}{$name} if defined $name and exists $self->{params}{req}{$name};

    # Params from POST JSON.
    unless (exists $self->{params}{json}) {
        $self->{params}{json} = $self->req->json;
    }
    return $self->{params}{json}{$name} if defined $name and exists $self->{params}{json}{$name};

    # If there is no param $name return all params.
    # Join req and POST params together (let's say that the reg is more important).
    unless (exists $self->{params}{all}) {
        $self->{params}{all} = \(%{$self->{params}{json}}, %{$self->{params}{req}});
    }

    return $self->{params}{all};

    # Split param path by separator.
#     my @params = split ',', $path; # path -> name
#     return undef unless @params;
#     my $req_params = $self->tx->req->params->to_hash;
# $self->dump('params array', @params, $req_params);

#     my $param = $req_params->{ shift @params } or return undef;
# $self->dump('params 1', $param);

#     foreach my $element (@params) {
#         $param = $param->{$element} or return undef;
#     }

    # return $param;
}


sub get_related {
    my ($self) = @_;

    my $related = $self->get_param('q.related');

    return $related;

    # if (not exists $self->{params}{all}{q} or not exists $self->{params}{all}{q}{with_objects}) {
    #     return wantarray ? () : [];
    # }

    # my $with_objects = $self->{params}{all}{q}{with_objects};
    # if (not $with_objects) {
    #     return wantarray ? () : [];
    # }

    # $with_objects = [ split(',', $with_objects) ] if ref $with_objects ne 'ARRAY';
    # return wantarray ? @$with_objects : $with_objects;
}


#TODO: _authorize_params implementation.
sub _authorize_params {}


sub _validate_fields_to_save {
    my ($self, $params) = @_;

#TODO: where use writable_fields? In REST or in model?
    my %writable_fields = map { $_ => 1 } $self->model->writable_fields;

    $self->response_400('WRONG_JSON_PARAMS') if any { not exists $writable_fields{$_} } keys %$params;
}


sub _get_resource {
    my ($self) = @_;

    my $id = $self->param('id');
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


### end

#TODO: lot of boulerplate below. Refactoring needed. Similar to Ruby on Rails?

#TODO: full list implementation.
sub list {
    my ($self) = @_;
    $self->log->info('list');
    
    my $list_params = $self->get_param();
    $self->log->debug('list params: '. Dumper $list_params);

    my $resource = $self->get_resource_list(%$list_params); # || $self->response_empty_list;
    
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->response(data => $resource);
}


sub get {
    my ($self) = @_;
    $self->log->info('get');

    # Gets an object by id or 404.
    my $resource = $self->_get_resource || $self->response_404;
    $self->log->debug('resource: '. Dumper $resource);

    $self->_authorize_params($resource);
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->response(data => $resource);
}


sub add {
    my ($self) = @_;
    $self->log->info('add');

    my $params = $self->req->json || $self->response_400('EMPTY_JSON_PARAMS');
    $self->log->debug('params: '. Dumper $params);

    $self->_validate_fields_to_save($params);
    $self->_authorize_params($params);

    my $resource = $self->model->add_object(%$params);
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->log->debug('added object: '. Dumper $resource);
    $self->response(data => $resource);
}


sub update {
    my ($self) = @_;
    $self->log->info('update');

    my $id = $self->param('id');
    my $resource = $self->_get_resource() || $self->response_404;

    my $params = $self->req->json || $self->response_400('EMPTY_JSON_PARAMS');
    $self->log->debug('params: '. Dumper $params);

    $self->_validate_fields_to_save($params);
    $self->_authorize_params($params);

    $resource = $self->model->update_object($id, %$params);
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->response(data => $resource);
}


#TODO: to implement.
sub patch {
    my ($self) = @_;
    $self->log->info('patch');

    my $resource = $self->_get_resource() || $self->response_404;
    # $self->log->debug('PARAMS: ', Dumper $params);

    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->response(data => $resource);
}


sub delete {
    my ($self) = @_;
    $self->log->info('delete');

    my $id = $self->param('id');
    my $resource = $self->_get_resource() || $self->response_404;

    $self->_authorize_params($resource);

    $resource = $self->model->delete_object($id);
    $resource = $self->model->filter_out_unreadable_fields($resource);

    $self->log->debug('deleted object: '. Dumper $resource);
    $self->response(data => $resource);
}



1;