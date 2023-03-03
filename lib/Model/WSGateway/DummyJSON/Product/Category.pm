package Model::WSGateway::DummyJSON::Product::Category;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::WSGateway::DummyJSON::Product;'

use strict;
use warnings;

use base qw(Model::WSGateway::DummyJSON);

# https://dummyjson.com/products/categories

sub _url_get { 'products/categories' }


1;