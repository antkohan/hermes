#!/usr/bin/perl

package processFileData;

use strict;
use warnings;
use processor;

our @ISA = qw(processor);

sub new {
    my ($class, $outFile) = @_;
    
    my $self = $class->SUPER::new();

    open(my $fh, '>>:encoding(UTF-8)', $outFile)
	or die "Could not open file '$outFile': $!";

    $self->{_outFile} = $fh;
    return $self;
}

sub process_file {
    my ($self, $data, @fields) = @_;
    
    my $outFile = $self->{_outFile};
    my $timestamp = "";
    if ($data ne '') {
	my @parts = split(';', $data); 
	$timestamp = $self->formatTimestamp($parts[1]);
    }
    $fields[3] =~ s/ (\/scratch) (\/\d+) (\[\d+\]) (\.moab01\.westgrid\.uvic\.ca) (\/.\.) (\w*)//x;
    
    print $outFile $fields[6] . ';' . $fields[5] . ';' . $fields[3]
	. ';' . $fields[2] . ';' . $fields[4] . ';' . $timestamp . "\n";
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

my $outFile = shift;
my $proc = new processFileData($outFile);
$proc->process();

