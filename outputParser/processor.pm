#!/usr/bin/perl

# the base class


use strict;



package processor;

sub new
{
    my $class = shift;
    my $self = {
        _filename => shift,
	_currentFile => '',
	_currentSha  => '',
	_stackFiles => [],
	_currentLevel => 0,
    };
    #print STDERR "To process [", $self->{_filename},"]\n";
    bless $self, $class;
    return $self;
}

sub process_file{
    my ($self, $data, @fields) = @_;
#    print "-------------$data-------------";
}


sub process {
    my ($self) = @_;
    my $fh;

    my $stack = $self->{_stackFiles};

    if (defined()) {
	open($fh, $self->{_filename}) or die "Unable to open " . $self->{_filename} ."\n";
    } else {
	$fh = *STDIN;
    }

    while (<$fh>) {
again:
	chomp;
	if (/^Z;Starting;(.+);([0-9a-f]{40})$/) {
	    $self->{_currentFile} = $1;
	    $self->{_currentSha1} = $2;
	    $self->{_currentLevel}++;
	    push(@$stack, [$self->{_currentFile},
			   $self->{_currentSha1},
		 ]);

	} elsif (/^Z;Ending;(.+)/) {
	    my $parm = $1;
	    my $top = pop(@$stack);
	    $self->{_currentLevel}--;
	    print STDERR "top;", $$top[0],  $$top[1], "\n" if $parm ne $$top[0];

	} elsif (/^E;@@@@@@/) {
	} elsif (/^A;BeginUnpack;/) {
	} elsif (/^A;EndUnpack;/) {
	} elsif (/^T;BEGIN;/) {
#	    print STDERR "Recursing...\n";
	} elsif (/^T;END;/) {
#	    print STDERR "exiting Recursing...\n";
	} elsif (/^P;/) {
	    my @fields = split(';', substr($_, 2));

#	    print "Depth: ", $fields[0], ";\n";
#	    print "name: ", $fields[1], ";\n";
#	    print "basename: ", $fields[2], ";\n";
#	    print "path: ", $fields[3], ";\n";
#	    print "ext: ", $fields[4], ";\n";
#	    print "sha1: ", $fields[5], ";\n";
#	    print "sha1 inside: ", $fields[6], ";\n";

	    my $data = '';
	    while (<$fh>) {
		last if /^[ZAPT];/;
		$data .= $_;
	    }

	    $self->process_file($data, @fields);
	    goto again if /^[ZAP];/;
	} else {
	    print "illegal record: $_\n";
	}
    }
    close $fh;

}

sub process_fields {
    my ($self) = @_;
    
    my $fh = *STDIN;
    while(<$fh>) {
	chomp;
	my @fields = split(';', $_);
	$self->process_file($_, @fields);
    }
}

1;
