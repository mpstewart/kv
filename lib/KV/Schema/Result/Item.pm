package KV::Schema::Result::Item;

use strict;
use warnings;
use utf8;

use base 'DBIx::Class::Core';

__PACKAGE__->table('items');
__PACKAGE__->add_columns(qw( item_id key value encrypted ));
__PACKAGE__->set_primary_key('item_id');
