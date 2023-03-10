package Model::DB::ORM::Alpha::Foo;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::DB::ORM::Alpha::Foo;'

use strict;
use warnings;

use base qw(Model::DB::ORM::Alpha);


__PACKAGE__->meta->setup(
    table => 'foos',
    auto  => 1,
);
# or define all columns by hand.


#TODO: read and decide what way will be better: 
# https://metacpan.org/dist/Rose-DB-Object/view/lib/Rose/DB/Object/Tutorial.pod#Multiple-objects
# Think about creating separate layer to implement all CRUD model methods: Model::DB::ORM::Object class will represent only single row.
# But what with initialization? It requires 'use Model::..'.
Rose::DB::Object::Manager->make_manager_methods('rows');


1;