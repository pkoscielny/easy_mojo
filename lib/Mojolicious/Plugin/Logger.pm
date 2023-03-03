package Mojolicious::Plugin::Logger;

use strict;
use warnings;

use base 'Mojolicious::Plugin';
#use MojoX::Log::Log4perl;
use Mojo::Log;


=head1
Mojo::Log logging levels order:
    trace
    debug
    info
    warn
    error
    fatal
=cut

sub register {
    my ($self, $app, $conf) = @_;

    # $app->log( MojoX::Log::Log4perl->new($conf->{log4perl_config_file}) );

    $app->log(Mojo::Log->new(
        path => $conf->{log_file_path},
        level => $conf->{default_level},
    ));

    #TODO: if needed - add hook before_dispatch and/or after_dispatch with remote logger (e.g. put log events to some queue system).
}


1;