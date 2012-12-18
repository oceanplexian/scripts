#! /usr/bin/perl


#----------------------------------------------------------------------#
# Source code by Alvin Alexander, devdaily.com
#----------------------------------------------------------------------#
sub promptUser {
   local($promptString,$defaultValue) = @_;
   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }
   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN (presumably the keyboard)
   chomp;
   if ("$defaultValue") {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}


#################################################################
##                       Timestamp Script                      ##
#################################################################

($sec,$min,$hour,$mday,$mon,$year,$wday,
$yday,$isdst)=localtime(time);

#################################################################
##  Source Code by Andreas Echavez - Turnstone Telnet Script   ##
#################################################################

use Net::Telnet;
if (defined $ARGV[0] and defined $ARGV[1]) {
}else{
print "\nWelcome to the Turnstone Test Pair Script.\n";
print "Usage: test_pair.pl turnstone cablepair openshort\n\n";

exit 0;
}



$oldpassword = "password_goes_here"; # Login Password

$turnstone = $ARGV[0];
$cable_pair_human = $ARGV[1];

use Number::Range;
$i = "$cable_pair_human";
for ($count = 0; $count <= 23; $count++) {
        $CLXCOUNT = sprintf("%.2d", $count + 5);
        $upperrange = (($count + "1") * "25");
        $lowerrange = $upperrange - "24";
my $valuator = Number::Range->new("$lowerrange..$upperrange");
     if ($valuator->inrange("$i")) {
         $CXID = $i - ($count * 25);
         $cable_pair = "CXL$CLXCOUNT\[$CXID\]";
     }

}


$cable_command = "tp -f $cable_pair";
$cable_command2 = "tp -f $cable_pair openshort";

print "Logging into $turnstone ";
if ( $ARGV[2] eq "openshort" ){
print "\n   -Open/Short Test Requested";
}

print "\n";
$telnet = Net::Telnet->new(Timeout => 200, errmode =>sub {&login_fail}); 
Prompt => ('/\$ $/i');
$telnet->open ($turnstone);

print "   -Logging In\n";
$telnet->waitfor('/login: $/i');
$telnet->print('root');
$telnet->waitfor('/password: $/i');
$telnet->print($oldpassword);

print "   -Getting Prompt\n";
$telnet->waitfor('/> /');
print "   -Got Prompt!\n";


if ( $ARGV[2] eq "openshort"){
print "   -Running $cable_command2\n";
$telnet->print($cable_command2);
$telnet->waitfor('/Should/');
print "   -Confirmed Turnstone Test\n";
$telnet->print('Yes');
$telnet->print('');
$telnet->waitfor('/Press/');

{
    local( $| ) = ( 1 );
    print "";
    print "Press <Enter> when open: ";
    my $resp = <STDIN>;
}

$telnet->print('');
$telnet->waitfor('/Press/');

{
    local( $| ) = ( 1 );
    print "Press <Enter> when shorted: ";
    my $resp = <STDIN>;
}

$telnet->print('');
}

else{
print "   -Running $cable_command\n";
$telnet->print($cable_command);
$telnet->waitfor('/Should/');
print "   -Confirmed Turnstone Test\n";
$telnet->print('Yes');
}

($stats) = $telnet->waitfor('/cageTS/');

print "   -Getting Stats\n";
print $stats;
$telnet->close;
print "\n";

print "Complete\n\n";
exit 0;







