#!/usr/bin/perl -w
# Grading script written by: Fekete Andras
# Script is under GPLv3. Please share any improvements.
# There is no warranty or support with this software.

use strict;

my $class = "cs410c";
if($#ARGV < 0) {
	print "Usage: $0 [OPTIONS] <assignment>\n";
	print "  -w => Ignore whitespace\n";
	print "  -i => Ignore case\n";
	print "  -s <StudentID> => Start from <StudentID>\n";
	exit;
}

my $diffcmd = "diff -a -y -W 170"; # treat as text; side-by-side; width=200
my $skip;
for(my $i = 0; $i < $#ARGV; $i++) {
	if($ARGV[$i] eq "-w") {
		$diffcmd .= " -w";
		print "Ignoring whitespace...\n";
	} elsif($ARGV[$i] eq "-i") {
		$diffcmd .= " -i";
		print "Ignoring case...\n";
	} elsif($ARGV[$i] eq "-s") {
		$i++;
		$skip = $ARGV[$i];
		print "Starting with student $skip\n";
	} else {
		print "Unrecognized OPTION.\n";
		exit;
	}
}

my $assign = $ARGV[-1];
my $sol = "/home/csadmin/$class/assignments/$assign/example/$class-$assign"."*-dir/";
sleep(1);

foreach $_ (</home/csadmin/$class/assignments/$assign/run/*>) {
	if(defined($skip)) {
		if($_ =~ m/$skip/) { undef($skip); } else { next; }
	}
	system("clear");
	print "$_\n";
	print "============== solution.c ===================\n";
#	system("diff $sol/solution.c $_/*.c");
	system("cat -n $_/*.c | more");
	foreach my $out (<$_/out*>) {
		my @tmp = split(/\//,$out);
		if($tmp[-1] ne "output") {
			print "============== $out ===================\n";
			system("$diffcmd $sol/$tmp[-1] $out | more");
		}
	}
	print "<<<=========== $_ ================<<<\n";
	$_ = <STDIN>;
	chomp($_);
	if($_ eq "q") { exit; }
}
