package Model;

use strict;
use warnings;

=head1

Model::DB::ORM - db layer based on Rose::DB. The naming convention is Model::DB::ORM::<DSN>::<table>.
Model::WSGateway - call to other web services.
App::Controller::REST has default resource object (throw exception) but in specific resource will be one of Model::*

The *_object is because some of method names like 'update' are reserved by Rose::DB::Object.

---------------------------

Model::DB::ORM (Rose::DB) - registering DB connections.
Model::DB::ORM::Object (Rose::DB::Object, Model) - init_db, get_dsn, get_dbh, load_by_id, ... 
Model::DB::ORM::Alpha (Model::DB::ORM::Object) - sub get_dsn {'alpha'} 
Model::DB::ORM::Alpha::Foo (Model::DB::ORM::Alpha) - table 

Model::WSGateway (Model) - implemented
Model::WSGateway::ExampleCom:
https://docs.mojolicious.org/Mojolicious/Guides/Cookbook#Backend-web-services
https://docs.mojolicious.org/Mojolicious/Guides/Cookbook#REST-web-services
https://dummyjson.com/
https://jsonplaceholder.typicode.com/

=cut


sub get_object {
    die "Model 'get' method is required";
}


sub get_object_list {
    die "Model 'get_list' method is required";
}


sub add_object {
    die "Model 'add' method is required";
}


sub update_object {
    die "Model 'update' method is required";
}


sub delete_object {
    die "Model 'delete' method is required";
}


sub readable_fields {
    die "Model 'readable_fields' method is required";
}


sub writable_fields {
    die "Model 'writable_fields' method is required";
}


#TODO: think about extending this feature to related objects.
sub filter_out_unreadable_fields {
    my ($class, $resource) = @_;
    return $resource unless $resource;

    my @readable_fields = $class->readable_fields or return $resource;
    my %readable_fields = map { $_ => 1 } @readable_fields;

    my $resources = ref $resource eq 'ARRAY' ? $resource : [$resource];
    foreach my $res (@$resources) {
        foreach my $field (keys %$res) {
            delete $res->{$field} unless exists $readable_fields{$field};
        }
    }

    return $resource;
}


sub filter_out_unwritable_fields {
    my ($class, $params) = @_;

    # Filter out forbidden fields only if writable fields are given.
    my @writable_fields = $class->writable_fields or return $params;
    my %writable_fields = map { $_ => 1 } @writable_fields;

    foreach my $field (keys %$params) {
        delete $params->{$field} unless exists $writable_fields{$field};
    }
    #my @all_fields = keys %$params;
    #map { delete $params{$_} unless exists $writable_fields{$_} } @all_fields;

    return $params;
}



1;