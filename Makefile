
test:
	make prepare_test_database
	make test_run

# After first run 'make test' you can run 'make test_run' multiple times to save your time.
test_run:
	@echo "######## Running tests ########"
	prove -r t/

test_cc:
	cover -t +select ^lib +ignore ^ -make 'prove -r t/; exit $?' db_test/cover_db

prepare_test_database:
	@echo "######## Preparing test databases ########"
	perl bin/generate_sqlite_db.pl --test --force
	perl bin/generate_pg_db.pl --test --force
	prove -r db_migrations/test_migrations.t
	perl bin/run_migrations.pl --test
	perl -Ilib -e "use strict; use Model::DB::Util; cache_test_db()"

prepare_database:
	@echo "######## Preparing databases ########"
	perl bin/generate_sqlite_db.pl
	perl bin/generate_pg_db.pl
	perl bin/run_migrations.pl
