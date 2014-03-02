#!/usr/bin/perl
use strict;
use warnings;

# NEED GNU
BEGIN {
	$ENV{PERL_RL} = "Gnu";
}	
use Term::ReadLine;
use Slurp;
my $term = Term::ReadLine->new('Quizzer');
my $attribs = $term->Attribs;
my $prompt = "-> ";

$attribs->{completion_entry_function} = $attribs->{list_completion_function};
my @list = qw(reference to a list of words which you want to use for completion);

if ($ARGV[0]) {
	@list = map { chomp $_; $_ } Slurp::to_array( $ARGV[0] );
}

my %state = map { $_ => 1 } @list;

my %seen = ();
sub state {
	my ($in) = @_;
	if ($in) {
		delete $state{$in};
		$seen{$in}++;
	}
	$attribs->{completion_word} = [
		keys %state
	];
}


state();
while ( defined ($_ = $term->readline($prompt)) ) {
	s/^\s*//;
	s/\s*$//;
	foreach my $v (split(/\s+/,$_)) {
		state($v);
		print $v, "\n";
		$term->addhistory($v);
	}
}
my @names = sort((keys %seen) , (keys %state));
open(my $file,">","out.csv");
print $file "CCID\tQUIZ$/";
for my $key (@names) {
	my $str = "$key\t".((exists $seen{$key})?$seen{$key}:0).$/;
	print $str;
	print $file $str;
}
close($file);
print STDERR "$/Done$/";
