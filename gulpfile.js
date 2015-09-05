var gulp = require('gulp'),
  del = require('del'),
  concat = require('gulp-concat'),
  wrapper = require('gulp-wrapper'),
  src = ['./src/main/asm', './src/**/*.asm']
;

gulp.task('clean', function() {
  return del([
    'dist/*'
  ]);
})

gulp.task('concat', function() {
  var commentLine = ';========================================\n';
  return gulp.src(src)
    .pipe(wrapper({
      header: commentLine + '; ${filename}\n' + commentLine
    }))
    .pipe(concat('smsspec.asm'))
    .pipe(gulp.dest('./dist/'))
});

gulp.task(
  'build',
  gulp.series(
    'clean',
    'concat'
  )
);

gulp.task('watch', function() {
  return gulp.watch(src, gulp.series('build'));
});
