#!/usr/bin/perl

# MOJO_TEST_EXIT=1 perl t/App/Controller/REST/V1/Baz.pm.t 

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';


###################
## Configuration ##
###################

use Test::More tests => 94;
use Test::NoWarnings;
# use Test::Differences;
# use Test::MockModule;
# use Test::MockObject;
# use Test::Mojo::More;

# Turn off logs.
# Set proper key prefix in Redis.
$ENV{MOJO_MODE} = 'test';

use Test::Mojo::App;

use Model::DB::Redis::Charlie::Baz;

# Cleaning all objects in Redis DB related to these tests.
Model::DB::Redis::Charlie::Baz->delete_objects('*');


###################
##     Tests     ##
###################

# Start a Mojolicious app.
my $t = Test::Mojo::App->new('App');


###
### Testing list action.
###

$t->get_ok('/api/v1/bazs.json')
    ->status_is(200)
    # ->json_is('/meta/items', 0)
    ->json_hasnt('/meta/items')  # to be sure that I won't forget add new tests for the 'items' feature.
    ->data_is([])
    ;

my $objects = [
    { 
        name => 'bar1', 
        more_complex_structure => [
            { 
                field1 => 'abc', 
                field2 => 'bcd',
            }, 
            { 
                field1 => 'cde', 
                field2 => 'def',
            },
        ], 
    },
    { 
        name => 'bar2', 
        another_structure => {
            field3 => 'efg',
        }, 
    },
    { 
        name => 'bar3', 
    },
];
foreach my $object (@$objects) {
    my $new_one = Model::DB::Redis::Charlie::Baz->add_object(%$object);
    $object->{_id} = $new_one->{_id};
}

$t->get_ok('/api/v1/bazs.json')
    ->status_is(200)
    # ->json_is('/meta/items', 3)
    ->data_is($objects)
    ;


###
### Testing get action.
###

foreach my $object (@$objects) {
    $t->get_ok("/api/v1/bazs/$object->{_id}.json")
        ->status_is(200)
        ->json_is('/data' => $object)
        ;
}

$t->get_ok('/api/v1/bazs/not_existing_id.json')
    ->status_is(404)
    ;

### Only get and list are available for this endpoint.


###
### Testing add action.
###

$t->post_ok('/api/v1/bazs.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

my $new_object = { name => 'new_object' };
$t->post_ok('/api/v1/bazs.json' => json => {
        %$new_object,
    })
    ->status_is(200)
    ->data_is($new_object)
    ;
my $new_id = $t->tx->res->json->{data}{_id};
$new_object->{_id} = $new_id;

$t->get_ok("/api/v1/bazs/$new_id.json")
    ->status_is(200)
    ->json_is('/data' => {
        %$new_object,
    })
    ;

push @$objects, $new_object;
$t->get_ok('/api/v1/bazs.json')
    ->status_is(200)
    # ->json_is('/meta/items', 4)
    ->data_is($objects)
    ;


###
### Testing update action.
###

$t->put_ok("/api/v1/bazs/$new_id.json")
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

$new_object->{name} = 'object_updated';
$t->put_ok("/api/v1/bazs/$new_id.json" => json => {
        name => $new_object->{name},
    })
    ->status_is(200)
    ->data_is($new_object)
    ;

$t->get_ok('/api/v1/bazs.json')
    ->status_is(200)
    # ->json_is('/meta/items', 4)
    ->data_is($objects)
    ;


###
### Testing patch action.
###

$t->patch_ok("/api/v1/bazs/$new_id.json")
    ->status_is(404)
    ;


###
### Testing delete action.
###

$t->delete_ok("/api/v1/bazs/$new_id.json")
    ->status_is(200)
    ->data_is($new_object)
    ;

pop @$objects;
$t->get_ok('/api/v1/bazs.json')
    ->status_is(200)
    # ->json_is('/meta/items', 3)
    ->data_is($objects)
    ;


1;