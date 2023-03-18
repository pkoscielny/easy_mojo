#!/usr/bin/perl

# carton exec perl t/App/Controller/REST/V2/Product.pm.t

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';

###################
## Configuration ##
###################

use Test::More tests => 83;
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
require Model::WSGateway::DummyJSON::Product;


# Mocking object for Mojo::UserAgent.
my $ua_mock = Test::Model::WSGateway->ua_mock;

my $ws_gateway = new Test::MockModule('Model::WSGateway');
$ws_gateway->redefine('ua', sub {$ua_mock});

my $product_1 = {
    "brand" => "Apple",
    "category" => "smartphones",
    "description" => "An apple mobile which is nothing like apple",
    "discountPercentage" => 12.96,
    "id" => 1,
    "images" => [
      "https://i.dummyjson.com/data/products/1/1.jpg",
      "https://i.dummyjson.com/data/products/1/2.jpg",
      "https://i.dummyjson.com/data/products/1/3.jpg",
      "https://i.dummyjson.com/data/products/1/4.jpg",
      "https://i.dummyjson.com/data/products/1/thumbnail.jpg"
    ],
    "price" => 549,
    "rating" => 4.69,
    "stock" => 94,
    "thumbnail" => "https://i.dummyjson.com/data/products/1/thumbnail.jpg",
    "title" => "iPhone 9",
};

my $product_2 = {
    "brand" => "Apple",
    "category" => "smartphones",
    "description" => "SIM-Free, Model A19211 6.5-inch Super Retina HD display with OLED technology A12 Bionic chip with ...",
    "discountPercentage" => 17.94,
    "id" => 2,
    "images" => [
      "https://i.dummyjson.com/data/products/2/1.jpg",
      "https://i.dummyjson.com/data/products/2/2.jpg",
      "https://i.dummyjson.com/data/products/2/3.jpg",
      "https://i.dummyjson.com/data/products/2/thumbnail.jpg"
    ],
    "price" => 899,
    "rating" => 4.44,
    "stock" => 34,
    "thumbnail" => "https://i.dummyjson.com/data/products/2/thumbnail.jpg",
    "title" => "iPhone X",
};

my $new_product = { 
    title => 'new product', 
};

my $updated_product = {
    title => 'updated product', 
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
$t->get_ok('/api/v2/products.json')
    ->status_is(200)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json([$product_2, $product_1]);
$t->get_ok('/api/v2/products.json')
    ->status_is(200)
    ->data_is([$product_2, $product_1])
    ;

###
### Testing get action.
###

$ua_mock->is_success(0);
$t->get_ok('/api/v2/products/1.json')
    ->status_is(404)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json($product_1);
$t->get_ok('/api/v2/products/1.json')
    ->status_is(200)
    ->data_is($product_1)
    ;


###
### Testing add action.
###

$t->post_ok('/api/v2/products.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

$t->post_ok('/api/v2/products.json' => json => {
        id => 4,  # invalid field to write.
    })
    ->status_is(400)
    ->json_is('/message', 'WRONG_ID_FIELD')
    ;

$ua_mock->is_success(0);
$t->post_ok('/api/v2/products.json' => json => {
        %$new_product,
    })
    ->status_is(503)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json($new_product);
$t->post_ok('/api/v2/products.json' => json => {
        %$new_product,
    })
    ->status_is(200)
    ->data_is($new_product)
    ;


###
### Testing update action.
###

$t->put_ok('/api/v2/products/1.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

$t->put_ok('/api/v2/products/1.json' => json => {
        id => 4,  # invalid field to write.
    })
    ->status_is(400)
    ->json_is('/message', 'WRONG_ID_FIELD')
    ;

$ua_mock->is_success(0);
$t->put_ok('/api/v2/products/1.json' => json => {
        %$updated_product,
    })
    ->status_is(404)
    ->data_is(undef)
    ;

$ua_mock->is_success(1);
$ua_mock->json($updated_product);
$t->put_ok('/api/v2/products/1.json' => json => {
        %$updated_product,
    })
    ->status_is(200)
    ->data_is($updated_product)
    ;


###
### Testing patch action.
###

$t->patch_ok('/api/v2/products/1.json')
    ->status_is(404)
    ;


###
### Testing delete action.
###

$t->delete_ok('/api/v2/products/1.json')
    ->status_is(404)
    ;


1;