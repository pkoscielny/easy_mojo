package Model::WSGateway;

use strict;
use warnings;

use base qw(Model);

use Data::Dumper;
use Carp 'confess';
use Mojo::UserAgent;
# use Mojo::Util;

my $ua = Mojo::UserAgent->new;

# Basic Model::WSGateway uses blocking requests.
# https://docs.mojolicious.org/Mojo/UserAgent

#TODO: https://docs.mojolicious.org/Mojolicious/Guides/Cookbook#Backend-web-services
#TODO: refactoring needed.

sub _url_base { confess "_url_base not implemented" }

sub _url_get    { confess "_url_get not implemented" }
sub _url_list   { confess "_url_list not implemented" }
sub _url_add    { confess "_url_add not implemented" }
sub _url_update { confess "_url_update not implemented" }
sub _url_delete { confess "_url_delete not implemented" }
sub _url_patch  { confess "_url_patch not implemented" }


sub get_object {
    my ($class, $id) = @_;
    my $url = join '/', $class->_url_base(), $class->_url_get($id);
# warn "url: $url";

    my $res = $ua
        ->max_redirects(5)
        ->get($url)
        ->result
    ;
    
    return undef unless $res->is_success;
    return $res->json;
}


sub get_object_list {
    my ($class, %params) = @_;
    my $url = join '/', $class->_url_base(), $class->_url_list(%params);
# warn "url: $url";

    my $res = $ua
        ->max_redirects(5)
        ->get($url)
        ->result
    ;
    
    return undef unless $res->is_success;
    return $res->json;
}


sub add_object {
    my ($class, %params) = @_;
    my $url = join '/', $class->_url_base(), $class->_url_add(%params);

    my $res = $ua
        ->max_redirects(5)
        ->post($url => json => \%params)
        ->result
    ;
    
    unless ($res->is_success) {
        return undef;
    }
    
    return $res->json;
}


sub update_object {
    my ($class, $id, %params) = @_;
    my $url = join '/', $class->_url_base(), $class->_url_update($id, %params);

    my $res = $ua
        ->max_redirects(5)
        ->put($url => json => \%params)
        ->result
    ;
    
    unless ($res->is_success) {
        return undef;
    }
    
    return $res->json;
}


sub delete_object {
    my ($class, $id) = @_;
    my $url = join '/', $class->_url_base(), $class->_url_delete($id);

    my $res = $ua
        ->max_redirects(5)
        ->delete($url)
        ->result
    ;
    
    unless ($res->is_success) {
        return undef;
    }
    
    return $res->json;
}


### Model::WSGateway specific methods:

#TODO: get_url ?


1;