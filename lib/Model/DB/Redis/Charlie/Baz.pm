package Model::DB::Redis::Charlie::Baz;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::DB::Redis::Charlie::Baz;'

use strict;
use warnings;

use base qw(Model::DB::Redis::Charlie);

use Mojo::Util qw( decamelize );


# sub readable_fields {()}
# sub writable_fields {()}

sub _get_key_prefix {
    return 'easy_mojo:'.decamelize(__PACKAGE__).':';
}

1;