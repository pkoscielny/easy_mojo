#!/usr/bin/perl

# carton exec perl t/App/Controller/REST/V1/Bar.pm.t

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';

###################
## Configuration ##
###################

use Test::More tests => 95;
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
require Model::DB::ORM::Bravo::Bar;


###################
##     Tests     ##
###################

# Start a Mojolicious app.
my $t = Test::Mojo::App->new('App');


###
### Testing list action.
###

$t->get_ok('/api/v1/bars.json')
    ->status_is(200)
    # ->json_is('/meta/items', 0)
    ->json_hasnt('/meta/items')  # to be sure that I won't forget add new tests for the 'items' feature.
    ->data_is([])
    ;

my $bars = [
    { id => 1, name => 'bar1' },
    { id => 2, name => 'bar2' },
    { id => 3, name => 'bar3' },
];
Model::DB::ORM::Bravo::Bar->add_object(%$_) for @$bars;

$t->get_ok('/api/v1/bars.json')
    ->status_is(200)
    # ->json_is('/meta/items', 3)
    ->data_is($bars)
    ;


###
### Testing get action.
###

foreach my $bar (@$bars) {
    $t->get_ok("/api/v1/bars/$bar->{id}.json")
        ->status_is(200)
        ->json_is('/data' => $bar)
        ;
}

$t->get_ok('/api/v1/bars/4.json')
    ->status_is(404)
    ;

### Only get and list are available for this endpoint.


###
### Testing add action.
###

$t->post_ok('/api/v1/bars.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

my $new_bar = { name => 'new_bar' };
$t->post_ok('/api/v1/bars.json' => json => {
        %$new_bar,
        id => 4,  # invalid field to write.
    })
    ->status_is(400)
    ->json_is('/message', 'WRONG_ID_FIELD')
    ;

$t->post_ok('/api/v1/bars.json' => json => {
        %$new_bar,
    })
    ->status_is(200)
    ->data_is($new_bar)
    ;

$t->get_ok("/api/v1/bars/4.json")
    ->status_is(200)
    ->json_is('/data' => {
        %$new_bar,
        id => 4,
    })
    ;

push @$bars, $new_bar;
$t->get_ok('/api/v1/bars.json')
    ->status_is(200)
    # ->json_is('/meta/items', 4)
    ->data_is($bars)
    ;


###
### Testing update action.
###

$t->put_ok('/api/v1/bars/1.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

$bars->[0]{name} = 'bar1_updated';
$t->put_ok('/api/v1/bars/1.json' => json => {
        name => $bars->[0]{name}
    })
    ->status_is(200)
    ->data_is($bars->[0])
    ;

$t->get_ok('/api/v1/bars.json')
    ->status_is(200)
    # ->json_is('/meta/items', 4)
    ->data_is($bars)
    ;


###
### Testing patch action.
###

$t->patch_ok('/api/v1/bars/1.json')
    ->status_is(400)
    ->json_is('/message', 'EMPTY_JSON_PARAMS')
    ;

$bars->[0]{name} = 'bar1_updated_again';
$t->patch_ok('/api/v1/bars/1.json' => json => {
        name => $bars->[0]{name}
    })
    ->status_is(200)
    ->data_is($bars->[0])
    ;

$t->get_ok('/api/v1/bars.json')
    ->status_is(200)
    # ->json_is('/meta/items', 4)
    ->data_is($bars)
    ;


###
### Testing delete action.
###

$t->delete_ok('/api/v1/bars/1.json')
    ->status_is(200)
    ->data_is($bars->[0])
    ;

shift @$bars;
$t->get_ok('/api/v1/bars.json')
    ->status_is(200)
    # ->json_is('/meta/items', 3)
    ->data_is($bars)
    ;


#########################
## Custom action tests ##
#########################

$t->post_ok('/api/v1/bars/custom_action1/42/testing_custom_action_1.json')
    ->status_is(200)
    ->data_is({ id => 42, name => 'testing_custom_action_1'})
    ;

$t->post_ok('/api/v1/bars/custom_action2.json')
    ->status_is(200)
    ->data_is({ test => 'custom_action2'})
    ;


# For easier debugging, it is recommended to add the code below as a snippet in your IDE:
# use Data::Dumper;
# print "res: ", Dumper $t->tx->res->json;
# exit;

1;