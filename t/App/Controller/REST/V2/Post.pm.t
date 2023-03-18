#!/usr/bin/perl

# carton exec perl t/App/Controller/REST/V2/Post.pm.t

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';

###################
## Configuration ##
###################

use Test::More tests => 53;
use Test::NoWarnings;
use Test::MockModule;
# use Test::MockObject;
# use Test::Differences;
# use Test::Mojo::More;

# Turn off logs.
$ENV{MOJO_MODE} = 'test';

use Test::Mojo::App;
use Test::Model::WSGateway;

# Should be always via 'require' and always after call prepare_test_db_env().
require Model::WSGateway::JSONPlaceholder::Post;


# Mocking object for Mojo::UserAgent.
my $ua_mock = Test::Model::WSGateway->ua_mock;

my $ws_gateway = new Test::MockModule('Model::WSGateway');
$ws_gateway->redefine('ua', sub {$ua_mock});

my $object_1 = {
    "userId" => 1,
    "id" => 1,
    "title" => "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body" => "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
};

my $object_2 = {
    "userId" => 2,
    "id" => 11,
    "title" => "et ea vero quia laudantium autem",
    "body" => "delectus reiciendis molestiae occaecati non minima eveniet qui voluptatibus\naccusamus in eum beatae sit\nvel qui neque voluptates ut commodi qui incidunt\nut animi commodi"
};

my $new_object = { 
    title => 'new post', 
};

my $updated_object = {
    title => 'updated post', 
};


###################
##     Tests     ##
###################

# Start a Mojolicious app.
my $t = Test::Mojo::App->new('App');


###
### Testing list action.
###

$ua_mock->is_success(0);
$t->get_ok('/api/v2/posts.json')
    ->status_is(200)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json([$object_2, $object_1]);
$t->get_ok('/api/v2/posts.json')
    ->status_is(200)
    ->data_is([$object_2, $object_1])
    ;

###
### Testing get action.
###

$ua_mock->is_success(0);
$t->get_ok('/api/v2/posts/1.json')
    ->status_is(404)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json($object_1);
$t->get_ok('/api/v2/posts/1.json')
    ->status_is(200)
    ->data_is($object_1)
    ;


###
### Testing add action.
###

$t->post_ok('/api/v2/posts.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

$t->post_ok('/api/v2/posts.json' => json => {
        id => 4,  # invalid field to write.
    })
    ->status_is(400)
    ->json_is('/message', 'WRONG_ID_FIELD')
    ;

$ua_mock->is_success(0);
$t->post_ok('/api/v2/posts.json' => json => {
        %$new_object,
    })
    ->status_is(503)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json($new_object);
$t->post_ok('/api/v2/posts.json' => json => {
        %$new_object,
    })
    ->status_is(200)
    ->data_is($new_object)
    ;


###
### Testing update action.
###

$t->put_ok('/api/v2/posts/1.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

$t->put_ok('/api/v2/posts/1.json' => json => {
        id => 4,  # invalid field to write.
    })
    ->status_is(400)
    ->json_is('/message', 'WRONG_ID_FIELD')
    ;

$ua_mock->is_success(0);
$t->put_ok('/api/v2/posts/1.json' => json => {
        %$updated_object,
    })
    ->status_is(404)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json($updated_object);
$t->put_ok('/api/v2/posts/1.json' => json => {
        %$updated_object,
    })
    ->status_is(200)
    ->data_is($updated_object)
    ;


###
### Testing patch action.
###

$t->patch_ok('/api/v2/posts/1.json')
    ->status_is(404)
    ;


###
### Testing delete action.
###

$ua_mock->is_success(0);
$t->delete_ok('/api/v2/posts/1.json')
    ->status_is(404)
    ;

$ua_mock->is_success(1);
$ua_mock->json($object_1);
$t->delete_ok('/api/v2/posts/1.json')
    ->status_is(200)
    ->data_is($object_1)
    ;


1;