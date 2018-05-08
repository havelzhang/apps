
package MsgSender;

use strict;
use Mail::Sender;
use MIME::Base64;

sub test{
	my $to      = ['havel.zhang@apeksys.com','havel72cn@163.com'];
	my $subject = 'Test subject';
	my $body    = "This is body";
	my $attachements = ['msgsender.pl', 'test.pl'];
	send_Msg($to, $subject, $body, $attachements);
}

sub send_Msg{
	my ($send_to, $subject, $body, $attachments) = @_; 
	my $mail_encode = "GB2312";
	$subject = encode_base64($subject);
	$subject = "=?${mail_encode}?B?${subject}?=";
	print STDERR "To: ", join(',', @$send_to),"\n";
	print STDERR "Subject:$subject\n";
	print STDERR "Body:$body\n";
	my $mail_server		= 'smtprelay.cdc.carrefour.com';
	my $mail_user		= 'NSA_Alert';
	my $mail_pass		= '';
	my $from_email		= 'NSA_Alert@carrefour.com';
	my $to_email		= join(',', @$send_to);	
	my %mail = ('user' => "$mail_user", 'pass' => "$mail_pass", 'server' => "$mail_server", 'from_email' => "$from_email",  'to_email'=> "$to_email");
	my $ctype = 'text/plain';
	
	if ( $body =~ /\<HTML\>/i ){
		$ctype = 'text/html';
	}
	
	my $sender = new Mail::Sender();
	if ( ! scalar @$attachments ){
		if ($sender->MailMsg({
			smtp		=> $mail{'server'},
			from		=> $mail{'from_email'},
			to			=> $mail{'to_email'},
			subject		=> $subject,
			msg			=> $body,
			description => 'html body',
			ctype		=> $ctype,
			authid		=> $mail{'user'},
			authpwd		=> $mail{'pass'},
			file		=> $attachments,
		}) < 0) {
			print "$Mail::Sender::Error\n";
			return 0 ;
		}else{	
			print STDERR "email sent\n";
		}
	}else{
		if ($sender->MailFile({
			smtp		=> $mail{'server'},
			from		=> $mail{'from_email'},
			to			=> $mail{'to_email'},
			subject		=> $subject,
			msg			=> $body,
			description => 'html body',
			ctype		=> 'text/html',
			authid		=> $mail{'user'},
			authpwd		=> $mail{'pass'},
			file		=> $attachments,
		}) < 0) {
			print "$Mail::Sender::Error\n";
			return 0 ;
		}else{	
			print STDERR "email sent\n";
		}	
	}
	return 1;
}

1;

__END__

