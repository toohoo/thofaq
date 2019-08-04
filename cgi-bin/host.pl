#!c:/xampp/perl/bin/perl
#!/usr/bin/perl
#http://www.iiv.de/wolfgang/buerger/tommyhof/test/host.pl

print "Content-type: text/html","\n\n";

print <<kopfende;
<html>
	<head>
	<title>Environment des IIVS</title>
	</head>
<body>
<h1>Environment des IIVS</h1>

kopfende

$remote_host = $ENV{ 'REMOTE_HOST' };
print "<p>Sie kommen von <b>", $remote_host, "</b>. \n";

print "<br>Parameter 0:<b>",$0,"</b></p>\n\n";

print "<table style=\"font-size:10pt\">\n";
@k=keys(%ENV);
$f1 = "#99cccc";
$f2 = "#cccccc";
$f = $f1;
foreach(sort(@k)) {
        print "<tr><td bgcolor=\"$f\">", $_,"</td><td bgcolor=\"$f\">",$ENV{$_},"</td></tr>\n";
        if ($f eq $f1) {$f = $f2} else {$f = $f1}
}
print "</table>\n";

print "\n<p>Version: $]</p>\n";

print "<p>Viel Spaﬂ beim Surfen!</p>\n";
print "</html>\n";
exit(0);
