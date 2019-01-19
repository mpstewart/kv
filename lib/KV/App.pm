package KV::App;
use strict;
use warnings;
use utf8;

use Find::Lib '../lib/';

use Moose;
use DBI;
use Getopt::Long;

use KV::Schema;

has schema => (
    is => 'ro',
    isa => 'KV::Schema',
    lazy_build => 1,
);

sub _build_schema {
    my $self = shift;

    my $db_filename = $self->db_filename;

    return KV::Schema->connect("dbi:SQLite:$db_filename");
}

has db_filename => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_db_filename { 
    my $self = shift;

    my $homedir = $ENV{HOME};

    return "$homedir/.kv.db";
}

has stdin => (
    is => 'ro',
    isa => 'Maybe[Str]',
    lazy_build => 1,
);

sub _build_stdin {
    my $self = shift;

    my $stdin;
    if (-t STDIN) {
        return undef;
    } else {
        $stdin = join "", <STDIN>;
    }

    return $stdin;
}

has key => (
    is => 'ro',
    isa => 'Maybe[Str]',
    lazy_build => 1,
);

sub _build_key {
    my $self = shift;

    if (my $key = pop @ARGV) {
        return $key;
    }

    die "Must have key to continue\n";
}

sub run {
    my $self = shift;
    $self->_init_db();

    if ($self->stdin) {
        $self->write_key();
    } else {
        $self->read_key();
    }
}

sub write_key {
    my $self = shift;

    my $key = $self->key;
    my $value = $self->stdin;

    eval {
        $self->schema->resultset("Item")->create({
            key => $key,
            value => $value,
        });
    }; if ($@ =~ /UNIQUE/) {
        die "You must specify a unique key name\n";
    }
}

sub read_key {
    my $self = shift;

    my $key = $self->key;

    my $item = $self->schema->resultset("Item")->find({
        key => $key
    });

    if ($item) {
        print $item->value if $item;
        exit 0;
    } else {
        die "No value foud for key '$key'\n";
    }

}

# Creates and migrates a database file if none exists
sub _init_db {
    my $self = shift;

    return if (-e $self->db_filename);

    my $ddl = qq{
        CREATE TABLE items(
            item_id   INT PRIMARY KEY,
            key       VARCHAR(20) UNIQUE,
            value     VARCHAR(1000),
            encrypted TINYINT(1) DEFAULT 0
        );
    };

    my $dbfile = $self->db_filename;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
    my $sth = $dbh->prepare($ddl);

    $sth->execute();
}

__PACKAGE__->meta->make_immutable();

1;
