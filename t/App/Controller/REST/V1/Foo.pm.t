#!/usr/bin/perl

# carton exec perl t/App/Controller/REST/V1/Foo.pm.t

use strict;
use warnings;

use Cwd;
use lib Cwd::realpath() .'/lib';

###################
## Configuration ##
###################

use Test::More tests => 59;
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
require Model::DB::ORM::Alpha::Foo;


###################
##     Tests     ##
###################

# Start a Mojolicious app.
my $t = Test::Mojo::App->new('App');


###
### Testing list action.
###

$t->get_ok('/api/v1/alt_foo.json')
    ->status_is(200)
    # ->json_is('/meta/items', 0)
    ->data_is([])
    ;

my $foos = [
    { id => 1, name => 'foo1' },
    { id => 2, name => 'foo2' },
    { id => 3, name => 'foo3' },
];
Model::DB::ORM::Alpha::Foo->add_object(%$_) for @$foos;

$t->get_ok('/api/v1/alt_foo.json')
    ->status_is(200)
    # ->json_is('/meta/items', 3)
    ->data_is($foos)
    ;

# Check other response formats.
# Unfortunatelly the response sometimes comes with a different columns order :-/

$t->get_ok('/api/v1/alt_foo.csv')
    ->status_is(200)
#     ->content_is('id,name
# 1,foo1
# 2,foo2
# 3,foo3
# '   )
#     ->or(sub {  
#         $t->content_is('name,id
# foo1,1
# foo2,2
# foo3,3
# ')        
#     })
    ->content_like(qr/id/,   'header id')
    ->content_like(qr/name/, 'header name')
    ->content_like(qr/foo1/, 'name foo1')
    ->content_like(qr/foo2/, 'name foo2')
    ->content_like(qr/foo3/, 'name foo3')
    ->content_like(qr/1/,    'id 1')
    ->content_like(qr/2/,    'id 2')
    ->content_like(qr/3/,    'id 3')
    ;

$t->get_ok('/api/v1/alt_foo.txt')
    ->status_is(200)
#     ->content_is('name  id
# foo1  1
# foo2  2
# foo3  3
# '   )
    ->content_like(qr/id/,   'header id')
    ->content_like(qr/name/, 'header name')
    ->content_like(qr/foo1/, 'name foo1')
    ->content_like(qr/foo2/, 'name foo2')
    ->content_like(qr/foo3/, 'name foo3')
    ->content_like(qr/1/,    'id 1')
    ->content_like(qr/2/,    'id 2')
    ->content_like(qr/3/,    'id 3')
    ;

$t->get_ok('/api/v1/alt_foo.yaml')
    ->status_is(200)
    ->content_is('---
data:
- id: 1
  name: foo1
- id: 2
  name: foo2
- id: 3
  name: foo3
message: \'\'
meta: {}
'   )
    ;

$t->get_ok('/api/v1/alt_foo.html')
    ->status_is(200)
    ->element_exists('table tbody tr td', 'name')
    ->element_exists('table tbody tr td', 'id')
    ->element_exists('table tbody tr td', 'foo1')
    ;


# Lack of tests for xls and xlsx formats.


###
### Testing get action.
###

foreach my $foo (@$foos) {
    $t->get_ok("/api/v1/alt_foo/$foo->{id}.json")
    # $t->get_ok('/api/v1/alt_foo/1')
        ->status_is(200)
        ->json_is('/data' => $foo)
        ;
}

$t->get_ok('/api/v1/alt_foo/4.json')
    ->status_is(404)
    ;

### Only get and list are available for this endpoint.

###
### Testing add action.
###

my $new_foo = { name => 'new_foo' };
$t->post_ok('/api/v1/alt_foo.json' => json => {
        %$new_foo,
    })
    ->status_is(404)
    # ->data_is($new_foo)
    ;

###
### Testing update action.
###

$t->put_ok('/api/v1/alt_foo/1.json')
    ->status_is(404)
    ;

###
### Testing patch action.
###

$t->patch_ok('/api/v1/alt_foo/1.json')
    ->status_is(404)
    ;

###
### Testing delete action.
###

$t->delete_ok('/api/v1/alt_foo/1.json')
    ->status_is(404)
    ;


# For easier debugging, it is recommended to add the code below as a snippet in your IDE:
# use Data::Dumper;
# print "res: ", Dumper $t->tx->res->json;
# exit;

1;