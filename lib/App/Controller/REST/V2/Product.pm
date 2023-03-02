package App::Controller::REST::V2::Product;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::API::DummyJSON::Product;
has model => 'Model::API::DummyJSON::Product';


1;
