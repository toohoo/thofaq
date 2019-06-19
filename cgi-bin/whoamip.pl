#!C:/xampp/perl/bin/perl -w
#!/usr/bin/perl
#######################################################
## whoamip.pl
## feststellen der IP des Abrufenden im Intranet
## Thomas Hofmann, Sep 2005
## IP-Adresse ueber Environment(REMOTE_ADDR)
#######################################################

if ($remote_addr = $ENV{ 'REMOTE_ADDR' }) {
	return($remote_addr);
} else {
	die "Fehler: IP nicht gefunden.";
}

1;
