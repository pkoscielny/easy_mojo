package App::Controller::REST::V1::Baz;

use strict;
use warnings;

use Mojo::Base 'App::Controller::REST';

use Model::DB::Redis::Charlie::Baz;
has model => 'Model::DB::Redis::Charlie::Baz';


1;
