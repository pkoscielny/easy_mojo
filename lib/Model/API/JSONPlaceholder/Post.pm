package Model::API::JSONPlaceholder::Post;

# carton exec perl -Ilib -e 'use strict; use warnings; use Model::API::JSONPlaceholder::Post;'

use strict;
use warnings;

use base qw(Model::API::DummyJSON);

# https://jsonplaceholder.typicode.com/posts

sub _url_get {
    my ($class, $id) = @_;
    return 'posts'.($id ? "/${id}" : '');
}


# What you want to see.
sub readable_fields {qw/
    id
    title
    body
    reactions
    tags
/}


# What you want to save.
sub writable_fields {qw/
    title
    body
/}


1;