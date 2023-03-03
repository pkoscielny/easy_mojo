#!/usr/bin/perl

use strict;
use warnings;

use Mojo::Base -strict;

use Test::Mojo::App;
use Test::More;
# use Test::NoWarnings;

=head1

* create temporary db per t file
* 

=cut

# use Test::Differences;
# use Test::MockModule;
# use Test::MockObject;
# use Test::Mojo::More;

# use FindBin;
# BEGIN { unshift @INC, "$FindBin::Bin/../lib"  }

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


done_testing();

# $t->post_ok('/api/v1/alt_foo.json' => json => {
#         event => 'full moon'
#     })
#     ->status_is(404)
#     ->json_is('/data/name' => 'name')
#     ;


1;