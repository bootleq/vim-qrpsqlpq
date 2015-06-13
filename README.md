Vim QuickRun psql Configuration Pack
====

Some minor setting for using Vim as psql client.

Sorry for such an ugly name, qrpsqlpq for QuickRun PSQL PacK.

This plugin tries to be unobtrusive, only adds a `sql/qrpsqlpq` type for
quickrun, and only takes effect when running quickrun with that type.

For example: call `qrpsqlpq#run()` on a sql file.


Features
----

- Output `psql` execution result to split/vsplit buffer.
- Format psql *expanded* output result.
- Detect Rails development db name by [Rails.vim][rails.vim].


Dependency
----

- [thinca/vim-quickrun][quickrun]



[quickrun]: https://github.com/thinca/vim-quickrun
[rails.vim]: https://github.com/tpope/vim-rails
