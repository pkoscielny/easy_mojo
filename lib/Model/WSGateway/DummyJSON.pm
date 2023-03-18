package Model::WSGateway::DummyJSON;

use strict;
use warnings;

use List::Util qw( any );

use base qw(Model::WSGateway);


# The readable_fields and the writable_fields are optional.
sub readable_fields {()}
sub writable_fields {()}

sub _url_base { 'https://dummyjson.com' }

sub _url_add    { $_[0]->_url_get(). '/add' }
sub _url_update { $_[0]->_url_get($_[1]) }
sub _url_patch  { $_[0]->_url_get($_[1]) }
sub _url_delete { $_[0]->_url_get($_[1]) }
# sub _url_delete { \&_url_get }
#TODO: _url_update = _url_patch = _url_delete

sub _url_list {
    my ($class, %params) = @_;
     
    my $params = join '&', map { $_ .'='. $params{$_} } keys %params;
    my $url    = $class->_url_get();

    $url .= "/search?${params}" if $params;

    return $url;
}


# Reimplement get_object_list due to more complex structure returned by dummyjson ws.
# Unfortunately the DummyJSON has different list structures depending on endpoint:
# * products -> hashref
# * product categories -> arrayref
my @meta_fields = qw(limit skip total);
sub get_object_list {
    my ($class, %params) = @_;
    my $url = join '/', $class->_url_base(), $class->_url_list(%params);

    my $res = $class->ua
        ->max_redirects(5)
        ->get($url)
        ->result
    ;    
    return undef unless $res->is_success;
 
    my $result = $res->json;
    return $result if ref $result eq 'ARRAY';

    # Split fields between data and meta.
    my $data;
    my $meta = {};
    foreach my $field (keys %$result) {
        if (any { $_ eq $field } @meta_fields) {
            $meta->{$field} = delete $result->{$field} ;
        } else {
            # For e.g. for 'products' it will be 'products', etc...
            $data = $result->{$field};
        }
    }

    return $data;
}


1;