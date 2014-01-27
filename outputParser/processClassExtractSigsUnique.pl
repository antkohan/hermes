#!/usr/bin/perl

use strict;

package processorGlobalDecls;
use base processor;
use strict;
use DBI;


sub Simple_Query
{
    my ($dbh, $query, @parms) = @_;
    my $q = $dbh->prepare($query);
    $q->execute(@parms);
    return $q->fetchrow_array();

}

sub Simple_Update
{
    my ($dbh, $query, @parms) = @_;
    my $q = $dbh->prepare($query);
    $q->execute(@parms);
}



my $dbName = 'maveni';

use Digest::SHA qw(sha1_hex);

our @ISA = qw(processor);    

sub new {
    my ($class, @args) = @_;

    my $self = $class->SUPER::new(@args);
    $self->{_db} =  my $dbh = DBI->connect("dbi:Pg:dbname=$dbName", "dmg", "",
					    { RaiseError => 1, AutoCommit => 0 }
	);
    return $self;
}



sub process_file{
    my ($self, $data, @fields) = @_;
    
    return if $data eq "";

    my ($depth, $name, $basename, $path, $ext,$sha1Inside,  $sha1) = @fields;

    my @lines = split("\n", $data);
    my $what = shift @lines;

    $data = join("\n", @lines);

    my $dataSha = sha1_hex($data);

    my $processed = $self->has_been_processed($dataSha);

    return if $processed;

    my $compiledFrom;
    my $classDecl = '';

    my $className;
    my $classFullName;
    my $classType;
    my $classExtends;
    my $classImplements;
    my $classPublic;
    my $classIsAbstract;
    my $classIsFinal;

    if ($lines[0] =~  /^Compiled from/) {
	$compiledFrom = shift @lines;
    }

    my $first = 1;
    while (scalar(@lines) > 0) {
	my $l = shift @lines;
	if ($l =~ /\{$/) { # end in {, means class declaration
	    ($className, $classFullName, $classType, $classPublic, $classIsAbstract, $classIsFinal, $classExtends, $classImplements) = $self->parse_class_declaration($l);
	    print "$sha1;cLA;$className;$classFullName;$classType;$classPublic;$classIsAbstract;$classIsFinal;$classExtends;$classImplements;$path;$basename;$ext;$sha1Inside;$depth;$compiledFrom;$l;\n";
	} elsif ($l eq "}") {
	    $className = '';
	} elsif ($l =~ /;$/) {
	    my ($id, $fullId, $type, $isMethod, $isPublic, $isStatic, $isAbstract, $parms, $throws) = $self->parse_declaration($l);
	    
	    if ($className eq "")  {
		print STDERR "We don't know the class name [$l] in [$sha1][$name]\n";
	    }

	    print "$dataSha;", $isMethod?"mET":"fIE",";$sha1;;$className;$classFullName;$id;$fullId;$type;$parms;$throws;$isPublic;$isAbstract;$isStatic;$isMethod;$throws;{$l}\n";
	} else {
	    print STDERR "Unknown field [$l] in [$sha1][$name]\n";
	}
    }
    $self->update_processed($dataSha, $sha1);
}

sub has_been_processed {
    my ($self, $sha) = @_;
    
    return Simple_Query($self->{_db}, "select extracted from sigs where sigsha1 = '$sha'");

}

sub update_processed {
    my ($self, $sha, $shaFile) = @_;
    
    Simple_Update($self->{_db}, "update sigs set insidefilesha1 = '$shaFile', extracted = TRUE where sigsha1 = '$sha'");
}

sub finish {
    my ($self, $sha, $shaFile) = @_;
    my $dbh = $self->{_db};
    $dbh->commit();
    $dbh->disconnect();
}


sub parse_class_declaration {
    my ($self, $l) = @_;
    my $original = $l;
    my $extends = '';
    my $implements = '';
    my $fullClass;
    my $type;
    my $id;
    my $isPublic = 0;
    my $isFinal = 0;
    my $isAbstract = 0;

    if (not ($l =~ s/\{$//)) {
	die "Illegal class name [$original][$l]\n";
    }
    while ($l =~ s/ (extends|implements) ([^ ]+)$//) {
	my $type = $1;
	if ($type eq "extends") {
	    die "already an implements [$original][$l]" if $extends ne "";
	    $extends = $2;
	} else {
	    die "already an implements [$original][$l]" if $implements ne "";
	    $implements = $2;
	}
    }

    while ($l =~ s/^(class|public|interface|abstract|final) //) {
	my $t = $1;
	if ($t eq "public") {
	    $isPublic = 1;
	}
	if ($t eq "final") {
	    $isFinal = 1;
	}
	if ($t eq "abstract") {
	    $isAbstract  = 1;
	}
	if ($t eq "class") {
	    die "already type [$original][$l]" if $type ne "";
	    $type  = "class";
	}

	if ($t eq "interface") {
	    die "already type [$original][$l]" if $type ne "";
	    $type  = "interace";
	}
    }

    if ($l =~ s/^([^ ]+)$//) {
	$fullClass = $1;
    } else {
	die "Illegal class name [$original][$l]\n";
    }
    $id = $self->extract_name_from_full_name($fullClass);
    $type = $l;

    return ($id, $fullClass, $type, $isPublic, $isAbstract, $isFinal, $extends, $implements);
}

sub parse_declaration {
    my ($self, $l) = @_;

    my $isMethod = 0;
    my $throws = '';
    my $parms;
    my $isPublic= 0;
    my $isStatic = 0;
    my $isAbstract = 0;
    my $id;
    my $fullId;
    my $type;

    $l =~ s/^ +//;
    
    if ($l =~ s/^public //) {
	$isPublic = 1;
    }
    if ($l =~ s/^abstract //) {
	$isAbstract= 1;
    }
    if ($l =~ s/^static //) {
	$isStatic = 1;
    }
    if ($l =~ s/       throws (.+);$/;/) {
	$throws = $1;
    }
    
    if ($l =~ s/\((.*)\);$//) {
	$isMethod = 1;
	$parms = $1;
    } else {
    }
    
    if ($l =~ s/^(.+) ([^ ]+)$//) {
	$fullId = $2;
	$type = $1;
    }  else {
	$fullId = $l;
	$l = '';
	# no space, that means we have a method without return value
    }
    
    $id = $self->extract_name_from_full_name($fullId);

    die "illegal record [$l]" if $id eq "";
    
    
#    print "{$l}\n";
    
    return ($id, $fullId, $type, $isMethod, $isPublic, $isStatic, $isAbstract, $parms, $throws);

}

sub extract_name_from_full_name
{
    my ($self, $fullId) = @_;
    my $id;

    if ($fullId =~ /\.([^\.]+)$/) {
	$id = $1;
    } else {
	$id = $fullId;
    }
    return $id;
}



################

my $file = shift;

my $proc = new processorGlobalDecls($file);

$proc->process();
$proc->finish();
