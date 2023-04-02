#!/usr/bin/perl

# carton exec perl t/App/Controller/REST/V1/Fruit.pm.t

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';

###################
## Configuration ##
###################

use Clone 'clone';
use Test::More tests => 88;
use Test::NoWarnings;
# use Test::Differences;
# use Test::MockModule;
# use Test::MockObject;
# use Test::Mojo::More;

# Turn off logs.
$ENV{MOJO_MODE} = 'test';

use Test::Mojo::App;
use Model::DB::Util;

# Prepare connections to test databases.
prepare_test_db_env();

# Quick copy of freshly prepared test databases.
prepare_test_db_from_cache();

# Should be always via 'require' and always after call prepare_test_db_env().
# See Model::DB::ORM implementation for explanation.
require Model::DB::ORM::Delta::Fruit;


###################
##     Tests     ##
###################

# Start a Mojolicious app.
my $t = Test::Mojo::App->new('App');


###
### Testing list action.
###

$t->get_ok('/api/v1/fruits.json')
    ->status_is(200)
    # ->json_is('/meta/items', 0)
    ->json_hasnt('/meta/items')  # to be sure that I won't forget add new tests for the 'items' feature.
    ->data_is([])
    ;

my $fruits = [
    { id => 1, name => 'fruit1' },
    { id => 2, name => 'fruit2' },
    { id => 3, name => 'fruit3' },
];
Model::DB::ORM::Delta::Fruit->add_object(clone $_) for @$fruits;

$t->get_ok('/api/v1/fruits.json')
    ->status_is(200)
    # ->json_is('/meta/items', 3)
    ->data_is($fruits)
    ;


###
### Testing get action.
###

foreach my $fruit (@$fruits) {
    $t->get_ok("/api/v1/fruits/$fruit->{id}.json")
        ->status_is(200)
        ->json_is('/data' => $fruit)
        ;
}

$t->get_ok('/api/v1/fruits/4.json')
    ->status_is(404)
    ;

### Only get and list are available for this endpoint.


###
### Testing add action.
###

$t->post_ok('/api/v1/fruits.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

my $new_fruit = { name => 'new_fruit' };
$t->post_ok('/api/v1/fruits.json' => json => {
        %$new_fruit,
        id => 4,  # invalid field to write.
    })
    ->status_is(400)
    ->json_is('/message', 'WRONG_ID_FIELD')
    ;

$t->post_ok('/api/v1/fruits.json' => json => {
        %$new_fruit,
    })
    ->status_is(200)
    ->data_is($new_fruit)
    ;

$t->get_ok("/api/v1/fruits/4.json")
    ->status_is(200)
    ->json_is('/data' => {
        %$new_fruit,
        id => 4,
    })
    ;

push @$fruits, $new_fruit;
$t->get_ok('/api/v1/fruits.json')
    ->status_is(200)
    # ->json_is('/meta/items', 4)
    ->data_is($fruits)
    ;


###
### Testing update action.
###

$t->put_ok('/api/v1/fruits/1.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

my $fruit_to_update = shift @$fruits;
$fruit_to_update->{name} = 'fruit1_updated';
$t->put_ok('/api/v1/fruits/1.json' => json => {
        name => $fruit_to_update->{name},
    })
    ->status_is(200)
    ->data_is($fruit_to_update)
    ;
push @$fruits, $fruit_to_update;

$t->get_ok('/api/v1/fruits.json')
    ->status_is(200)
    # ->json_is('/meta/items', 4)
    ->data_is($fruits)
    ;


###
### Testing patch action.
###

$t->patch_ok('/api/v1/fruits/1.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

$fruit_to_update = pop @$fruits;
$fruit_to_update->{name} = 'fruit1_updated_again';
$t->patch_ok('/api/v1/fruits/1.json' => json => {
        name => $fruit_to_update->{name},
    })
    ->status_is(200)
    ->data_is($fruit_to_update)
    ;
push @$fruits, $fruit_to_update;

$t->get_ok('/api/v1/fruits.json')
    ->status_is(200)
    # ->json_is('/meta/items', 4)
    ->data_is($fruits)
    ;


###
### Testing delete action.
###

$t->delete_ok('/api/v1/fruits/1.json')
    ->status_is(200)
    ->data_is($fruits->[-1])
    ;

pop @$fruits;
$t->get_ok('/api/v1/fruits.json')
    ->status_is(200)
    # ->json_is('/meta/items', 3)
    ->data_is($fruits)
    ;


1;