package App::Controller::REST::V2::Post;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::API::JSONPlaceholder::Post;
has model => 'Model::API::JSONPlaceholder::Post';



1;
