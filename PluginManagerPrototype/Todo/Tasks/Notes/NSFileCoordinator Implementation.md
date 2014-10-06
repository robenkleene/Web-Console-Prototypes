# `NSFileCoordinator` Implementation

I'll want to make all file system access conform to `NSFileCoordinator` APIs. These will need tests.

## Implementation

* How do I write tests for `NSFileCoordinator` APIs?
  * E.g., have an `NSFileManager` do a `coordinateWritingItemAtURL:` on a file being presented. This should trigger a `presentedSubitemDidChangeAtURL:` notification.
* Test `accommodatePresentedItemDeletionWithCompletionHandler:`. E.g., open a plugin, then delete it from the file system. It should receive a `accommodatePresentedItemDeletionWithCompletionHandler:` telling the item to be deleted.

## Notes

### Deleting Presented Items

`accommodatePresentedItemDeletionWithCompletionHandler:` should be called when an item is about to be deleted.

### Writing a New File with NSFileCoordinator

``` objective-c
- (BOOL)saveAndReturnError:(NSError **)outError {
    NSURL *url = [self url];
    __block BOOL didWrite = NO;
    NSFileCoordinator* fc = [[NSFileCoordinator alloc]
                                initWithFilePresenter:self];
    [fc coordinateWritingItemAtURL:url
                           options:NSFileCoordinatorWritingForReplacing
                             error:outError
                        byAccessor:^(NSURL *updatedURL) {
        NSFileWrapper *fw = [self fileWrapper];
        didWrite = [fw writeToURL:updatedURL options:0
              originalContentsURL:nil error:outError];
    }];
    return didWrite;
}
//*
```


### Summary

* Use NSFileCoordinator when you read and write files
* Use NSFilePresenter to hear about changes that happened
* Use NSFileVersion to deal with conflicts
