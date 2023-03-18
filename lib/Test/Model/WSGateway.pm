package Test::Model::WSGateway;

# This module give you possibility to mock Mojo::UserAgent in tests;

use strict;
use warnings;


sub ua_mock { bless {}, __PACKAGE__ }

sub max_redirects { $_[0] }
sub get { $_[0] }
sub post { $_[0] }
sub put { $_[0] }
sub delete { $_[0] }
sub result { $_[0] }

# Sometimes we need to set undef as a result.
my $json;
sub json { 
    shift;

    $json = shift if @_;
    return $json;
}

my $is_success = 1;
sub is_success { 
    shift;

    $is_success = shift if @_;
    return $is_success;
}


1;