require 'pretty_print.pl';

package cUtil;

use File::Basename;
use strict;
sub new{
	my $class = shift;
	$class = ref($class) if ref($class);
	my ($feed_name, $logger) = @_;
	bless my $self = {
		'feedname' =>$feed_name,
		'logger'   =>$logger,
		'conf'     =>undef,
	},$class;
	return $self;
}

sub set_feed_name{
	my $self = shift;
	my $fn = shift;
	$self->{'feedname'} = $fn;
}

sub get_file_name{
	my $self = shift;
	my $dir = shift;
	my @l = fileparse($dir);
	return $l[0];
}

sub success_exit{
	my $self = shift;
	my $msg = shift;
	$self->log($msg);
	$self->log($self->{'feedname'} . " sucessfully completed!!");
	$self->{'logger'}->finish_log() if defined $self->{'logger'};
	$self->move_dir($self->{'conf'}->{'processing_dir'}, $self->{'conf'}->{'success_dir'}) if defined $self->{'conf'};	
	exit(0);
}

sub exit_usage{
	my $self = shift;
	my $msg = shift;

	print STDERR "$msg\n";
	if (defined $self->{'conf'}){
		print STDERR "$self->{'conf'}->{'prog_name'} $self->{'conf'}->{'command_opt'}\n";
	}
	exit(-1);
}

sub error_exit{
	my $self = shift;
	my $msg = shift;
	if (defined $self->{'conf'}){
		$self->{'conf'}->{'dbh'}->disconnect() if defined $self->{'conf'}->{'dbh'};
	}
	$self->log($self->{'feedname'} . " has errors!!");
	$self->log($msg);
	$self->log(pretty_print::pretty_print($self->{'conf'}));
	$self->{'logger'}->finish_log() if defined $self->{'logger'};
	$self->move_dir($self->{'conf'}->{'processing_dir'}, $self->{'conf'}->{'error_dir'}) if defined $self->{'conf'};	
	exit(-1);
}

sub log{
	my $self = shift;
	my $msg = shift;
	if (defined $self->{'logger'}){
		$self->{'logger'}->log_msg($msg);
	}else{
		print STDERR "$msg\n";
	}
}

sub set_conf{
	my $self = shift;
	my $conf= shift;
	$self->{'conf'} = $conf if defined $conf;
}

sub set_logger{
	my $self = shift;
	my $logger = shift;
	$self->{'logger'} = $logger if defined $logger;
}

sub uncompress{
	my $self = shift;
	my $fn = shift;
	if (! -f $fn){
		$self->log("File <$fn> is not a file!!");
		return $fn;
	}
	if ( -z $fn){
		$self->log("File <$fn> size is zero!!");
		return $fn;
	}
	my $cmd = '';
	my $exploded = $fn;
	if ($fn =~ m/^(.+)\.Z$/i){
		$exploded = $1;
		$cmd  = "compress -df $fn";
	}elsif ($fn =~ m/^(.+)\.gz$/i){
		$exploded = $1;
		$cmd = "gunzip --force $fn";
	}elsif ($fn =~ m/^(.+)\.zip$/i){
		$exploded = $1;
		$cmd = "unzip $fn";
	}else{
		;
	}
	`$cmd` if $cmd ne '';
	return $exploded;
}

sub compress{
	my $self = shift;
	my $fn = shift;
	if (! -e $fn){
		$self->log("File <$fn> does not exist!!");
		return $fn;
	}
	if (! -f $fn){
		$self->log("File <$fn> is not a file!!");
		return $fn;
	}
	if ($fn =~ /\.zip$/i || $fn =~ /\.gz$/i || $fn =~ /\.rar$/i){
		$self->log("File <$fn> is already compressed");
		return $fn;
	}
	my $cmd = "gzip --force $fn";
	`$cmd` if $cmd ne '';
	return "$fn.gz";
}

sub move_file_to_dir{
	my $self = shift;
	my $fn = shift;
	my $d = shift;
	my $fn1 = $self->get_file_name($fn);
	if (-e "$d\\$fn1"){
		my $new_fn = $fn1. '.' . $self->get_yyyymmdd_hhmmss();
		`mv --force $d\\$fn1 $d\\$new_fn`;
	}
	`mv --force $fn $d`;
}


