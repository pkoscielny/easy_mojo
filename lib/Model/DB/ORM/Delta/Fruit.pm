package Model::DB::ORM::Delta::Fruit;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::DB::ORM::Delta::Fruit'

use strict;
use warnings;

use base qw(Model::DB::ORM::Delta);


__PACKAGE__->meta->setup(
    table => 'fruits',
    auto  => 1,
);
# or define all columns by hand.


#TODO: read and decide what way will be better: 
# https://metacpan.org/dist/Rose-DB-Object/view/lib/Rose/DB/Object/Tutorial.pod#Multiple-objects
# Think about creating separate layer to implement all CRUD model methods: Model::DB::ORM::Object class will represent only single row.
# But what with initialization? It requires 'use Model::..'.
Rose::DB::Object::Manager->make_manager_methods('rows');


1;