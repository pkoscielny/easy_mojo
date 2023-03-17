# Easy Mojo

A small example of Mojolicious power.

## List of features

* A fully working skeleton of web service
* RESTful actions
* Simple creation and configuration of new resources
* Easily create custom actions
* Resources based on various databases and other webservices
* Content negotiation
* Supported response formats: JSON, YAML, CSV, HTML, XLS, XLSX, text
* Database migrations
* Dockerizing everything


## Prepare environment
```
bin/docker.sh --help
```

```
bin/docker.sh --build
```

Create empty databases and run migrations:
```
bin/emojo make prepare_database
```

## Run Easy Mojo as a service

Interactive mode for development:
```
bin/docker.sh --start -i
```
You can control running migrations `(set MOJO_DB_MIGRATIONS to 0 or 1)`
or operating mode `(set MOJO_ENV to dev, test, prod)`.

All of these env variables are set in the docker-compose.yml
Setting the `dev` mode will start Morbo. Other modes will start the Hypnotoad server.


## Run specific commands


### Prepare and run all unit tests


```
bin/docker.sh --start -i
```

In other console:
```
bin/emojo
make test
```

After this first run you can run tests multiple times:
```
make test_run
```

Also you can run test code coverage:
```
make test_cc
```
All code coverage results are in a `db_test/cover_db` folder.


### Run BASH console inside a easy_mojo container:
```
bin/emojo
```


## Author
Paweł Kościelny
