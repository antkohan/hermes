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
    $self->{_outSHAs} = $fhs[3];

    return $self;
}

sub process_file {
    my ($self, @fields) = @_;

    my $outClass = $self->{_outClass};
    my $outMethod = $self->{_outMethod};
    my $outAttr = $self->{_outAttr};
    my $outSHAs = $self->{_outSHAs};

    if ($fields[1] eq "cLA") {

	my($shaFile, $isClass, $className, $fullClassName, $classType, $isPub, $isAb, $isFin, 
	   $extends, $impl, $path ,$basename, $ext, $shaInside, $depth, $compFrom) = @fields;

	$path =~ s/ (\/scratch) (\/\d+) (\[\d+\]) (\.moab01\.westgrid\.uvic\.ca) (\/.\.) (\w*)//x;

	my $data = join("\n", $shaFile, $className, $fullClassName, $path, $basename, $ext);
	my $sigSha = sha1_hex($data);

	my $output = join(';', $sigSha, $className, $fullClassName, $path, $basename, $ext);
	my $shaOutput = join(';', $sigSha, $shaFile);

	print $outClass $output . "\n";
	print $outSHAs $shaOutput . "\n";

    } elsif ($fields[1] eq "mET") {

	my $classSha = shift @fields;
	my ($isMet, $shaFile, $blank, $className, $fullClassName, $id, $fullId, $type, $params) = @fields;

	my $data = join("\n", $shaFile,$className, $fullClassName, $id, $fullId, $type, $params);
	my $sigSha = sha1_hex($data);

	my $output = join(';', $sigSha, $className, $fullClassName, $id, $fullId, $type, $params);
	my $shaOutput = join(';', $sigSha, $shaFile);

	print $outMethod $output . "\n";
	print $outSHAs $shaOutput. "\n";

    } else {

	my $classSha = shift @fields;
	my ($isAttr, $shaFile, $blank, $className, $fullClassName, $id) = @fields;

	my $data = join("\n", $shaFile,$className, $fullClassName, $id);
	my $sigSha = sha1_hex($data);

	my $output = join(';', $sigSha, $className, $fullClassName, $id);
	my $shaOutput = join(';', $sigSha, $shaFile);

	print $outAttr $output . "\n";
	print $outSHAs $shaOutput . "\n";
    }
}

my (@outFiles) = @ARGV;
my $proc = new processSignatures(@outFiles);
$proc->process_fields();
