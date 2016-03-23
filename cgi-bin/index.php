<?php
	if (!empty($_SERVER['HTTPS']) && ('on' == $_SERVER['HTTPS'])) {
		$uri = 'https://';
	} else {
		$uri = 'http://';
	}
	$uri .= $_SERVER['HTTP_HOST'];
	header('Location: '.$uri.'/faq/cgi-bin/faq.pl');
	exit;
?>
Something is wrong with the XAMPP installation :-(
<br>Take <a href="http://localhost/faq/cgi-bin/faq.pl">this Road</a> instead ...