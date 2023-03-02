package Model::DB::Bravo::Bar;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::DB::Bravo::Bar;'

use strict;
use warnings;

use Rose::DB::Object::Manager;
use base qw(Model::DB::Bravo);


__PACKAGE__->meta->setup(
    table => 'bars',
    auto  => 1,
);
# or define all columns and relations by hand.


#TODO: fields mapping? 

# What you want to see.
sub readable_fields {qw/
    id
    name
/}


# What you want to save.
sub writable_fields {qw/
    name
/}


#TODO: read and decide which way will be better: 
# https://metacpan.org/dist/Rose-DB-Object/view/lib/Rose/DB/Object/Tutorial.pod#Multiple-objects
# Think about creating separate layer to implement all CRUD model methods: Model::DB::Object class will represent only single row.
# But what with initialization? It requires 'use Model::..'.
Rose::DB::Object::Manager->make_manager_methods('rows');

1;