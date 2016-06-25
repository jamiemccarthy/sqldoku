# sqldoku

Experimenting with solving Sudoku puzzles using Rails.

    mysql> create user 'sqldoku'@'localhost' identified by 'password';
    mysql> grant all on sqldoku_development.* to 'sqldoku'@'localhost';
    mysql> grant all on sqldoku_test.* to 'sqldoku'@'localhost';

    bundle exec rake db:create db:migrate db:setup
