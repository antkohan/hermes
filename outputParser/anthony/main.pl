#!/usr/bin/perl

use 5.14.2;
use strict;
use warnings;
use File::Spec;

use Parser;
use UseDB;


my $outFile = "output.csv";
my $outFilePath = File::Spec->rel2abs($outFile);

my $parser = new Parser();
$parser->setOutFile($outFile);

my $db = new UseDB("mydb", "tony", "");

my @files = </Users/antkohan/Desktop/parser/testInfo/*>; 
foreach my $file (@files){
    chomp $file;
    if($file =~ /part\.out\.\d{4}$/){
	$parser->parseFile($file);
    }
}

#$db->insertData($outFile);
