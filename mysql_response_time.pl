#!/usr/bin/perl -w

#
#	To use this, enable response time distribution in Percona
#
 
use DBI;
use strict; 
use Time::HiRes;
use Getopt::Std;

use Data::Dumper;

die "Usage: $0 -h hostname -u username -p password\n" if @ARGV < 2;

my %options=();
getopts("h:u:p:", \%options);

my $user	=	"root";
my $pass	=	"xxxx";
my $host	=	"127.0.0.1";

$host = $options{h};
$user = $options{u};
$pass = $options{p};


my $query 	=	 "SELECT * from QUERY_RESPONSE_TIME";
my $db		=	"information_schema";


my @results;
my @times;
print "\033[2J"; print "\033[0;0H";

my $dbh = DBI->connect("DBI:mysql:$db:$host", $user, $pass);

sub run_query {
	my $sqlQuery  = $dbh->prepare($query)
		or die "Can't prepare $query: $dbh->errstr\n"; 
	my $rv = $sqlQuery->execute
		or die "can't execute the query: $sqlQuery->errstr";
 

	while (my @row= $sqlQuery->fetchrow_array()) {
		my $tables = $row[0];
		my $col2 = $row[1];
		push(@results,  "$col2");
		push(@times,"$tables");
#		print "$tables\t$col2 \n";
	}
}


sub do_loop {

       	@results  	= ();
        @times          = ();

	&run_query;
	my @results_first = @results;

	@results	= ();
	@times		= ();

	Time::HiRes::sleep(0.5);
	&run_query;
	print "Connected to $db\n\n";
	print "     Seconds\tQPS\tTotal\n";
	print "-----------------------------------\n";
	my @results_second = @results;
	my @out = map { ($results_second[$_] - $results_first[$_] ) * 2 } 0 .. $#results_first;
	my $count = 0;

	foreach my $time (@out) {
		print "$times[$count]\t";
		print "$time\t";
		print "$results[$count]\n";
		$count++;
	}

	my $qps_sum;
	$qps_sum += $_ for @out;
	print "-----------------------------------\n";
	print "  Total QPS: $qps_sum\n\n";
}

while () {
	&do_loop;
	print "\033[2J"; print "\033[0;0H";

}

exit(0);
