#!/usr/bin/perl

# carton exec perl t/App/Controller/REST/V2/Category.pm.t

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';

###################
## Configuration ##
###################

use Test::More tests => 36;
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
require Model::WSGateway::DummyJSON::Product::Category;


# Mocking object for Mojo::UserAgent.
my $ua_mock = Test::Model::WSGateway->ua_mock;

my $ws_gateway = new Test::MockModule('Model::WSGateway');
$ws_gateway->redefine('ua', sub {$ua_mock});

my $objects = [
    "smartphones",
    "laptops",
    "fragrances",
    "skincare",
    "groceries",
    "home-decoration",
    "furniture",
    "tops",
    "womens-dresses",
    "womens-shoes",
    "mens-shirts",
    "mens-shoes",
    "mens-watches",
    "womens-watches",
    "womens-bags",
    "womens-jewellery",
    "sunglasses",
    "automotive",
    "motorcycle",
    "lighting",
];


###################
##     Tests     ##
###################

# Start a Mojolicious app.
my $t = Test::Mojo::App->new('App');


###
### Testing list action.
###

$ua_mock->is_success(0);
$t->get_ok('/api/v2/categorys.json')
    ->status_is(200)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json($objects);
$t->get_ok('/api/v2/categorys.json')
    ->status_is(200)
    ->data_is($objects)
    ;


###
### Testing get action.
###

$t->get_ok('/api/v2/categorys/1.json')
    ->status_is(404)
    ;


###
### Testing add action.
###

$t->post_ok('/api/v2/categorys.json')
    ->status_is(404)
    ;


###
### Testing update action.
###

$t->put_ok('/api/v2/categorys/1.json')
    ->status_is(404)
    ;


###
### Testing patch action.
###

$t->patch_ok('/api/v2/categorys/1.json')
    ->status_is(404)
    ;


###
### Testing delete action.
###

$t->delete_ok('/api/v2/categorys/1.json')
    ->status_is(404)
    ;


1;