package App::Controller::REST::V2::Category;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::WSGateway::DummyJSON::Product::Category;
has model => 'Model::WSGateway::DummyJSON::Product::Category';



1;
