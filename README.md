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
```
bin/docker.sh --start --i
```

## Run specific commands

Prepare and run all unit tests:
```
bin/emojo make test 
```

After this first run you can run tests multiple times:
```
bin/emojo make test_run 
```


Run BASH console:
```
bin/emojo
```

## Author
Paweł Kościelny
