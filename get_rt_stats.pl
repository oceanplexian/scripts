#!/usr/bin/perl -w
use MIME::Lite;
use Text::Table;
use Data::Dumper;
use DBI;
use CGI ':standard';
use GD::Graph::bars;
use MIME::Base64;
use Date::Format;


$week = time2str("%m/%d/%Y", time), "\n"; 


my $var;
my @username;
my @userdata;

sub transpose {
  map {
    my $j = $_;
    [ map $_[$_][$j], 0..$#_ ]
  } 0..$#{$_[0]};
}


print Dumper $msg;

$dbh = DBI->connect('dbi:mysql:rt3','root','password_goes_here') or die "Connection Error: $DBI::errstr\n";
#$sql = "select U.Name,count(1) from Transactions T, Users U where U.id=T.Creator and T.Created>'2011-1-05' group by T.Creator;";
$sql = 
"SELECT U.Name, 
SUM(IF((Type='Comment' OR Type='Correspond'), 1, 0)) Updated, 
SUM(IF(Type='Create', 1, 0)) Created,
SUM(IF((NewValue='resolved' AND Field='Status' AND Type='Status'), 1, 0)) Resolved, 
SUM(IF((Type='Status' AND Field='Status' AND NewValue='open'), 1, 0)) Opened,
SUM(IF(Type='Status' AND Field='Status' AND OldValue!='new' AND NewValue='open', 1, 0)) ReOpened, 
SUM(IF((Type='Take' OR Type='Steal'), 1, 0)) Taken
FROM Transactions T, Users U 
WHERE U.id=T.Creator 
AND ObjectType='RT::Ticket' 
AND T.Created>DATE_ADD(NOW(),INTERVAL -7 DAY) 
GROUP BY T.Creator;";

$sql_tickets ="
select T.ObjectId,E.Subject, Count(1) from Transactions T, Tickets E where T.ObjectID=E.Id and T.Type = ('Comment' or 'Correspond') and
T.Created>DATE_ADD(NOW(),INTERVAL -7 DAY) group by ObjectId;
";

$sth = $dbh->prepare($sql);
$sth->execute or die "MySQL Connection Error: $DBI::errstr\n";
print "\n";
while (@row = $sth->fetchrow_array) {
	$requestors{$row[0]}->{'Updated'} = "$row[1]";
	$requestors{$row[0]}->{'Created'}   = "$row[2]";
	} 

$sth_tickets = $dbh->prepare($sql_tickets);
$sth_tickets->execute or die "MySQL Connection Error: $DBI::errstr\n";
while (@row = $sth_tickets->fetchrow_array) {
        $requestors_tickets{$row[0]}->{'Subject'} = "$row[1]";
        $requestors_tickets{$row[0]}->{'Count'}   = "$row[2]";
        }



print Dumper \%requestors_tickets;

my $tb = Text::Table->new("Name", "Updates");

foreach my $key(keys %requestors){
	push @{$user_data[0]}, "$key";
	push @{$user_data[2]}, "$requestors{$key}->{'Created'}";
	push @{$user_data[1]}, "$requestors{$key}->{'Updated'}";

}

foreach my $key(keys %requestors_tickets){
       	push @{$user_data_tickets[1]}, "$key";
       	push @{$user_data_tickets[0]}, "$requestors_tickets{$key}->{'Subject'}";
       	push @{$user_data_tickets[2]}, "$requestors_tickets{$key}->{'Count'}";

}

my @sorted_tickets =
  transpose
  sort { $a->[2] <=> $b->[2] }
  transpose @user_data_tickets;


my @sorted =
  transpose
  sort { $a->[1] <=> $b->[1] }
  transpose @user_data;

$iterations = $#{$sorted_tickets[0]} + 1;

### Printing stuff goes here
$table3 = "<table class=sample><tr><th>Name</th><th>Count</th></tr>";
       	foreach my $i (reverse 0..$iterations) {
       	if ( $sorted_tickets[2][$i] != "0" ) {
                $table3 = $table3."<tr><td>".${@sorted_tickets[0]}[$i]."</td><td>".${@sorted_tickets[2]}[$i]."</td></tr>";
                }
       	${@sorted_tickets[1]}[$i] = undef;
       	}
$table3 = $table3."</table>";

$table1 = "<table class=settings><tr></tr>";
        foreach my $i (reverse 0..$iterations) {
        if ( $sorted[1][$i] != "0" ) {
                $table1 = $table1."<tr><td>".${@sorted[0]}[$i]."</td><td>".${@sorted[2]}[$i]."</td></tr>";
                }
        }
$table1 = $table1."</table>";
$table2 = "<table class=settings><tr></tr>";
        foreach my $i (reverse 0..$iterations) {
        if ( $sorted[1][$i] != "0" ) {
                $table2 = $table2."<tr><td>".${@sorted[0]}[$i]."</td><td>".${@sorted[1]}[$i]."</td></tr>";
                }
        }

$table2 = $table2."</table>";
#print $table2;

#print Dumper @user_data;
my @data = (["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",
             "Sep", "Oct", "Nov", "Dec"],
            [23, 5, 2, 20, 11, 33, 7, 31, 77, 18, 65, 52]);

$tb->add(@data);


my $mygraph = GD::Graph::bars->new(420, 480);
$mygraph->set(
    x_label     => 'Username',
    y_label     => 'Ticket Updated',
    title       => 'Ticket Updates per User in the last 7 Days',
    x_labels_vertical =>1,

) or warn $mygraph->error;

my $myimage = $mygraph->plot(\@user_data) or die $mygraph->error;

open(PICTURE, ">/opt/webroot/myimages/picture.png") or die("Cannot open file for writing");

# Make sure we are writing to a binary stream
binmode PICTURE;

# Convert the image to PNG and print it to the file PICTURE
print PICTURE $myimage->png;
#$graph = encode_base64($myimage->png);

#$image = "<img alt=\"Embedded Image\" src=\"data:image/png;base64,".$graph."\" />";

close PICTURE;


#print $tb."\n";

# SendTo email id
my $email = 'user@site.com';
# create a new MIME Lite based email
my $msg = MIME::Lite->new
(
Subject => "HTML email test",
From    => 'sfo1-ops01@sfo1-ops01.corp.livejournal.org',
To      => $email,
Type    => 'text/html',
Data    => "<h2>7 Day RT Ticket Report (Week ending $week)</h2>
<br>$table3<br><br>
<table><tr><td><h4>Tickets Created</h4>$table1</td><td><h4>Tickets Updated</h4> $table2</td></tr></table>"


);

$msg->attach(
    Type     => 'image/png',
    Data     => $myimage->png,
    Filename => 'RT_User_Stats.png',

);


$msg->send();
#print Dumper $msg;
