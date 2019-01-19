package KV::App;
use strict;
use warnings;
use utf8;

use DBI;
use Env qw( HOME );

sub run         ( );
sub write_item  ($);
sub create_item ($);
sub update_item ($);
sub read_item   ($);
sub exists_item ($);

our $DB_LOCATION = "$HOME/.kv.db";

my $DBH;

my $KEY = pop @ARGV if scalar @ARGV;
my $VALUE = join "", <STDIN> unless (-t STDIN);

my $HAS_STDIN = $VALUE ? 1 : 0;

sub run () {
    my $class = shift;
    _init_dbh();

    die "Must provide key\n" unless $KEY;

    if ($HAS_STDIN) {
        write_item {
            key   => $KEY,
            value => $VALUE,
        };
    } else {
        die "No item found for key $KEY\n" unless exists_item $KEY;

        my $value = read_item $KEY;
        print $value;
    }

    exit 0;
}

sub write_item ($) {
    my $item = shift;

    my $key   = $item->{key  };
    my $value = $item->{value};

    if (exists_item $key) {
        update_item $item;
    } else {
        create_item $item;
    }

    return $item;
}

sub create_item ($) {
    my $item = shift;

    my @fields = qw( key value );
    my $fieldlist = join ", ", @fields;
    my $field_placeholders = join ", ", map {'?'} @fields;

    my $dml = "INSERT INTO items ($fieldlist) VALUES ($field_placeholders)";

    my $sth = $DBH->prepare($dml);

    my @values = map { $item->{$_} } @fields;

    $sth->execute(@values);
}

sub update_item ($) {
    my $item = shift;

    my $key   = $item->{key  };
    my $value = $item->{value};

    my $dml = "UPDATE items set value = ? WHERE key = ?";

    my $sth = $DBH->prepare($dml);

    $sth->execute($value, $key);

    return $item;
}

sub read_item ($) {
    my $key = shift;

    my $dql = "SELECT * FROM ITEMS WHERE key = ?";
    my $sth = $DBH->prepare($dql);

    $sth->execute($key);

    my $result = $sth->fetchrow_hashref();

    return $result->{value};
}

sub exists_item ($) {
	my $key = shift;
	my $value = read_item $key;
	
	return $value ? 1 : 0;
}

# On first run, will create the database in $HOME/.kv.db, then initialize a DBI
# connection to the store. In subsequent runs, will simply initialize the DBI
# connection. 'Subsequent' is determined by the prior existence of the store. If
# the database already exists, we just assume there's been a migration already,
# so we don't do one. Easy and/or peasy.
sub _init_dbh {
    die "Unable to locate db store. Please run `make install`."
        unless -f $DB_LOCATION;
    $DBH= DBI->connect("dbi:SQLite:dbname=$DB_LOCATION","","");
}

1;
