package Model::DB::Redis::Object;

use strict;
use warnings;

use Carp 'confess';
use Data::Dumper;
use Time::HiRes qw( time );
use JSON::XS;

use Model::DB::Redis qw( get_redis_connection );
use base qw( Model );


###### Redis specific methods implementation.

my $json = JSON::XS->new->utf8(1)->allow_nonref(1)->allow_blessed(1)->convert_blessed(1);

sub get_dsn { confess "Implementation for get_dsn is required" }

sub _get_key_prefix { confess "Implementation for _get_key_prefix is required" }

sub _redis_connection {
    my ($class) = @_;
    return get_redis_connection( $class->get_dsn() );
}

sub _generate_id {
    my $id = time() .'-'. int(rand(1000));
    $id =~ s/\./-/;
    return $id;
}

sub _get_key {
    my ($class, $id) = @_;

    my $prefix = $class->_get_key_prefix();
    return $id if index($id, $prefix) >= 0;

    return "${prefix}${id}";
}

sub _get_id {
    my ($class, $id) = @_;

    my $prefix = $class->_get_key_prefix();
    return $id if index($id, $prefix) == -1;

    $id =~ s/$prefix//g;
    return $id;
}

sub get_keys {
    my ($class, $pattern, %params) = @_;
    my $conn = $class->_redis_connection();

    $pattern //= '*';
    my $keys_pattern = $class->_get_key($pattern);
    return sort $conn->keys($keys_pattern) if $params{sorted};
    return      $conn->keys($keys_pattern);
}


###### Model methods implementation.

# The readable_fields and the writable_fields are optional.
sub readable_fields {()}
sub writable_fields {()}


sub get_object {
    my ($class, $id) = @_;
    my $conn = $class->_redis_connection();

    my $key  = $class->_get_key($id);
    my $text = $conn->get($key) or return undef;
    my $rh   = $json->decode($text);

    $class->filter_out_unreadable_fields($rh);
    $rh->{_id} = $class->_get_id($id);

    return $rh;
}


sub get_object_list {
    my ($class, 
        %params,  #TODO: big description about list params.
    ) = @_;
    #TODO: implement here this complex logic for clever list fetching.

    my @keys = $class->get_keys('*', sorted => 1);

    return [ map { $class->get_object($_) } @keys ];
}


sub add_object {
    my ($class, %params) = @_;
    my $conn = $class->_redis_connection();

    my $id   = $params{_id} || _generate_id();
    my $key  = $class->_get_key($id);

    $class->handle_unwritable_fields(\%params);
    my $text = $json->encode(\%params);

    $conn->set($key, $text);

    $params{_id} = $class->_get_id($id);
    return \%params;
}


sub update_object {
    my ($class, $id, %params) = @_;
    my $conn = $class->_redis_connection();

    $params{_id} = $id;
    return $class->add_object(%params);
}


sub delete_object {
    my ($class, $id) = @_;
    my $conn = $class->_redis_connection();

    my $rh  = $class->get_object($id);
    my $key = $class->_get_key($id);

    $conn->del($key);

    return $rh;
}


sub delete_objects {
    my ($class, $pattern) = @_;

    my @keys = $class->get_keys($pattern);
    $class->delete_object($_) for @keys;

    return @keys;
}


1;