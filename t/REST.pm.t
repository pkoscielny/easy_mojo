use Mojo::Base -strict;

use Test::Mojo;
use Test::More;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib"  }

# Start a Mojolicious app.
my $t = Test::Mojo->new('App');

# Post a JSON document.
$t->post_ok('/api/alt_one.json' => json => {event => 'full moon'})
  ->status_is(200)
  ->json_is('/data/name' => 'name')
  ;

$t->get_ok('/api/alt_one.json')
  ->status_is(200)
  ->json_is('/data/name' => 'name')
  ;

$t->get_ok('/api/alt_one/1234.json')
  ->status_is(200)
  ->json_is('/data/name' => 'Pawel')
  ;

$t->put_ok('/api/alt_one/1234.json')
  ->status_is(200)
  ->json_is('/data/name' => 'name')
  ;
  
$t->delete_ok('/api/alt_one/1234.json')
  ->status_is(200)
  ->json_is('/data/name' => 'name')
  ;
  
$t->patch_ok('/api/alt_one.json')
  ->status_is(200)
  ->json_is('/data/name' => 'name')
  ;
  
done_testing();

1;