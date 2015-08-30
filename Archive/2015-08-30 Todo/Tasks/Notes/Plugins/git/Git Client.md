# Git Client

* [ ] `mktemp` is a dependency
* [ ]  Write a `GitTestHelper`
* [ ] Write a CoffeeScript helper based off of `do_javascript_function`

1. On Init makes a git repo in /tmp
2. Clean up deletes that repo

## `GitTestHelper`

### API

- `make_file_at_path(path, content)`
- `make_folder_at_path(path)`
- `delete_folder_at_path(path)`
- `git_init_at_path(path)`