
test:
	make prepare_test_database
	make run_test

run_test:
	carton exec 'prove -r t/'

prepare_test_database:
	@echo "######## Preparing test databases ########"
	carton exec 'perl bin/generate_sqlite_db.pl --test --force'
	carton exec 'perl bin/run_migrations.pl --test'
	carton exec 'perl -Ilib -e "use strict; use Model::DB::Util; cache_test_db()"'

prepare_database:
	@echo "######## Preparing databases ########"
	carton exec 'perl bin/generate_sqlite_db.pl --force'
	carton exec 'perl bin/run_migrations.pl'
