package Model::API::DummyJSON;

use strict;
use warnings;

use base qw(Model::API);


# The readable_fields and the writable_fields are optional.
sub readable_fields {()}
sub writable_fields {()}

sub _url_base { 'https://dummyjson.com' }

sub _url_add    { $_[0]->_url_get(). '/add' }
sub _url_update { $_[0]->_url_get($_[1]) }
sub _url_patch  { $_[0]->_url_get($_[1]) }
sub _url_delete { $_[0]->_url_get($_[1]) }
#TODO: _url_update = _url_patch = _url_delete

sub _url_list {
    my ($class, %params) = @_;
     
    my $params = join '&', map { $_ .'='. $params{$_} } keys %params;
    my $url    = $class->_url_get();

    $url .= "/search?${params}" if $params;

    return $url;
}


1;