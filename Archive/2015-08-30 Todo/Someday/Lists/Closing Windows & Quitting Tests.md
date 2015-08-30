# Closing Windows & Quitting Tests

These tests are waiting for a method for checking if a process is running before being useful.

## Closing Windows

### Test closing a window with a running tasks terminates the task

1. Run a plugin that runs a task that needs to be interrupted
2. Assert that the task is running
3. Tell the window to close
4. Confirm the close window dialog
5. Assert that the task is terminated
6. Assert that the plugin does not have windows

### Closing a window with a running tasks and canceling the close does not close the window and does not interrupt the task

1. Run a plugin that runs a task that needs to be interrupted
2. Assert that the task is running
3. Tell the window to close
4. Cancel the close window dialog
5. Assert that the task is running
6. Assert that the plugin still has windows
