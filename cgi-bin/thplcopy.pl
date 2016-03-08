#!/xampp/perl/bin/perl

######################################################
# thplcopy.pl - t.h. feb 2001
#
# Kopieren von Standard-Perl-Scripts in genutzte Verzeichnisse
# Voraussetzung: Netzlaufwerk unter F:
######################################################

@verz =	(
	'F:\lektorat\PROG\BJOSEF', 
	# 09.01.2003 , habe heute bemerkt, dass es das Verz. nicht mehr gibt
	#'F:\lektorat\PROG\WES\UEBPERL', 
	'F:\lektorat\REPORT\PERL', 
	'F:\lektorat\REPORT\PRO\FNOFF', 
	'F:\lektorat\REPORT\PRO\ID', 
	'F:\lektorat\REPORT\PRO\LEERTAG', 
	'F:\lektorat\REPORT\PRO\PROABWLI', 
	'F:\lektorat\REPORT\PRO\PROPARS', 
	'F:\lektorat\REPORT\PRO\PROUML', 
	'F:\lektorat\REPORT\PRO\SOFO', 
	'F:\lektorat\REPORT\PRO\SONDZEI', 
	'F:\lektorat\REPORT\PRO\STATISTI', 
	'F:\lektorat\REPORT\PRO\SW', 
	'F:\lektorat\REPORT\PRO\UPDATE', 
	'F:\lektorat\REPORT\PRO\ZH1SW', 
	'F:\lektorat\REPORT\PRO\SGMRUECK', 
	'F:\lektorat\REPORT\PRO\autmeta', 
	'F:\lektorat\REPORT\PRO\autgt', 
	'F:\lektorat\REPORT\PRO\SOFOrein', 
	'F:\lektorat\SGML\TRANSFER', 
	'F:\Lektorat\Report\Pro\Autkopf',
	'F:\Lektorat\Report\Pro\IE5',
	'F:\pm-daten\hofmannt\ranking\tools',
	'F:\lektorat\REPORT\PRO\PROtab3', 
	'd:\ubmdaten\ranking\tools', 
	'F:\lektorat\REPORT\PRO\autumf',
	'F:\lektorat\REPORT\PRO\gestrans',
	'F:\lektorat\REPORT\PRO\textumf',
	'F:\lektorat\REPORT\PRO\SWLIST', 
	'F:\lektorat\REPORT\PRO\nachtlau', 
	'C:\Ubmdaten\User\Tommy\pmy',
	'F:\lektorat\REPORT\PRO\dtd-re', 
	'F:\lektorat\SGML\GESTRANS', 
#	'C:\Dokumente Und Einstellungen\Thofmann\Desktop\tab2sgm', 
	'F:\lektorat\REPORT\PRO\tab2sgm', 
	'M:\wwwroot\sich\markup', 
	'M:\wwwroot\sich\markup\opt\faq', 
	'F:\lektorat\REPORT\PRO\tabgross', 
	);
#	'F:\lektorat\REPORT\PRO\GTEXT', 

@dat =	(
	"thpl.pl",
	"thplcopy.pl",
	"thplcopy.bat",
	"sgmtools.pl",
	"thpl.zip",
	"cgi-lib.pl",
	"webtools.pl",
	#"whoamip.pl",
	"checkdate.pl",
	"ubmintra.css",
	);

chop($aktdir = `cd`);
$aktdir = "\L$aktdir";
$aktdir =~ s|^[g-ln-z]|f|i;
$orgein = $/;
print "\t*** thplcopy.pl -- t.h. feb 2001 ***\nVerz:[$aktdir]\n";

foreach $d (@dat) {
	open (EIN, "$aktdir\\$d") || &abbruch ("Kann Datei [$aktdir\\$d] nicht lesen.");
	binmode(EIN) if ($d !~ m/\.(txt|pl|htm|html|css)$/i);
	undef ($/);
	$ein = <EIN>;
	$/ = $orgein;
	close (EIN);
	print "=====d: $d =====\n";
	$i = 0;
	
	alleverz: foreach $v (@verz) {
		$i++;
		$v = "\L$v";
		#print " v:[$v]--aktdir:[$aktdir]\n"; <STDIN>;
		if ($v eq $aktdir) {
			print "\n\t$i nicht";
			next alleverz;
		} else {
			print "\r$i";
		}
		if (! (-d $v)) {
			&fehler ("Kann Datei [$v\\$d] nicht schreiben.");
			next alleverz;
		}
		open (AUS, ">$v\\$d") || &abbruch ("Kann Datei [$v\\$d] nicht schreiben.");
		binmode(AUS) if ($d !~ m/\.(txt|pl|htm|html|css)$/i);
		print AUS $ein;
		close(AUS);
	}
	print "\n"
}

sub abbruch {
	local @u = @_;
	if ($u[0]) {
		print "Fehler: $u[0]\n";
		<STDIN>;
		exit;
	}
}

sub fehler {
	local @u = @_;
	if ($u[0]) {
		print "\nFehler: $u[0]\n";
	}
}
