# Git Rugged

## Implementation

1. Parse `git_status`
  - Do delegate calls like file
2. Make my own object graph
3. When I get commands like `add`
  - Send out delegate call backs like "didMoveFileFrom"
  - Can I observer the status of the property? E.g., see when it's status gets added to staged. [Module: Observable (Ruby 2.0.0)](http://ruby-doc.org/stdlib-2.0/libdoc/observer/rdoc/Observable.html)
  - Assert that the file has been added? E.g., assert that it's status matches staged?
  
I think I want a second object that manages which area a file moves from:
  - E.g., this would get delegate calls like `didChangeFile:oldArea:newArea` and change them to index paths?