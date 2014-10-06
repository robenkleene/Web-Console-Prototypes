# TextMate Document Watching Implementation

TextMate keeps track of bundles by an index of all bundles at `~/Library/Caches/com.macromates.TextMate/`. This index is kept up to date by replaying the file system events in reconstructing the index based on what's happened in the mean time.

`BundlesManager.mm`:

``` objective-c
- (void)updateWatchList:(std::set<std::string> const&)newWatchList
{
	struct callback_t : fs::event_callback_t
	{
		void set_replaying_history (bool flag, std::string const& observedPath, uint64_t eventId)
		{
			D(DBF_BundlesManager_FSEvents, bug("%s (observing ‘%s’)
", BSTR(flag), observedPath.c_str()););
			[[BundlesManager sharedInstance] setEventId:eventId forPath:[NSString stringWithCxxString:observedPath]];
		}

		void did_change (std::string const& path, std::string const& observedPath, uint64_t eventId, bool recursive)
		{
			D(DBF_BundlesManager_FSEvents, bug("%s (observing ‘%s’)
", path.c_str(), observedPath.c_str()););
			[[BundlesManager sharedInstance] reloadPath:[NSString stringWithCxxString:path] recursive:recursive];
			[[BundlesManager sharedInstance] setEventId:eventId forPath:[NSString stringWithCxxString:observedPath]];
		}
	};

	static callback_t callback;

	std::vector<std::string> pathsAdded, pathsRemoved;
	std::set_difference(watchList.begin(), watchList.end(), newWatchList.begin(), newWatchList.end(), back_inserter(pathsRemoved));
	std::set_difference(newWatchList.begin(), newWatchList.end(), watchList.begin(), watchList.end(), back_inserter(pathsAdded));

	watchList = newWatchList;

	for(auto path : pathsRemoved)
	{
		D(DBF_BundlesManager_FSEvents, bug("unwatch ‘%s’
", path.c_str()););
		fs::unwatch(path, &callback);
	}

	for(auto path : pathsAdded)
	{
		D(DBF_BundlesManager_FSEvents, bug("watch ‘%s’
", path.c_str()););
		fs::watch(path, &callback, cache.event_id_for_path(path) ?: FSEventsGetCurrentEventId(), 1);
	}
}
```

`OakDocumentView.mm`:

``` objective-c
struct document_view_callback_t : document::document_t::callback_t
{
  WATCH_LEAKS(document_view_callback_t);
  document_view_callback_t (OakDocumentView* self) : self(self) { }
  void handle_document_event (document::document_ptr document, event_t event)
  {
    if(event == did_change_marks)
    {
      [[NSNotificationCenter defaultCenter] postNotificationName:GVColumnDataSourceDidChange object:self];
    }
    else if(event == did_change_file_type)
    {
      for(auto const& item : bundles::query(bundles::kFieldGrammarScope, document->file_type()))
        self.statusBar.grammarName = [NSString stringWithCxxString:item->name()];
    }
    else if(event == did_change_indent_settings)
    {
      self.statusBar.tabSize  = document->buffer().indent().tab_size();
      self.statusBar.softTabs = document->buffer().indent().soft_tabs();
    }

    if(document->recent_tracking() && document->path() != NULL_STR)
    {
      if(event == did_save || event == did_change_path || (event == did_change_open_status && document->is_open()))
        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:[NSString stringWithCxxString:document->path()]]];
    }
  }
private:
  __weak OakDocumentView* self;
};
```
