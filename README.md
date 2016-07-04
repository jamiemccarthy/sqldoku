# sqldoku

Experimenting with solving Sudoku puzzles using Rails.

    mysql> create user 'sqldoku'@'localhost' identified by 'password';
    mysql> grant all on sqldoku_development.* to 'sqldoku'@'localhost';
    mysql> grant all on sqldoku_test.* to 'sqldoku'@'localhost';

    bundle exec rake db:create db:migrate db:setup

This one seems to get solved okay:

[[3,1,7],[4,1,1],[6,1,6],[7,1,8],[1,2,8],[9,2,1],[3,3,2],[4,3,4],[6,3,9],[7,3,6],[1,4,2],[9,4,6],[3,5,3],[4,5,2],[6,5,5],[7,5,1],[1,6,9],[9,6,5],[3,7,1],[4,7,8],[6,7,3],[7,7,2],[1,8,3],[9,8,4],[3,9,6],[4,9,5],[6,9,1],[7,9,7]].each { |a| p.set!(*a) }

This one exposed a bug!

[[4,1,7],[5,1,2],[7,1,1],[8,1,9],[8,2,4],[9,2,8],[1,3,7],[6,3,3],[1,4,6],[6,4,5],[2,5,3],[3,5,8],[5,5,1],[7,5,9],[8,5,5],[4,6,8],[9,6,4],[4,7,3],[9,7,1],[1,8,4],[2,8,5],[2,9,6],[3,9,2],[5,9,5],[6,9,8]].each { |a| p.set!(*a) }
