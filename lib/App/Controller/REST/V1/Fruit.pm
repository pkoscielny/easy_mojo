package App::Controller::REST::V1::Fruit;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::DB::ORM::Delta::Fruit;
has model => 'Model::DB::ORM::Delta::Fruit';


1;
