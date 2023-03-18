requires 'Mojolicious', '9.25';
requires 'JSON::XS', '4.03';
requires 'YAML::XS', '0.86';
# requires 'Template::Simple', '0.06';
requires 'Text::Pluralize', '1.1';  # this lib is poor. Try to find something better.
requires 'Dotenv', '0.002';

requires 'Test::MockModule', 'v0.177.0';
requires 'Test::NoWarnings', '1.06';
requires 'Devel::Cover', '1.38';

requires 'MojoX::Log::Log4perl', '0.12';
requires 'Log::Dispatch::Screen', '2.70';
#requires 'Log::Log4perl::Appender::DBI';

requires 'Mojolicious::Plugin::ReplyTable', '0.12';
requires 'Spreadsheet::WriteExcel', '2.40';
requires 'Excel::Writer::XLSX', '1.10';

#requires 'Mojolicious::Plugin::SwaggerUI', 'v0.0.4';

requires 'Rose::DB::Object', '0.820';
requires 'DBD::SQLite', '1.72';
#requires 'Rose::DB::MySQL';
#requires 'Rose::DB::Pg';
#requires 'Rose::DB::SQLite';
#requires 'DBD::mysql';
#requires 'DBD::Pg';

requires 'Redis', '2.000';