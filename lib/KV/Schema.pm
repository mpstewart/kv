package KV::Schema;

use strict;
use warnings;
use utf8;

use v5.28.1;

use DBIx::Class;
use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces();

1;
