#!/usr/bin/perl

package processSignatures;

use strict;
use warnings;
use processor;

use Digest::SHA qw(sha1_hex);

our @ISA = qw(processor);

sub new {
    my ($class, @outFiles) = @_;

    my $self = $class->SUPER::new();

    my @fhs;
    for my $i (0 .. $#outFiles){
	open ($fhs[$i], '>>:encoding(UTF-8)', $outFiles[$i])
	    or die "Could not open file '$outFiles[$i]': $!";
    }
    $self->{_outClass} = $fhs[0];
    $self->{_outMethod} = $fhs[1];
    $self->{_outAttr} = $fhs[2];

    return $self;
}

sub process_signatures {
    my ($self) = @_;
    
    my $fh = *STDIN;
    while(<$fh>) {
	my @fields = split(';', $_);
	$self->process_file(@fields);
    }
}

sub process_file {
    my ($self, @fields) = @_;

    my $outClass = $self->{_outClass};
    my $outMethod = $self->{_outMethod};
    my $outAttr = $self->{_outAttr};

    if ($fields[1] eq "cLA") {
	my($shaFile, $isClass, $className, $fullClassName, $classType, $isPub, $isAb, $isFin, 
	   $extends, $impl, $path ,$basename, $ext, $shaInside, $depth, $compFrom) = @fields;
	$path =~ s/ (\/scratch) (\/\d+) (\[\d+\]) (\.moab01\.westgrid\.uvic\.ca) (\/.\.) (\w*)//x;
	my $data = join("\n", $shaFile, $shaInside, $className, $fullClassName, $path, $basename, $ext);
	my $sigSha = sha1_hex($data);
	my $output = join(';', $sigSha, $shaFile, $shaInside, $className, $fullClassName, $path, $basename, $ext);
	print $outClass $output . "\n";
    } elsif ($fields[1] eq "mET") {
	my $classSha = shift @fields;
	my ($isMet, $shaFile, $blank, $className, $fullClassName, $id, $fullId, $type, $params) = @fields;
	my $data = join("\n", $shaFile,$className, $fullClassName, $id, $fullId, $type, $params);
	my $sigSha = sha1_hex($data);
	my $output = join(';', $sigSha,$shaFile,$className, $fullClassName, $id, $fullId, $type, $params);
	print $outMethod $output . "\n";
    } else {
	my $classSha = shift @fields;
	my ($isAttr, $shaFile, $blank, $className, $fullClassName, $id) = @fields;
	my $data = join("\n", $shaFile,$className, $fullClassName, $id);
	my $sigSha = sha1_hex($data);
	my $output = join(';', $sigSha,$shaFile,$className, $fullClassName, $id);
	print $outAttr $output . "\n";
    }
}

my ($outClass, $outMethod, $outAttr) = @ARGV;
my $proc = new processSignatures($outClass, $outMethod, $outAttr);
$proc->process_signatures();
