module.exports = function(grunt) {
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		jade: {
			options: {
				pretty: true
			},
			no_options: {
				files: {
					'example/index.html': ['example/jade/index.jade'],
					'test/lib/index.html': ['test/lib/jade/index.jade']
				}
			}
		},
		watch: {
		  scripts: {
		    files: ['**/*.jade'],
		    tasks: ['jade'],
		    options: {
		      spawn: false,
		    },
		  },
		},
	});

	grunt.loadNpmTasks('grunt-contrib-jade');
	grunt.loadNpmTasks('grunt-contrib-watch');

	grunt.registerTask('default', ['jade']);
};