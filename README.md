# KV

## Description
A super simple key value store written in Perl, using DBI and SQLite.

## Installation
This guide assumes the following:

* You've install `sqlite3`
* You've installed `cpanm`, and have set up the [local bootstrapping](https://metacpan.org/pod/local::lib#The-bootstrapping-technique)
* You have `$HOME/bin/` in your `$PATH`.

Simply:
```bash
$ git clone git@gitbub.com:mpstewart/kv.git
$ cd kv
$ make install
$ make db_init
```

This will:

* Install the Perl modules to `$HOME/perl5/lib/perl5/`
* Create the storage database file in `$HOME/.kv.db`, as well as migrate the schema.

## Usage

`kv` detects input piped to `STDIN` (and only from a pipe!) and will load it into a key value store stored in `$HOME/.kv.db`. The key for the stored item is the first argument passed to `kv`. Reading from the store is done simply by specifying the key with nothing coming in on `STDIN`.

### Writing to the store

```bash
$ echo "Hello world!" | kv greeting
```

### Reading from the store

```bash
$ kv greeting
Hello world!
```

### Overwriting a key

**WARNING** Currently, `kv` will silently overwrite any existing record. It's recommended to try to dump out the contents of a stored record if you're unsure if it already exists or not.

## Limitations

Currently, there's no way to _delete_ something from the store once it's in there. You can always `sqlite3 ~/.kv.db` and take care of that yourself, though. It's planned as an upcoming feature, though, once I add some option parsing support.

## Planned features

* More convenience around overwriting and deleting existing keys, probably via a set of `-f` and  `-d` flags.