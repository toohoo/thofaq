#!d:/xampp/perl/bin/perl -w
#!/usr/bin/perl
#######################################################
## whoamip.pl
## feststellen der IP des Abrufenden im Intranet
## Thomas Hofmann, Sep 2005
## IP-Adresse ueber Environment(REMOTE_ADDR)
#######################################################

require 'cgi-lib.pl';
print PrintHeader();
print HtmlTop('test whoamip');

my $actdir = `cd`;
push ( @INC, $actdir );
chomp $actdir;
print "\n<pre>-----\n";
my $idx = 1;
#foreach my $inc( @INC ) { print "$idx = $inc\n"; $idx++; }
#print "\n------\n";
#print "calling: $actdir . '\\whoamip.pl' \n";
#print "\n------\n";
my $ip = do( $actdir . "\\whoamip.pl" );
print $ip;
#print "\n------\n";
print "\n-----</pre>\n";
print HtmlBot();
1;
