package App::Controller::REST::V2::Category;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::API::DummyJSON::Product::Category;
has model => 'Model::API::DummyJSON::Product::Category';



1;
