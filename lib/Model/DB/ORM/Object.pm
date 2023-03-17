package Model::DB::ORM::Object;

use strict;
use warnings;

use Carp 'confess';

use Model::DB::ORM;
use Rose::DB::Object::Helpers qw( as_tree );
use base qw(Rose::DB::Object Model);


sub get_dsn { confess "Implementation for get_dsn is required" }


my %db_cache;
sub init_db { 
    my ($class) = @_;
    my $dsn = $class->get_dsn();

    unless ($db_cache{$dsn} and $db_cache{$dsn}->dbh->ping) {
        #TODO: Model::DB::ORM->new or new_or_cached.
        my $db = Model::DB::ORM->new(type => $dsn);

        #TODO: release_dbh? Think about it: https://metacpan.org/pod/Rose::DB#Database-Handle-Life-Cycle-Management
        confess $db->error if not $db->retain_dbh;
        
        $db_cache{$dsn} = $db;
    }

    return $db_cache{$dsn};
}

# If you need to run a custom SQL, e.g. for very specific cases or better performance.
sub get_dbh {
    $_[0]->init_db->dbh;
}


###### Model methods implementation.

# The readable_fields and the writable_fields are optional.
sub readable_fields {()}
sub writable_fields {()}

#TODO: reimplement set_fields - implement set fields cascade: https://metacpan.org/pod/Rose::DB::Object#OBJECT-METHODS
sub set_fields {
    my ($self, %params) = @_;

    $self->handle_unwritable_fields(\%params);

    while (my($field, $value) = each %params) {
        $self->$field($value);
    }

    return $self;
}


sub _get_object {
    my ($class, 
        $id,     # PK.
        %params  # rewrite speculative, etc (https://metacpan.org/pod/Rose::DB::Object#OBJECT-METHODS see load).
    ) = @_;

    #TODO: add more validation.
    my $pk = $class->meta->primary_key->columns->[0]->name;
    # confess unless $pk;

    my $object = $class->new($pk => $id);
    return $object->load(speculative => 1, %params) || undef;
}


# Hash version of _get_object.
sub get_object {
    my ($class, 
        $id,     # PK.
        %params  # rewrite speculative, etc (https://metacpan.org/pod/Rose::DB::Object#OBJECT-METHODS see load).
    ) = @_;

    my $object = $class->_get_object($id, %params) || return undef;
    return $object->as_tree;
}


sub get_object_list {
    my ($class, 
        %params,  #TODO: big description about list params.
    ) = @_;

    #TODO: implement here this complex logic for clever list fetching.

    my $objects = $class->get_rows(
        %params,
        #debug => 1, # watch SQL queries directly
    );

    return [ map { $_->as_tree } @$objects ];
}


sub add_object {
    my ($class, %params) = @_;

    my $object = $class->new;
    $object->set_fields(%params);
    $object->save(cascade => 1);

    return $object->as_tree;
}


sub update_object {
    my ($class, $id, %params) = @_;

    my $object = $class->_get_object($id, %params);
    $object->set_fields(%params);
    $object->save(cascade => 1);  # changes_only => 1

    return $object->as_tree;
}


sub delete_object {
    my ($class, $id) = @_;

    my $object = $class->_get_object($id);
    $object->delete();  # cascade => 1 ?

    return $object->as_tree;
}


1;