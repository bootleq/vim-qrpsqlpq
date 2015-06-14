Vim QuickRun psql Configuration Pack
====

Some minor setting for using Vim as `psql` client, with [vim-quickrun][quickrun] plugin.

Sorry for such an ugly name, qrpsqlpq for <b>Q</b>uick<b>R</b>un <b>PSQL</b> <b>P</b>ac<b>K</b>.

This plugin tries to be unobtrusive, only adds `sql/qrpsqlpq` type for
quickrun, only takes effect when running quickrun with that type.

For example: call `qrpsqlpq#run()` on a .sql file.


Features
----

- Output `psql` execution result in split/vsplit buffer.
- Format psql *"expanded"* output result:
  - Blank lines between records.
  - Fold each record.
  - Minor highlight.
- Format `EXPLAIN` output result:
  - Convert time display `cost=1.00..5.00` to `COST: 4.00`.
  - Mark bottleneck entry with `MAX` text.
  - Minor highlight.
- Detect Rails development db name by [Rails.vim][rails.vim].


Dependency
----

- [thinca/vim-quickrun][quickrun]



[quickrun]: https://github.com/thinca/vim-quickrun
[rails.vim]: https://github.com/tpope/vim-rails
