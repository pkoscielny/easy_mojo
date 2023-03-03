package Model::API::JSONPlaceholder;

use strict;
use warnings;

use base qw(Model::API);


# The readable_fields and the writable_fields are optional.
sub readable_fields {()}
sub writable_fields {()}

sub _url_base { 'https://jsonplaceholder.typicode.com' }

sub _url_list   { $_[0]->_url_get() }
sub _url_add    { $_[0]->_url_get() }
sub _url_update { $_[0]->_url_get($_[1]) }
sub _url_patch  { $_[0]->_url_get($_[1]) }
sub _url_delete { $_[0]->_url_get($_[1]) }
#TODO: _url_update = _url_patch = _url_delete


1;