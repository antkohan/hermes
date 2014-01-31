#!/usr/bin/perl

package UseDB;

use 5.14.2;
use strict;
use warnings;
use DBI;

sub new {
    my ($class, $dbName, $userName, $pass) = @_;

    my $self = {
	db_Name => $dbName,
      	user_Name => $userName,
	pass => $pass
    };

    bless $self, $class;
    return $self;
}

sub insertData {
    my ($self, $file) = @_;
    my $dbh = DBI->connect("dbi:Pg:dbname=$self->{db_Name}","$self->{user_Name}","$self->{pass}");
    $dbh->do("COPY files FROM STDIN WITH DELIMITER ';'");
   
    open(my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file '$file': $!";

    #this contains the most absurd bug I've seen in my life
    while(my $line = <$fh>){
	$dbh->pg_putcopydata($line);
    }
    $dbh->pg_putcopyend;

    $dbh->disconnect();
}

1;
