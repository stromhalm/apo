path = require 'path'

# Build configurations
module.exports = (grunt) ->
	require('load-grunt-tasks')(grunt)
	require('time-grunt')(grunt)
	pkg = require './package.json'

	grunt.initConfig
		settings:
			distDirectory: 'dist'
			srcDirectory: 'src'
			tempDirectory: '.temp'

		# Deletes dist and .temp directories
		# The .temp directory is used during the build process
		# The dist directory contains the artifacts of the build
		# These directories should be deleted before subsequent builds
		# These directories are not committed to source control
		clean:
			working: [
				'<%= settings.tempDirectory %>'
				'<%= settings.distDirectory %>'
			]

		# Compiles CoffeeScript (.coffee) files to JavaScript (.js)
		coffee:
			app:
				files: [
					cwd: '<%= settings.tempDirectory %>'
					src: '**/*.coffee'
					dest: '<%= settings.tempDirectory %>'
					expand: true
					ext: '.js'
				]
				options:
					sourceMap: true

		# Lints CoffeeScript files
		coffeelint:
			app:
				files: [
					cwd: ''
					src: [
						'src/**/*.coffee'
						'!src/scripts/libs/**'
					]
				]
				options:
					indentation:
						value: 1
					max_line_length:
						level: 'ignore'
					no_tabs:
						level: 'ignore'

		# Sets up a web server
		connect:
			app:
				options:
					base: '<%= settings.distDirectory %>'
					hostname: 'localhost'
					livereload: true
					middleware: (connect, options, middlewares) ->
						express = require 'express'
						routes = require './routes'
						app = express()

						app.use express.static String(options.base)
						routes app, options
						middlewares.unshift app
						middlewares
					open: true
					port: 0

		# Copies directories and files from one location to another
		copy:
			app:
				files: [
					cwd: '<%= settings.srcDirectory %>'
					src: '**'
					dest: '<%= settings.tempDirectory %>'
					expand: true
				,
					cwd: '.components/'
					src: '**'
					dest: '<%= settings.tempDirectory %>'
					expand: true
				]
			dev:
				cwd: '<%= settings.tempDirectory %>'
				src: '**'
				dest: '<%= settings.distDirectory %>'
				expand: true
			prod:
				files: [
					cwd: '<%= settings.tempDirectory %>'
					src: [
						'**/*.{gif,jpeg,jpg,png,svg,webp}'
						'**/*.{css,js,html,map}'
						]
					dest: '<%= settings.distDirectory %>'
					expand: true
				]

		# Compresses image files
		imagemin:
			images:
				files: [
					cwd: '<%= settings.tempDirectory %>'
					src: '**/*.{gif,jpeg,jpg,png}'
					dest: '<%= settings.tempDirectory %>'
					expand: true
				]
				options:
					optimizationLevel: 7

		# Runs unit tests using karma
		karma:
			unit:
				options:
					browsers: [
						'PhantomJS'
					]
					captureTimeout: 5000
					colors: true
					files: [
						'http://ajax.googleapis.com/ajax/libs/angularjs/1.5.3/angular.min.js'
						'http://ajax.googleapis.com/ajax/libs/angularjs/1.5.3/angular-animate.min.js'
						'http://ajax.googleapis.com/ajax/libs/angularjs/1.5.3/angular-aria.min.js'
						'http://ajax.googleapis.com/ajax/libs/angularjs/1.5.3/angular-messages.min.js'
						'https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/0.2.18/angular-ui-router.min.js'
						'http://ajax.googleapis.com/ajax/libs/angular_material/1.0.7/angular-material.min.js'
						'http://cdnjs.cloudflare.com/ajax/libs/angular-material-icons/0.7.0/angular-material-icons.min.js'
						'https://cdnjs.cloudflare.com/ajax/libs/ngStorage/0.3.6/ngStorage.min.js'
						'https://d3js.org/d3.v3.min.js'
						'http://cdnjs.cloudflare.com/ajax/libs/json3/3.3.2/json3.min.js'
						'http://ajax.googleapis.com/ajax/libs/angularjs/1.5.3/angular-mocks.js'
						'dist/**/main.js'
						'dist/**/*.js'
						'test/**/*.{coffee,js}'
					]
					frameworks: [
						'jasmine'
					]
					junitReporter:
						outputFile: 'test-results.xml'
					keepalive: false
					logLevel: 'INFO'
					port: 9876
					preprocessors:
						'**/*.coffee': 'coffee'
					reporters: [
						'spec'
					]
					runnerPort: 9100
					singleRun: true

		# Compile LESS (.less) files to CSS (.css)
		less:
			app:
				files:
					'.temp/styles/style.css': '.temp/styles/**.less'

		# Convert CoffeeScript classes to AngularJS modules
		ngClassify:
			app:
				files: [
					cwd: '<%= settings.tempDirectory %>'
					src: '**/*.coffee'
					dest: '<%= settings.tempDirectory %>'
					expand: true
				]

		cacheBust:
			taskName:
				options:
					assets: ['.temp/scripts/**/*.js']
					deleteOriginals: true
				src: []

		includeSource:
			options:
				basePath: '.temp'
			myTarget:
				files:
					'.temp/index.html': '.temp/index.html'

		# Run tasks when monitored files change
		watch:
			basic:
				files: [
					'src/fonts/**'
					'src/images/**'
					'src/scripts/**/*.js'
					'src/styles/**/*.css'
					'src/**/*.html'
				]
				tasks: [
					'copy:app'
					'copy:dev'
					'karma'
				]
				options:
					livereload: true
					nospawn: true
			coffee:
				files: 'src/scripts/**/*.coffee'
				tasks: [
					'clean:working'
					'coffeelint'
					'copy:app'
					'ngClassify:app'
					'coffee:app'
					'copy:dev'
					'includeSource'
					'karma'
				]
				options:
					livereload: true
					nospawn: true
			less:
				files: 'src/styles/**/*.less'
				tasks: [
					'copy:app'
					'less'
					'copy:dev'
				]
				options:
					livereload: true
					nospawn: true
			test:
				files: 'test/**/*.*'
				tasks: [
					'karma'
				]
			# Used to keep the web server alive
			none:
				files: 'none'
				options:
					livereload: true

	# ensure only tasks are executed for the changed file
	# without this, the tasks for all files matching the original pattern are executed
	grunt.event.on 'watch', (action, filepath, key) ->
		file = filepath.substr(4) # trim "src/" from the beginning.  I don't like what I'm doing here, need a better way of handling paths.
		dirname = path.dirname file
		ext = path.extname file
		basename = path.basename file, ext

		grunt.config ['copy', 'app'],
			cwd: 'src/'
			src: file
			dest: '.temp/'
			expand: true

		copyDevConfig = grunt.config ['copy', 'dev']
		copyDevConfig.src = file

		if key is 'coffee'
			# delete associated temp file prior to performing remaining tasks
			# without doing so, shimmer may fail
			grunt.config ['clean', 'working'], [
				path.join('.temp', dirname, "#{basename}.{coffee,js,js.map}")
			]

			copyDevConfig.src = [
				path.join(dirname, "#{basename}.{coffee,js,js.map}")
				'scripts/main.{coffee,js,js.map}'
			]

			coffeeConfig = grunt.config ['coffee', 'app', 'files']
			coffeeConfig.src = file
			coffeeLintConfig = grunt.config ['coffeelint', 'app', 'files']
			coffeeLintConfig = filepath

			grunt.config ['coffee', 'app', 'files'], coffeeConfig
			grunt.config ['coffeelint', 'app', 'files'], coffeeLintConfig

		if key is 'less'
			copyDevConfig.src = [
				path.join(dirname, "#{basename}.{less,css}")
				path.join(dirname, 'styles.css')
			]

		grunt.config ['copy', 'dev'], copyDevConfig

	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Enter the following command at the command line to execute this build task:
	# grunt build
	grunt.registerTask 'build', [
		'clean:working'
		'coffeelint'
		'copy:app'
		'ngClassify'
		'coffee:app'
		'less'
		'includeSource'
		'copy:dev'
	]

	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Opens the app in the default browser
	# Watches for file changes, and compiles and reloads the web browser upon change
	# Enter the following command at the command line to execute this build task:
	# grunt or grunt default
	grunt.registerTask 'default', [
		'build'
		'connect'
		'watch'
	]

	# Identical to the default build task
	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Opens the app in the default browser
	# Watches for file changes, and compiles and reloads the web browser upon change
	# Enter the following command at the command line to execute this build task:
	# grunt dev
	grunt.registerTask 'dev', [
		'default'
	]

	# Compiles the app with optimized build settings
	# Places the build artifacts in the dist directory
	# Enter the following command at the command line to execute this build task:
	# grunt prod
	grunt.registerTask 'prod', [
		'clean:working'
		'coffeelint'
		'copy:app'
		'ngClassify'
		'coffee:app'
		'imagemin'
		'less'
		'cacheBust'
		'includeSource'
		'copy:prod'
	]

	# Opens the app in the default browser
	# Build artifacts must be in the dist directory via a prior grunt build, grunt, grunt dev, or grunt prod
	# Enter the following command at the command line to execute this build task:
	# grunt server
	grunt.registerTask 'server', [
		'connect'
		'watch:none'
	]

	# Looks like the prevailing winds are pointing to use 'serve' instead of 'server'
	# Why not both?  :)
	# grunt serve
	grunt.registerTask 'serve', [
		'server'
	]

	# Compiles the app with non-optimized build settings
	# Places the build artifacts in the dist directory
	# Runs unit tests via karma
	# Enter the following command at the command line to execute this build task:
	# grunt test
	grunt.registerTask 'test', [
		'build'
		'karma'
	]
