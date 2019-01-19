package KV::App;
use strict;
use warnings;
use utf8;

use DBI;
use Env qw( HOME );

sub run         ( );
sub write_record  ($);
sub create_record ($);
sub update_record ($);
sub read_record   ($);
sub exists_record ($);

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
        write_record {
            key   => $KEY,
            value => $VALUE,
        };
    } else {
        die "No record found for key $KEY\n" unless exists_record $KEY;

        my $value = read_record $KEY;
        print $value;
    }

    exit 0;
}

sub write_record ($) {
    my $record = shift;

    my $key   = $record->{key  };
    my $value = $record->{value};

    if (exists_record $key) {
        update_record $record;
    } else {
        create_record $record;
    }

    return $record;
}

sub create_record ($) {
    my $record = shift;

    my @fields = qw( key value );
    my $fieldlist = join ", ", @fields;
    my $field_placeholders = join ", ", map {'?'} @fields;

    my $dml = "INSERT INTO records ($fieldlist) VALUES ($field_placeholders)";

    my $sth = $DBH->prepare($dml);

    my @values = map { $record->{$_} } @fields;

    $sth->execute(@values);
}

sub update_record ($) {
    my $record = shift;

    my $key   = $record->{key  };
    my $value = $record->{value};

    my $dml = "UPDATE records set value = ? WHERE key = ?";

    my $sth = $DBH->prepare($dml);

    $sth->execute($value, $key);

    return $record;
}

sub read_record ($) {
    my $key = shift;

    my $dql = "SELECT * FROM records WHERE key = ?";
    my $sth = $DBH->prepare($dql);

    $sth->execute($key);

    my $result = $sth->fetchrow_hashref();

    return $result->{value};
}

sub exists_record ($) {
	my $key = shift;
	my $value = read_record $key;
	
	return $value ? 1 : 0;
}

# On first run, will create the database in $HOME/.kv.db, then initialize a DBI
# connection to the store. In subsequent runs, will simply initialize the DBI
# connection. 'Subsequent' is determined by the prior existence of the store. If
# the database already exists, we just assume there's been a migration already,
# so we don't do one. Easy and/or peasy.
sub _init_dbh {
    die "Unable to locate db store. Please run `make db_init` in project directory.\n"
        unless -f $DB_LOCATION;
    $DBH= DBI->connect("dbi:SQLite:dbname=$DB_LOCATION","","");
}

1;
