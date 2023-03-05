package Mojolicious::Plugin::Logger;

use strict;
use warnings;

use base 'Mojolicious::Plugin';
use MojoX::Log::Log4perl;
# use Mojo::Log;


=head1
Logging levels order:
    trace
    debug
    info
    warn
    error
    fatal

Use Log::Log4perl::MDC if you want to add some custom fields to logs.
If needed - add a hook before_dispatch and/or after_dispatch with a remote logger (e.g. put log events to some queue system).
=cut

sub register {
    my ($self, $app, $conf) = @_;

    # Do not use Mojo::Log or MojoX::Log::Log4perl for unit tests.
    # These cause problems with Test::NoWarnings;
    # First one can use only STDERR in console mode.
    # Second one also generates warning concerning format.
    if ($app->mode ne 'test') {
        $app->log( MojoX::Log::Log4perl->new($ENV{LOG4PERL_CONFIG_FILE}) );

        # $app->log(Mojo::Log->new(
        #     path  => $ENV{MOJO_LOG_FILE},
        #     level => $ENV{MOJO_LOG_LEVEL},
        # ));
    }
}


1;