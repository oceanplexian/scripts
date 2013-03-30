use HTTP::Daemon;
use HTTP::Status;
use JSON;

my $d = new HTTP::Daemon
	ReuseAddr => 1,
	LocalPort => 8080;

my $start_time = time();
print "Daemon Started at: <URL:", $d->url,"> t:$start_time\n";
while (my $c = $d->accept) {
	while (my $r = $c->get_request) {
		if ($r->method eq 'GET' and $r->url->path =~ /\/server\/*/) {
			my $time = time();
			print "$time --> REQ/OK\n";
			$c->send_response('Content-Type: text/html');
			($f1 = $r->url->path) =~ s/^.*\///;
    			print $c server_info($f1)."\n";
		}

                elsif ($r->method eq 'PUT' and $r->url->path =~ /\/command\/start\/*/) {
                        my $time = time();
                        print "$time --> REQ/OK\n";
                        $c->send_response('Content-Type: text/html');
                        ($f1 = $r->url->path) =~ s/^.*\///;
                        print $c start_vm($f1)."\n";
                }

		else {
                       	my $time = time();
                       	print "$time --> REQ/ERROR\n";
			$c->send_error(RC_FORBIDDEN)
		}
	}
	$c->close;
	undef($c);
 }

sub json_error {
        $code=$_[0];
        my %error_codes = (
                010     =>	'VM Already Running',
                011     =>	'VM Not Found',
                012     =>	'Undefined Creation Error'
        );
	my %error = (
                result    => {
                        desc    =>	$error_codes{$code},
                        id	=>	$code,
                        status  =>	"error",
                }
        );
	$json = encode_json \%error;
        return $json;
}

sub server_info {
	$server_name=$_[0];
	@var = `xm list`;
	@grep = grep(/$server_name/, @var);
	#my @grep=grep( { "$_&amp;" eq "bil1-mx" } @var);
	my @xmlist = split(/\s+/, $grep[0]);
	my %attrs = (
       		name    => @xmlist[0],
	       	id      => @xmlist[1],
	       	mem     => @xmlist[2],
	       	vcpus   => @xmlist[3],
       		state   => @xmlist[4],
	       	time    => @xmlist[5]
	);
	my $json = encode_json \%attrs;
	#return $json.@xmlist[0];
	if (defined(@xmlist[0])) {
	       	return $json;
	} else {
	       	return "{\"error\": {\"id\":\"001\", \"desc\": \"VM Not Found\"}}";
	}
}

sub start_vm {

        $server_name=$_[0];
        $config="/etc/xen/auto/$server_name";
        $command_name="xm create $config";

        $error_response="already in use";
        $success_response="Started domain";
        @var = `$command_name 2>&1`;
        @failure = grep(/$error_response/, @var);
        @success = grep(/$success_response/, @var);
        my %attrs = (
                command    => "start_vm",
                status     =>  "ok"
        );
	my $json = encode_json \%attrs;
       	if (defined(@success[0])) {
               	return $json;
        } elsif (defined(@failure[0])) {
                return json_error(010);
        } else {

               	return json_error(012);
       	}
}
