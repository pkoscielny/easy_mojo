#!/usr/bin/perl

# MOJO_MODE=test carton exec prove t/App/Controller/REST/V1/Foo.pm.t
# MOJO_MODE=test carton exec perl t/App/Controller/REST/V1/Foo.pm.t

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';

use Test::More tests => 23;
use Test::NoWarnings;
# use Test::Differences;
# use Test::MockModule;
# use Test::MockObject;
# use Test::Mojo::More;

use Test::Mojo::App;

Test::Mojo::App->prepare_test_env();


# Start a Mojolicious app.
my $t = Test::Mojo::App->new('App');

# Post a JSON document.
$t->post_ok('/api/v1/alt_foo.json')
    ->status_is(404)
    ;

$t->get_ok('/api/v1/alt_foo.json')
    ->status_is(200)
    ->json_is('/data' => [
        {
            id => 1,
            name => 'foo1',
        }, 
        {
            id => 2,
            name => 'foo2',
        },
        {
            id => 3,
            name => 'foo4',
        },
    ])
    ;

$t->get_ok('/api/v1/alt_foo.json')
    ->status_is(200)
    ->data_is([
        {
            id => 1,
            name => 'foo1',
        }, 
        {
            id => 2,
            name => 'foo2',
        },
        {
            id => 3,
            name => 'foo4',
        },
    ])
    ;

$t->get_ok('/api/v1/alt_foo/1.json')
# $t->get_ok('/api/v1/alt_foo/1')
    ->status_is(200)
    ->json_is('/data' => {
        id => 1,
        name => 'foo1',
    })
    ;

$t->put_ok('/api/v1/alt_one/1.json')
    ->status_is(404)
    ;

$t->delete_ok('/api/v1/alt_one/1.json')
    ->status_is(404)
    ;

$t->patch_ok('/api/v1/alt_one/1.json')
    ->status_is(404)
    ;



# $t->post_ok('/api/v1/alt_foo.json' => json => {
#         event => 'full moon'
#     })
#     ->status_is(404)
#     ->json_is('/data/name' => 'name')
#     ;


1;