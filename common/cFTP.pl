package cFTP;

use Net::FTP;
require 'E:/Apps/config/site_config.pl';


sub remote_email{
	my ($server,$user,$password,$dir,$file) = @_;
	my $ftp = Net::FTP->new($server,Debug=>0);
	$ftp->login($user,$password);
	$ftp->cwd($dir);
	$ftp->put($file);
	$ftp->quit;
}

sub do_email{
	my ($subject, $msg,$addr,$fn) = @_;
	open(F, ">$fn");
	print F 'TO|' . $addr . "\n";
	print F 'SUBJECT|' . "$subject\n";
	print F "===============================================\n";
	print F "$msg\n";
	close(F);
	remote_email($site_config::remoteEmailServer,
					    	$site_config::remoteUser,
							$site_config::remotePassword,
							$site_config::remoteEmailDir,
							$fn);
}


my $ftp;

sub new{
	my $class = shift;
	$class = ref($class) if ref($class);
	my ($srvr,$user, $pass) = @_;
	bless my $self = {
		'server' =>$srvr,
		'user'=>$user,
		'pass' => $pass,
		'logger' => undef,
	},$class;
	return $self;
}

sub ascii{
	my $self = shift;
	$ftp->ascii();
}

sub binary{
	my $self = shift;
	$ftp->binary();
}

sub quit{
    my $self = shift;
    $ftp->quit();
}

sub mkdir{
	my $self = shift;
	my $dir = shift;
	my $t = shift;
	my $r = 1;
	$ftp->mkdir("$dir//$t", $r);
}

sub put{
	my $self = shift;
	my $src = shift;
	my $target = shift;
	my $fn = shift;
	$ftp->cwd($target);
	$ftp->put($src,$fn);
}

sub quit{
	my $self = shift;
	$ftp->quit;
}

sub set_logger{
	my $self = shift;
	my $l = shift;
	$self->{'logger'} = $l;
}

sub connect{
	my $self = shift;
    my $rt;
	if (defined $ftp){
		eval{
			my $l = $ftp->ls('/');
			return 1;
		};
		if ($@){
			$self->{'logger'}->info('not connected, reconn') if defined $self->{'logger'};
		}
	}
	eval{
   		$ftp = Net::FTP->new($self->{'server'}, Debug=>0, Timeout=>200 , Passive=>0);
   		$rt = $ftp->login($self->{'user'}, $self->{'pass'});
	};
	if ($@ or  $rt != 1){
		$self->{'logger'}->info('Cannot connect') if defined $self->{'logger'};
		return undef;
	}
	return 1;
}

sub get_file_names{
	my $self    = shift;
	my $dir     = shift;
	my $pattern = shift;
	my $sz ;
	my $fmdtm;
    my @l;
	eval{
   		$ftp->cwd($dir);
		@l = $ftp->ls($pattern);
		foreach (@l){
			$sz = $self->get_size($dir,$_);
			# $fmdtm = $self->get_mdtm($dir,$_);
			# $ftime = $self->readable_time($fmdtm);
			print STDERR "$_\t\t$sz\t\t\n";
			$self->{'logger'}->info("$_\t\t$sz\t\t") if defined $self->{'logger'};
		}
		$ftp->cwd('/');
	};
	if ($@){
		$self->{'logger'}->log_error("FTP Failed <$@>");
		return ();
	}
	return @l;
}

sub readable_time{
	my $ts = shift;
	my $t = defined $ts  ? $ts : time;
	my @l = localtime($t);
	my $t = sprintf("%04d-%02d-%02d %02d:%02d:%02d ", $l[5]+1900, $l[4]+1, $l[3], $l[2], $l[1], $l[0]);
	return $t;
}

sub rename{
	my $self	= shift;
	my $dir 	= shift;
	my $srcfn	= shift;
	my $tgtfn	= shift;
	eval{
		$ftp->cwd('/');
		$ftp->cwd($dir);
		$ftp->rename($srcfn,$tgtfn);
	};
	if ($@){
		$self->{'logger'}->log_error("FTP Failed <$@>");
		return undef;
	}
	return 1;
}

sub get_size{
	my $self	= shift;
	my $dir 	= shift;
	my $fn		= shift;
	my $fsize;
	eval{
		$ftp->cwd('/');
		$ftp->cwd($dir);
		$fsize = $ftp->size("$dir/$fn");
	};
	if($@){
		$self->{'logger'}->info("FTP Failed<$@>");
		return undef;
	}
	return $fsize;
	
}

sub get_mdtm{
	my $self	= shift;
	my $dir 	= shift;
	my $fn		= shift;
	my $fmdtm;
	eval{
		$ftp->cwd('/');
		$ftp->cwd($dir);
		$fmdtm = $ftp->mdtm("$dir/$fn");
	};
	if($@){
		$self->{'logger'}->info("FTP Failed<$@>");
		return undef;
	}
	return $fmdtm;
	
}


sub get_file{
	my $self       = shift;
	my $src_dir    = shift;
	my $target_dir = shift;
	my $file_name  = shift;
        my $fn;
	eval{
		$fn = $ftp->get("$src_dir/$file_name", "$target_dir/$file_name") or
		  die $ftp->message;
	};
	if ($@){
		return undef;
	}
	return $fn;
}
sub remove_file{
	my $self	= shift;
	my $fn		= shift;
	eval{
		$ftp->delete($fn);
		$self->{'logger'}->info("removed file <$fn>");
	};
	if($@){
		$self->{'logger'}->log_error("FTP Failed <$@>");
		return undef;
	}
	return 1;
}
1;

