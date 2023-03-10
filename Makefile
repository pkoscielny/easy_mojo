
test:
	make prepare_test_database
	make run_test

# After first run 'make test' you can run 'make run_test' multiple times to save your time.
run_test:
	@echo "######## Running tests ########"
	prove -r t/

prepare_test_database:
	@echo "######## Preparing test databases ########"
	perl bin/generate_sqlite_db.pl --test --force
	prove -r db_migrations/test_migrations.t
	perl bin/run_migrations.pl --test
	perl -Ilib -e "use strict; use Model::DB::Util; cache_test_db()"

prepare_database:
	@echo "######## Preparing databases ########"
	perl bin/generate_sqlite_db.pl --force
	perl bin/run_migrations.pl
