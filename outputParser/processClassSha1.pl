#!/usr/bin/perl

use strict;

# Simply print the sha1 of the file and the one of its containing data


package processorGlobalDeclsSha1;
use processor;
use strict;
use strict;
use Digest::SHA qw(sha1_hex);

our @ISA = qw(processor);    # inherits from Person



sub process_file{
    my ($self, $data, @fields) = @_;
    
    return if $data eq "";

    my ($depth, $name, $basename, $path, $ext,$sha1Inside,  $sha1) = @fields;

    my @lines = split("\n", $data);
    my $what = shift @lines;

    $data = join("\n", @lines);

    my $dataSha = sha1_hex($data);
    print "$sha1;$dataSha\n";
}


######################
my $file = shift;
my $proc = new processorGlobalDeclsSha1($file);
$proc->process();


