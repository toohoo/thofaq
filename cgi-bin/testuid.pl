#!D:/xampp/perl/bin/perl
#!/usr/bin/perl
$| = 1;

print "Content-type: text/plain\n\n";

print $^X, "\n";
print $<, "\n";
print $>, "\n";

$orgein = $/;

local $slash = "\/";
local $dir = "/home/iiv00096/public_html/_faq/cgi-bin/";
local $dat = $dir . "test.txt";
print "Datei: [$dat]\n";
if (!open (DAT, $dat)) {
	print "Kann Datei [$dat] nicht lesen.\n";
	exit(0);
} 
undef ($/);
local $inhalt = <DAT>;
$/ = $orgein;
close DAT;

print $inhalt;
