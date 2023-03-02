#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib"  }

use Mojolicious::Commands;

use Carp;
$SIG{__DIE__} = \&Carp::confess;

# Start command line interface for application
Mojolicious::Commands->start_app('App');
