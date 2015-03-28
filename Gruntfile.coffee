module.exports = (grunt) ->

	grunt.initConfig

		# builds webapp from webapp/
		# puts the bundle in server/static/
		# except index.html, which goes in server/templates/
		coffeeify: 
			compile: 
				files: [
					src: ['webapp/lib/*.coffee', 'webapp/main.coffee'],
					dest: 'server/static/bundle.js'
	      		]

		copy:
			# index.html goes in server/templates
			html:
				src: 'webapp/index.html'
				dest: 'server/templates/index.html'
			assets:
				expand: true
				cwd: 'webapp/assets/'
				src: '**'
				dest: 'server/static/assets/'
				flatten: true
				filter: 'isFile'
		sass:
			compile:
				files:
					'server/static/style.css': 'webapp/styles/main.scss'
		watch:
			coffeeify:
				files: ['webapp/lib/*.coffee', 'webapp/main.coffee']
				tasks: ['coffeeify:compile']
			copy:
				files: ['webapp/index.html', 'webapp/assets/*']
				tasks: ['copy:html', 'copy:assets']
			sass:
				files: ['webapp/styles/*.scss']
				tasks: ['sass:compile']

					
	grunt.loadNpmTasks 'grunt-coffeeify'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-sass'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.registerTask 'default', ['coffeeify', 'copy', 'sass']
