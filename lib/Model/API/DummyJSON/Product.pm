package Model::API::DummyJSON::Product;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::API::DummyJSON::Product;'

use strict;
use warnings;

use base qw(Model::API::DummyJSON);

# https://dummyjson.com/products

sub _url_get {
    my ($class, $id) = @_;
    return 'products'.($id ? "/${id}" : '');
}


# What you want to save.
sub writable_fields {qw/
    title
/}


1;