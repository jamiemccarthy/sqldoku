# sqldoku

Experimenting with solving Sudoku puzzles using Rails.

    mysql> create user 'punching'@'localhost' identified by 'password';
    mysql> grant all on punching_development.* to 'punching'@'localhost';
    mysql> grant all on punching_test.* to 'punching'@'localhost';

    bundle exec rake db:create db:migrate db:setup
