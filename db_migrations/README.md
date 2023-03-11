```
docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --help | less
docker run --rm -it -v $PWD:/easy_mojo --entrypoint /bin/bash liquibase_with_mysql:4.19
```

Create new db file for SQLite:
```
sqlite3 db/alpha.db "VACUUM;"
sqlite3 db/bravo.db "VACUUM;"
```

Run migrations:
```
docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/alpha.db" --classpath=/easy_mojo/db_migrations/alpha/ --changelog-file=changelog.xml update
docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/bravo.db" --classpath=/easy_mojo/db_migrations/bravo/ --changelog-file=changelog.xml update
```

Check status:
```
docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/alpha.db" --classpath=/easy_mojo/db_migrations/alpha/ --changelog-file=changelog.xml status
```

Rollback:
https://docs.liquibase.com/commands/rollback/rollback-sql.html
```
docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/alpha.db" --classpath=/easy_mojo/db_migrations/alpha/ --changelog-file=changelog.xml rollback-count-sql --count=1

docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/alpha.db" --classpath=/easy_mojo/db_migrations/alpha/ --changelog-file=changelog.xml rollback-count --count=1
```

or

```
docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/alpha.db" --classpath=/easy_mojo/db_migrations/alpha/ --changelog-file=changelog.xml rollback-sql --tag=version_0.2

docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/alpha.db" --classpath=/easy_mojo/db_migrations/alpha/ --changelog-file=changelog.xml rollback --tag=version_0.2
```

Generate database documentation, e.g:
```
docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/alpha.db" --classpath=/easy_mojo/db_migrations/alpha/ --changelog-file=changelog.xml db-doc --output-directory=/easy_mojo/db_migrations/alpha/doc/
```
In this folder you can (re)generate database documentation.


For unit tests run updates on test databases without data (--contexts="!data")
```
docker run --rm -v $PWD:/easy_mojo liquibase_with_mysql:4.19 --url="jdbc:sqlite:/easy_mojo/db/alpha.db" --classpath=/easy_mojo/db_migrations/alpha/ --changelog-file=changelog.xml update --contexts='!data'
```
Better will be to use tests fixtures separately, not in migrations.
