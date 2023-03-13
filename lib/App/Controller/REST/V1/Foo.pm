package App::Controller::REST::V1::Foo;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::DB::ORM::Alpha::Foo;
has model => 'Model::DB::ORM::Alpha::Foo';


# Reimplement 'get' or any orher action if needed.
# sub get {
#     my ($self) = @_;
#     $self->log->info('get');
#     # Do everything what you want.
#     ...
#     $self->response(data => $resource);
# }


1;
