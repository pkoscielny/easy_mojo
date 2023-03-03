package App::Controller::REST::V2::Product;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::WSGateway::DummyJSON::Product;
has model => 'Model::WSGateway::DummyJSON::Product';


1;
