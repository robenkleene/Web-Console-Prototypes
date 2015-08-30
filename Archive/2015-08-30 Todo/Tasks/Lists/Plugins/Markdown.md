# Markdown

* Style Fixes
	* Style code blocks correctly, right now whitespace is being shown between the lines
	* Hierarchical lists show a margin between the next list. E.g., `<ul><li>An Item</li><ul><li>A sub-tem</li></ul><li>Another item</li><ul>`  shows a line-break after the second `</ul>`
* Markdown Plugin and file URLs, e.g., if you click to another markdown file what should happen? Or a link to an image, etc...?
* Fix it to run with selected text, i.e., enable piping to the plugin
	* For it to run with selection, I'll need a way to run a plugin and pass to STDIN in one sweep
	* Test Markdown with selection
