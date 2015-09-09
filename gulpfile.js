var gulp = require('gulp'),
  del = require('del'),
  concat = require('gulp-concat'),
  wrapper = require('gulp-wrapper'),
  run = require('gulp-run'),
  src = ['./src/**/constants.asm', './src/main.asm', './src/**/*.asm']
;

gulp.task('clean', function() {
  return del([
    'dist/*'
  ]);
});

gulp.task('concat', function() {
  var commentLine = ';========================================\n';
  return gulp.src(src)
    .pipe(wrapper({
      header: commentLine + '; ${filename}\n' + commentLine
    }))
    .pipe(concat('smsspec.asm'))
    .pipe(gulp.dest('./dist/'))
  ;
});

gulp.task(
  'build',
  gulp.series(
    'clean',
    'concat'
  )
);

gulp.task('watch', gulp.series('build', function() {
  return gulp.watch(src, gulp.series('build'));
}));

gulp.task('create-link-file', function(callback) {
  require('fs').writeFile('./example/build/linkfile', "[objects]\ntest_suite.o", [], callback);
  //return run("echo '[objects]' > linkfile", {cwd: './example/build'});
});

gulp.task('assemble-example', function() {
  return run('wla-z80 -o test_suite.asm ./build/test_suite.o', {cwd: './example'}).exec();
});

gulp.task('link-example', function() {
  return run('wlalink -drvs linkfile ../bin/test_suite.sms && mv .\\.sym ../bin/test_suite.sym',
    {cwd: './example/build'}).exec();
});

gulp.task('build-example', gulp.series(
  gulp.parallel(
    'build',
    'create-link-file'
  ),
  'assemble-example',
  'link-example'
));

gulp.task('watch-example', function() {
  //gulp.watch(src, gulp.series('build'));
  gulp.watch('./example/**/*.asm', gulp.series('build-example'));
});
