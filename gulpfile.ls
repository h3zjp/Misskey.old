require! {
	gulp
	del
	'gulp-plumber': plumber
	'gulp-livescript': ls
}

paths =
	package-json: './package.json.ls'
	ls: './src/**/*.ls'
	web-res: './src/web/resources/**/**'
	web-views: './src/web/views/**/*.jade'
	web-dev-references: './src/reference/**/*.jade'

gulp.task \clean del.bind(null, ['./bin/**'])

gulp.task \build-package-json ->
	gulp.src paths.package-json
		.pipe plumber!
		.pipe ls!
		.on \error (console.log.bind console)
		.pipe gulp.dest './'

gulp.task \build-ls ->
	gulp.src paths.ls
		.pipe plumber!
		.pipe ls!
		.on \error (console.log.bind console)
		.pipe gulp.dest './bin/'

gulp.task \build-web-res ->
	gulp.src paths.web-res
		.pipe plumber!
		.pipe gulp.dest './bin/web/resources'

gulp.task \build-web-views ->
	gulp.src paths.web-views
		.pipe plumber!
		.pipe gulp.dest './bin/web/views'
	gulp.src paths.web-dev-references
		.pipe plumber!
		.pipe gulp.dest './bin/reference'

gulp.task \build <[ build-package-json build-ls build-web-res build-web-views ]>

gulp.task \watch <[ build ]> ->
	gulp.watch paths.package-json, <[ build-package-json ]>
	gulp.watch paths.ls, <[ build-ls ]>
	gulp.watch paths.web-res, <[ build-web-res ]>
	gulp.watch paths.web-views, <[ build-web-views ]>

gulp.task \default <[ build ]>
