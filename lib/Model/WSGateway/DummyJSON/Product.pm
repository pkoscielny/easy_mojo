package Model::WSGateway::DummyJSON::Product;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::WSGateway::DummyJSON::Product;'

use strict;
use warnings;

use base qw(Model::WSGateway::DummyJSON);

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