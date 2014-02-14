#!/usr/bin/perl -w
# Grading script written by: Fekete Andras
# Script is under GPLv3. Please share any improvements.
# There is no warranty or support with this software.

use strict;

my $class = "cs410c";
if($#ARGV < 0) {
	print "Usage: $0 [OPTIONS] <assignment>\n";
	exit;
}

my $assign = $ARGV[-1];
my $sol = "/home/csadmin/$class/assignments/$assign/done";
my $diffcmd  = "diff -a -d -w";
my $maxStudents = 1000;

my @students = ();
my @trash;
foreach $_ (<$sol/*>) {
	@trash = split(/\//,$_);
	if($#students != -1) {
		my $curStud = $students[$#students];
		$curStud =~ s/-.*//g;
		my $curStud2 = $trash[-1];
		$curStud2 =~ s/-.*//g;
		if($curStud eq $curStud2) { $students[$#students] = $trash[-1]; } # second submission
		else { $students[$#students + 1] = $trash[-1]; } # new student
	} else {$students[$#students + 1] = $trash[-1]; } # new student
}

my @diffs = ();
print "\t";
for(my $i = 0; $i < $#students + 1; $i++) {
	my $curStud = $students[$i];
	$curStud =~ s/-.*//g;
	print "$curStud\t";
}
print "\n";

my @studentMin = ();
my %stuMin;
for(my $i = 0; $i < $#students + 1; $i++) {
	my $curStud = $students[$i];
	$curStud =~ s/-.*//g;
	print "$curStud\t";
	$diffs[$i] = ();
	for(my $j = 0; $j < $i; $j++) {
		print "-\t";
	}
	$diffs[$i][$i] = `$diffcmd $sol/$students[$i]/*.c $sol/$students[$i]/*.c | wc -l`;
	chomp($diffs[$i][$i]);
	my $min = $i+1;
	for(my $j = $i+1; $j < $#students + 1; $j++) {
		$diffs[$i][$j] = `$diffcmd $sol/$students[$i]/*.c $sol/$students[$j]/*.c | wc -l`;
		chomp($diffs[$i][$j]);
		if($diffs[$i][$j] < $diffs[$i][$min]) { $min = $j; }
	}
	if($min > $#students) { $min = $#students; } # Prevent for last student to have a bad value
	$studentMin[$i] = $min;
	for(my $j = $i; $j < $#students + 1; $j++) {
		if($j == $min) { print "*"; }
		print "$diffs[$i][$j]\t";
	}
	print "\n";
	my $key = $diffs[$i][$min] * $maxStudents;
	while(defined($stuMin{$key})) { $key++; }
	$stuMin{$key} = "$students[$i] <--> $students[$min]";
}

foreach $_ (sort keys %stuMin) {
	print $_/$maxStudents . ":$stuMin{$_}\n";
}
#for(my $i = 0; $i < $#students + 1; $i++) {
#	print "$students[$i] <-- $diffs[$i][$studentMin[$i]] --> $students[$studentMin[$i]]\n";
#}