sub copy_file_to_dir{
	my $self = shift;
	my $fn = shift;
	my $d = shift;
	my $fn1 = $self->get_file_name($fn);
	if (-e "$d\\$fn1"){
		my $new_fn = $fn1. '.' . $self->get_yyyymmdd_hhmmss();
		`cp --force $d\\$fn1 $d\\$new_fn`;
	}
	`cp --force $fn $d`;
}


sub move_dir{
	my $self = shift;
	my $dest = shift;
	my $targ = shift;
        print STDERR "move /Y $dest $targ \n";
	`move /Y $dest $targ`;
}

sub set_up_dir{
	my $self = shift;
	my $d = shift;
	return if -e $d;
	my @l = split(/\\/, $d);
	my ($a, $i,$j);
	if ($l[0] =~ /:$/){
		$a = "$l[0]\\$l[1]";
		$i = 2;
	}else{
		if ($a eq ''){
			$a = "\\$l[1]";
			$i = 2;
		}else{
			$a = "$l[0]";
			$i = 1;
		}
	}
	`mkdir $a` if ! -e $a;
	for ($j = $i; $j <= $#l; $j++){
		$a = "$a\\$l[$j]";
		`mkdir $a` if !-e $a;
	}
}

sub readable_time{
	my $self = shift;
	my $ts = shift;
	my $t = defined $ts  ? $ts : time;
	my @l = localtime($t);
	my $t = sprintf("%04d-%02d-%02d %02d:%02d:%02d ", 
			$l[5]+1900, $l[4]+1, $l[3], $l[2], $l[1], $l[0]);
	return $t;
}

sub n_days_yyyymmdd{
	my $self = shift;
	my $days = shift;
	my @l = localtime(time + $days*24*3600);
	my $ymd = sprintf("%04d%02d%02d", $l[5]+1900, $l[4]+1, $l[3]);
	return $ymd
}

sub n_days_yyyymmdd_with_slash{
	my $self = shift;
	my $days = shift;
	my @l = localtime(time + $days*24*3600);
	my $ymd = sprintf("%04d/%02d/%02d", $l[5]+1900, $l[4]+1, $l[3]);
	return $ymd
}

sub get_yyyymmdd_hhmmss{
	my $self = shift;
	my @lts = localtime(time);
	my ( $yyyy, $mon, $dd, $hh, $mm, $ss) = 
	    ( $lts[5]+1900, $lts[4]+1, $lts[3], $lts[2], $lts[1], $lts[0]);
	return sprintf "%04d%02d%02d_%02d%02d%02d", $yyyy,$mon,$dd,$hh,$mm,$ss;
}

sub get_yymmddhhmmss{
	my $self = shift;
	my @lts = localtime(time);
	my $a = $lts[5]+1900;
	my $b = substr($a, 2,2);
	my ( $yyyy, $mon, $dd, $hh, $mm, $ss) = 
	    ($b, $lts[4]+1, $lts[3], $lts[2], $lts[1], $lts[0]);
	return sprintf "%02d%02d%02d%02d%02d%02d", $yyyy,$mon,$dd,$hh,$mm,$ss;
}

sub get_yyyymmddhhmmss{
	my $self = shift;
	my @lts = localtime(time);
	my $a = $lts[5]+1900;
	my $b = substr($a, 2,2);
	my ( $yyyy, $mon, $dd, $hh, $mm, $ss) = 
	    ($a, $lts[4]+1, $lts[3], $lts[2], $lts[1], $lts[0]);
	return sprintf "%04d%02d%02d%02d%02d%02d", $yyyy,$mon,$dd,$hh,$mm,$ss;
}



sub get_hh_mi{
	my $self = shift;
	my @lts = localtime(time);
	my $a = $lts[5]+1900;
	my $b = substr($a, 2,2);
	my ( $yyyy, $mon, $dd, $hh, $mm, $ss) = 
	    ($a, $lts[4]+1, $lts[3], $lts[2], $lts[1], $lts[0]);
	my %rt_hh_mi;
	$rt_hh_mi{'hh'}=$hh;
	$rt_hh_mi{'mi'}=$mm;
	return \%rt_hh_mi;
}


sub last_month_yyyymm{
	my $self = shift;
	my $ym = shift;
	my $y = int substr($ym,0,4);
	my $m = int substr($ym,4,2);
	my ($ly, $lm);
	if ($m == 1){
		$ly = $y-1;
		$lm = 12;
	}else{
		$ly = $y;
		$lm = $m-1;
	}
	return sprintf("%04d%02d", $ly, $lm);
}

1;


