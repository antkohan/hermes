#!/usr/bin/perl

package processJars;

use strict;
use warnings;
use processor;
use File::Basename;

our @ISA = qw(processor);

sub new {
    my($class, $outFile) = @_;

    my $self = $class->SUPER::new();
    
    open(my $fh, '>>:encoding(UTF-8)', $outFile)
	or die "Could not open file '$outFile':$!";

    $self->{_outFile} = $fh;
    return $self;
} 

sub process_file {
    my($self, @fields) = @_;
   
    my $outFile = $self->{_outFile};

    if($fields[0] eq "Z" and $fields[1] eq "Starting") {
	my $fullPath = $fields[2];
	$fullPath =~ s/ \/global\/scratch\/dmg\/maven //x;
	$fullPath =~ s/ (\/scratch) (\/\d+) (\[\d+\]) (\.moab01\.westgrid\.uvic\.ca) (\/.\.) (\w*)//x;
	my $path = dirname($fullPath);
	my $fileName = basename($fullPath);
	my $shaContainer = $fields[3];
	my $output = join(";", $shaContainer, $path, $fileName);
	print $outFile $output . "\n";
    }

}

my $outFile = shift;
my $proc = new processJars($outFile);
$proc->process_fields();
