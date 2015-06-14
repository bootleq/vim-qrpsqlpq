Vim QuickRun psql Configuration Pack
====

Some minor setting for using Vim as psql client.

Sorry for such an ugly name, qrpsqlpq for QuickRun PSQL PacK.

This plugin tries to be unobtrusive, only adds a `sql/qrpsqlpq` type for
quickrun, and only takes effect when running quickrun with that type.

For example: call `qrpsqlpq#run()` on a sql file.


Features
----

- Output `psql` execution result in split/vsplit buffer.
- Format psql *expanded* output result:
  - Blank lines between records.
  - Fold each record.
  - Minor highlights.
- Format `EXPLAIN` output result:
  - Convert time display `cost=1.00..5.00` to `COST: 4.00`.
  - Mark bottleneck entry with `MAX` text.
  - Minor highlights.
- Detect Rails development db name by [Rails.vim][rails.vim].


Dependency
----

- [thinca/vim-quickrun][quickrun]



[quickrun]: https://github.com/thinca/vim-quickrun
[rails.vim]: https://github.com/tpope/vim-rails
