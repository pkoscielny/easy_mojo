package Model::API::DummyJSON::Product::Category;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::API::DummyJSON::Product;'

use strict;
use warnings;

use base qw(Model::API::DummyJSON);

# https://dummyjson.com/products/categories

sub _url_get { 'products/categories' }


1;