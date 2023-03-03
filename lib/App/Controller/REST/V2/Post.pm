package App::Controller::REST::V2::Post;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::WSGateway::JSONPlaceholder::Post;
has model => 'Model::WSGateway::JSONPlaceholder::Post';



1;
