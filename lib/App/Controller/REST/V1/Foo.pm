package App::Controller::REST::V1::Foo;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::DB::Alpha::Foo;
has model => 'Model::DB::Alpha::Foo';


1;
