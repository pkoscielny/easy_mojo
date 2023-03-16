package App;


=head1

docker-compose -f docker/docker-compose.yml up

carton install
carton exec script/app.pl routes -v
carton exec morbo -l  "http://*:3001" script/app.pl -w . -m dev
http://127.0.0.1:3001/api/v1/alt_foo/1.json
http://127.0.0.1:3001/api/v1/bars/1.json

https://docs.mojolicious.org/Mojolicious/Plugin/DefaultHelpers

TODO:
* add generators for different drivers in bin/run_migrations.pl
* add more unit tests for existing resources
* add a test code coverage to a Makefile
* fix problem with not working GET method in custom actions
* add meta implementation: elapsed_time for getting data from model; items for list, etc.
* dockerizing everything (https://docs.mojolicious.org/Mojolicious/Guides/Cookbook#Containers)
* switch to the Hypnotoad
* implement model for other databases like Redis, Mongodb, ...
* implement model for postgres with migrations, test db caching, etc...
* add onlice API doc (e.g. Swagger)
* run scanner: https://github.com/aquasecurity/trivy
* implement RESTful actions as a non-blocking operations (external API calls, interactions with model objects in general)
---
* authentication plugin
* authorization plugin

=cut

use strict;
use warnings;

use Carp 'confess';
$SIG{__DIE__} = \&confess;

use YAML::XS;
use Text::Pluralize;
use Dotenv -load => 'config/.env';

use Mojo::Base 'Mojolicious';
use Mojo::Util qw( decamelize );

use Data::Dumper;

my @supported_response_formats = qw/txt csv html json yaml xls xlsx/;


# After startup all controller classes will be load.
sub startup {
    my ($self) = @_;
    print 'Running mode: ', $self->mode, "\n";

    $self->setup_plugins();

    # Set unique passphrase for cookies.
    # https://docs.mojolicious.org/Mojolicious#secrets
    $self->secrets($self->config->{app_secret_passphrase});

    $self->setup_rest_config();
    $self->setup_routing();

    # $self->setup_hooks();
}


sub setup_plugins {
    my ($self) = @_;

    # https://docs.mojolicious.org/Mojolicious/Plugin/NotYAMLConfig
    $self->plugin('Mojolicious::Plugin::NotYAMLConfig', 
        module => 'YAML::XS', 
        file => $self->home->rel_file('config/app.yml')->to_string
    );

    # $self->plugin('DefaultHelpers');  # loaded by default so it is not needed.

    #TODO: thinkg about ReplyTable plugin for generating csv, etc formats in response_to.
    $self->plugin('Mojolicious::Plugin::ReplyTable');

    $self->plugin('Request');
    $self->plugin('Logger');

    #TODO: think about it. It will be good to have this functionality. Maybe simple returns routing.yaml content without comments?
    # $self->plugin(
    #     SwaggerUI => {
    #         route   => $self->routes()->any('/swagger'),
    #         url     => "/api",  
    #         title   => "Mojolicious App",
    #         # favicon => "/images/favicon.png",
    #     }
    # );
}


# Loads the REST routing configuration from a YAML file.
sub setup_rest_config {
    my ($self) = @_;

    my $conf_file = $self->home->rel_file('config/routing.yml')->to_string;
    my $rest_conf = YAML::XS::LoadFile($conf_file);

    foreach my $rh (@$rest_conf) {

        # Validate fields.
        foreach my $field (qw(package_name actions)) {
            die "'$field' field is required in $conf_file" if not exists $rh->{$field};
        }

        # Add actions as a hashref - more useful.
        $rh->{rh_actions} = { map {$_ => 1} map { ref $_ eq 'HASH' ? $_->{action} : $_ } @{$rh->{actions}} };

        $rh->{controller_name} = "REST::$rh->{package_name}";
    }

    # $self->app->log->debug('routing conf: '. Dumper $rest_conf);
    $self->{rest_config} = $rest_conf;
}


#TODO: diagnostic endpoints.
#TODO: move it as plugin? For sure refactoring is needed.
sub setup_routing {
    my ($self) = @_;

    # https://docs.mojolicious.org/Mojolicious/Routes/Route#to
    # https://docs.mojolicious.org/Mojolicious/Guides/Routing#Formats

    my $route_prefix = $self->config->{route_prefix};

    # Router.
    my $routes = $self->routes;

    #TODO: this loop is too big - refactoring needed.
    foreach my $rh (@{ $self->{rest_config} }) {

        # Calculate a route based on package_name or a route taken from it's configuration.
        my $base_route = $rh->{alt_route} || do {
            my @package_name = split '::', $rh->{package_name};

            $package_name[-1] = pluralize($package_name[-1], 2) if $self->config->{route_pluralization};

            join '/', $route_prefix, map { decamelize $_ } @package_name;
        };
        $self->log->trace("base route: $base_route");

        my $r = $routes->under($base_route => [format => \@supported_response_formats]);
        my $c_name = $rh->{controller_name};

        ### Common actions.

        # List.
        $r->get('/')
            ->to(controller => $c_name, action => 'list') 
            if exists $rh->{rh_actions}{list};

        #TODO: for bigger params payload (complex query) I have to use POST method.
        # POST.
        # $r->post('/list')
        #     ->to(controller => $c_name, action => 'list')
        #     if exists $rh->{actions}{list};

        # GET.
        $r->get('/:id')
            ->to(controller => $c_name, action => 'get') 
            if exists $rh->{rh_actions}{get};

        # POST.
        $r->post('/')
            ->to(controller => $c_name, action => 'add')
            if exists $rh->{rh_actions}{add};

        # PUT.
        $r->put('/:id')
            ->to(controller => $c_name, action => 'update')
            if exists $rh->{rh_actions}{update};

        # DELETE.
        $r->delete('/:id')
            ->to(controller => $c_name, action => 'delete')
            if exists $rh->{rh_actions}{delete};
        
        # TODO: patch implementation.
        # PATCH.
        # $r->patch('/')
        #     ->to(controller => $c_name, action => 'patch')
        #     if exists $rh->{rh_actions}{patch};

        ### Custom actions.

        foreach my $item (@{ $rh->{actions} }) {
            
            # Actions as scalars are common.
            next if not ref $item;

            my $action = $item->{action};
            my $method = lc $item->{method};
            my $local_route = "/$action/";
            if (my $phs = $item->{placeholders}) {
                $local_route .= join "/", map {":$_"} @$phs;
            }

            eval {
                $r->$method($local_route)
                    ->to(controller => $c_name, action => $action);
            };
            die qq{
                CONTROLLER: $c_name
                ACTION: $action
                ERROR: $@
            } if $@;
        } #actions

    } #routes
}


# sub setup_hooks {
#     my ($self) = @_;

#     $self->hook( before_dispatch => sub {
#         my ($app) = @_;
        
#         $app->{params} //= {};

#     });

# }



1;
