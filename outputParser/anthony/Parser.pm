#!/usr/bin/perl

package Parser;

use 5.14.2;
use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;
    return $self;
}

sub setOutFile {
    my ($self, $outFile) = @_;

    open(my $fh, '>:encoding(UTF-8)', $outFile)
	or die "Could not open file '$outFile': $!";
    $self->{out_File} = $fh;
}

sub parseFile {
    my ($self, $fileName) = @_;

    open(DATAFILE, $fileName)
	or die "Could not open file '$fileName': $!";
    my @lines = <DATAFILE>;
    close(DATAFILE);

    for my $i (0 .. $#lines){
	#Most P sections take two lines, but not all.
	if(substr($lines[$i], 0, 1) eq "P"){
	    my $next = $i+1;
	    my $line = $lines[$i];
	    chomp $line;
	    if (substr($lines[$next], 0, 8) eq "/scratch") {
		$line .=';';
		$line .= $lines[$next];
	    }
	    $self->parseLine($line);
	}
    }
}

sub parseLine {
    my ($self, $line) = @_;

    my $outFile = $self->{out_File};    
    chomp $line;
    my @fields = split(";", $line);
    
    my $timestamp;
    if ($#fields >= 9) {
	$timestamp = $self->formatTimestamp($fields[9]);
    } else {
	$timestamp = "";
    }

    $fields[4] =~ s/ (\/scratch) (\/\d+) (\[\d+\]) (\.moab01\.westgrid\.uvic\.ca) (\/.\.) (\w*)//x;
    
    print $outFile $fields[7] . ';' . $fields[6] . ';' . $fields[4]
	. ';' . $fields[3] . ';' . $fields[5] . ';' . $timestamp . "\n";
}

sub formatTimestamp {
    my ($self, $date) = @_;
    my @parts = split(" ", $date);
    
    my $months = {"Jan"=>1, "Feb"=>2, "Mar"=>3, "Apr"=>4,
		  "May"=>5, "Jun"=>6, "Jul"=>7, "Aug"=>8,
		  "Sep"=>9, "Oct"=>10, "Nov"=>11, "Dec"=>12};

    my $month = $months->{$parts[2]};
    
    return $parts[3] . "-". $month . "-" . $parts[1] . " " . $parts[4] . " " . $parts[5];
}

1;
