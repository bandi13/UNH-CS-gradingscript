#!/usr/bin/perl -w
# Grading script written by: Fekete Andras
# Script is under GPLv3. Please share any improvements.
# There is no warranty or support with this software.

use strict;
use Term::ReadKey;

my $class = "cs410c";
if($#ARGV < 0) {
	print "Usage: $0 [OPTIONS] <assignment>\n";
	print "  -w => Ignore whitespace\n";
	print "  -i => Ignore case\n";
	print "  -s <StudentID> => Start from <StudentID>\n";
	exit;
}

my ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();

my $diffcmd = "diff -a -y -W ".int($wchar); # treat as text; side-by-side; width=<consoleWidth>
my $rawDiff = "diff -a"; # treat as text
my $skip;
my $wordCount = 0;
for(my $i = 0; $i < $#ARGV; $i++) {
	if($ARGV[$i] eq "-w") {
		$diffcmd .= " -w";
		$rawDiff .= " -w";
		print "Ignoring whitespace...\n";
	} elsif($ARGV[$i] eq "-i") {
		$diffcmd .= " -i";
		$rawDiff .= " -i";
		print "Ignoring case...\n";
	} elsif($ARGV[$i] eq "-s") {
		$i++;
		$skip = $ARGV[$i];
		print "Starting with student $skip\n";
	} elsif($ARGV[$i] eq "-wc") {
		$wordCount = 1;
		print "Counting differences...\n";
	} else {
		print "Unrecognized OPTION.\n";
		exit;
	}
}

my $assign = $ARGV[-1];
my $sol = "/home/csadmin/$class/assignments/$assign/example/$class-$assign"."*-dir/";
my $total = 0;
foreach $_ (</home/csadmin/$class/assignments/$assign/run/*>) { $total++; }
print "Total students: $total\n";
sleep(1);

my $count = 0;
my $lines;
my $diffCount;
foreach $_ (</home/csadmin/$class/assignments/$assign/run/*>) {
	$count++;
	if(defined($skip)) { if($_ =~ m/$skip/) { undef($skip); } else { next; } }
	$diffCount = 0;
	$lines = "";
	system("clear");
	$lines .= "$_\n";
	if($wordCount == 0) {
		foreach my $out (<$_/*.c>) {
			my $header = $out;
			$header =~ s/\.c$/.h/;
			if(-e $header) {
				$lines .= "============== $header ===================\n";
				$lines .= `cat -n $header`;
			}
			$lines .= "============== $out ===================\n";
			$lines .= `cat -n $out`;
		}
	}
	foreach my $out (<$sol/out*>) {
		my @tmp = split(/\//,$out);
		if($tmp[-1] ne "output") {
			my $curCount = `$rawDiff $out $_/$tmp[-1] | wc -l`;
			chomp($curCount);
			if($wordCount == 0) {
				$lines .= "============== $out ===================\n";
				$lines .= `$diffcmd $out $_/$tmp[-1]`;
				$lines .= "diff Lines: $curCount\n";
			}
			$diffCount += $curCount;
		}
	}
	foreach my $out (<$sol/*.txt>) {
		my @tmp = split(/\//,$out);
		my $curCount = `$rawDiff $out $_/$tmp[-1] | wc -l`;
		chomp($curCount);
		if($wordCount == 0) {
			$lines .= "============== $out ===================\n";
			$lines .= `$diffcmd $out $_/$tmp[-1]`;
			$lines .= "diff Lines: $curCount\n";
		}
		$diffCount += $curCount;
	}
	&printLines($lines,$hchar - 1);
	print "Total diff Lines: $diffCount\n";
	print "Student $count / $total\n";
	print "<<<=========== $_ ================<<<\n";
	$_ = <STDIN>;
	chomp($_);
	if($_ eq "q") { exit; }
}

sub printLines {
	my $line = shift;
	my $rows = shift;
	my @lines = split(/\n/,$line);
	my $i = 0;
	while($i < $#lines) {
		for(my $j = 0; ($j < $rows) && ($i < $#lines); $j++, $i++) { print "$lines[$i]\n"; }
		my $char = myGetChar();
		if($char eq "q") { return; }
		while(($char eq "\n") && ($i < $#lines)) { print "$lines[$i]\n"; $i++; $char = myGetChar(); }
	}
}

sub myGetChar {
	ReadMode('cbreak');
	my $key = ReadKey(0);
	ReadMode('normal');
	return $key;
}
