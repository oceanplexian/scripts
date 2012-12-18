#!/bin/perl
use Digest::MD5;

sub dl_torrent {
	$SIG{CHLD} = sub {
		print "\nProcess Complete\n";
		exit 0;
	};

	my $file_name="file_torrent";
	my $torrent_md5_timeout = '15';
	my $hash_new ;
	my $hash_last ;
	my $count = 0;
	my $path = "/opt/release";
	my $torrent_client="/usr/local/bin/aria2c  --allow-overwrite=true --file-allocation=none --index-out=1=$file_name --dir=$path > /tmp/log";
	my $file_absolute_path="$path/$file_name";
	open(FH,">$file_absolute_path") or die "Can't create $file_absolute_path: $!";
	close(FH);
	
#	$torrent_url=$torrent_args[0];


	my $torrent_client_pid = fork();
	die "unable to fork: $!" unless defined($torrent_client_pid);
	if (!$torrent_client_pid) {  # child
	#    exec('for i in `seq 1 10`; do sleep 1; date > file; done; sleep 20');
	     exec("$torrent_client /opt/release/current-release.torrent");
	}
	# parent continues here, pid of child is in $pid
	print "\n".$torrent_client_pid."\n";
	for (my $count = 0; $count < $torrent_md5_timeout; $count++) {
        	if ( $count != 1 ) {
			print "\nu";
		}else{
			print "\nc";
		}
        	open FILE, "$file_absolute_path";
	        my $ctx = Digest::MD5->new;
        	$ctx->addfile (*FILE);
	        my $hash_now = $ctx->hexdigest;
        	close (FILE);

	        if ( $hash_last != $hash_now ) {
        	        $count = 0;
	        }
	        $hash_last = $hash_now;
        	select(undef,undef,undef,.550);
	}
	$exists_pid = kill 0, $torrent_client_pid;
	my $torrent_client_pid_child = $torrent_client_pid + 1;
	if ( $exists_pid == '1') {
	    kill HUP => $torrent_client_pid;
	    kill HUP => $torrent_client_pid_child;
	    waitpid($torrent_client_pid, 0);
	        print "\n Process complete, $torrent_client_pid terminated\n";
	}else{
		print "\n Process has timed out on data write\n";
	}
}
