#!D:/xampp/perl/bin/perl -w
#!/usr/bin/perl
#######################################################
## FAQ.pl
## uebernommen von Start.pl
## uebernommen von whoamip-web.pl
## Startseite der FAQ ausgeben.
##
## Was muss die Startseite enthalten?
## - Liste der Kategorien mit Links und ev. wieviele Eintraege
## - Link zum Bearbeiten der Kategorien
## - Fragen von erste Kategorie gleich zeigen?
##
## Parameter: evtl. zu zeigende Kategorie
##
#######################################################
    
##-- Einleitung ---------------------------------------
#$scriptname = $ENV{ 'PATH_TRANSLATED' };
## geht nicht, daher diese Variable
$scriptname = $ENV{ 'SCRIPT_FILENAME' };
$slash = "\\";
$aktdir = holpfad0($scriptname);

#print "Content-type: text/html\n\n";
#print "<html>\n<head>\n<title>Test</title>\n</head>\n<body>\n";
#print "<p>scriptname=[$scriptname]</p>\n";
#print "<p>PATH_TRANSLATED=[$ENV{ 'PATH_TRANSLATED' }]</p>\n";

push (@INC, $aktdir);
require "thpl.pl";
require "cgi-lib.pl";
chdir ($aktdir);

require "webtools.pl";

## packe ich bei webtools mit rein
#require "globals.pl";
%globals = getglobals();

## nur global festlegen
#%opt = ();

print PrintHeader();
$head = UbmCgiHead("FAQ - Hilfe: häufig gestellte Fragen");  ##  - Thomas Hofmann; Tel. 146 - T.H. Okt 2005
print $head;

$aktkat = 1;
$input="";
@input=();
%input=();
my $hashtags = 'off';  ## or simply '' but NOT 'on'
## wurde was uebergeben?
if (ReadParse(*input)) {
	if ($input{'kat'}) {
		$aktkat = $input{'kat'};
	}
	if ( $input{'hashtags'} =~ m/on/i ) {
		$hashtags = 'on';
	}
}

#webhinweis( "aktkat nach Einlesen input: [$aktkat]" );

## sind die Dateien da?
## 	faq-titel faq-kategogien faq-inhalt
## 		in globals.pl festlegen
##	tabulator separierte Textdateien
## 	jede Datei muss wenigstens einen Eintrag haben, einziger Eintrag kann nicht geloescht werden
## Aufbau:
## faq-tit
## 	FAQNr, KatNr, Titel der Frage
## 		aus dieser Datei muss ich 2 Felder machen: 
## 		ftit fuer FAQNr, Titel der Frage
## 		fnrkat fuer FAQNr, KatNr
## faq-kat
## 	KatNr, Name der Kategogie
## faq-inh
## 	FAQNr, Inhalt der Frage
##
## Probleme Inhalt FAQ
## 	Wie mache ich das hier mit dem Inhalt? 
## 	Was soll der alles enthalten? 
## 		normalen Text
## 		Umbrueche
## 		Links
## 		Listen
## 		fett, kursiv
## 		Ueberschriften
## 		Code
## 	Wie speichere ich Umbrueche? 
## 		(\x02)
## Dateien einlesen



## nur global festlegen ($ftit usw.)
## 	s.u.

#print "<hr><pre>\n";
#&printHash(%globals);
#print "</pre><hr>\n";


##-- Sollte ich das Folgende auslagern in eine do "holfaq.pl" Routine? ---------------------------------
## besser waere ein sub, nur wie soll ich die Felder übergeben?
## habe bei perl-archiv.de was gefunden:
## 	http://www.perl-archiv.de/sid1953062225218/perl/tutorial/references.shtml
##
## 	($aref, $bref) = func(\@a, \@b);
## 	print "@$aref has more then @$bref\n";
## 	sub func {
## 	    my ($cref, $dref) = @_;
## 	    if (@$cref > @$dref) {
## 	        return ($cref, $dref);
## 	    } else {
## 	        return ($dref, $cref);
## 	    }
## 	}
##
## 	d.h. arbeiten mit Referenzen



#webhinweis( "faq.pl - VOR Dateinamen Festlegung" );
($fkat, $ftit, $finh) = ($globals{"faq-kat"},$globals{"faq-tit"},$globals{"faq-inh"});
#webhinweis( "faq.pl - NACH Dateinamen Festlegung" );

#@fkat = @ftit = @finh = ();
#%fkat = %ftit = %finh = ();
#%fnrkat = ();

if (! holfaq(*fkat, *ftit, *finh, *fnrkat) ) {
	webabbruch ("Fehler beim Holen der Daten. $globals{'adminmes'}.");
}
#webhinweis( "faq.pl - NACH holfaq" );

## Kommentare holen, keine Fehlermeldung noetig
#%rem = &holrem();

my @hashtags = gethashtags( \%finh ) if $hashtags eq 'on';

## Kategorien ausgeben mit Links zu den anderen Kategorien und Link zum Aendern---------------------------------------
$fkat{ 'hashtags' } = \@hashtags if $hashtags eq 'on';  ## tell ausgabekat, it has to write out the hastags
$fueredit = undef;
ausgabekat($aktkat, $fueredit, %fkat);
delete $fkat{ 'hashtags' } if defined( $fkat{ 'hashtags' } );  ## take away the false kat

## FAQ ausgeben mit Link zum Aendern---------------------------------------
## brauch ich hier die Kategorien zu uebergeben?
#webhinweis( "aktkat vor ausgabefaq: [$aktkat]" );
ausgabefaq($aktkat, $fueredit, *fkat, *ftit, *finh, *fnrkat);


print "</html>\n";
exit(0);

##-- ENDE Hauptprogramm -------------------------------


##-- SUBs ---------------------------------------------
sub holpfad0 {
## Uebergabe: vollstaendiges Verzeichnis/Dateiname
## Rueckgabe: Verzeichnis ohne Dateiname bzw. letztes Unterverzeichnis
## globale Variablen: nurpfad, nurdat, slash

        local (@par)=@_;
        local ($vpfad);

        $vpfad=$par[0];
        #print ">$vpfad<\n";
        $vpfad =~ m/^(.+)([\\\/])(.*)$/;
        if (defined($1)) {
                $nurpfad = $1;
                $slash   = $2;
                $nurdat  = $3;
        } else {
                $nurpfad = '';
                $nurdat = $vpfad;
        }
        #print "LEER\n" if ($nurpfad eq '') || print ">$nurpfad<\n";
        #print ">$nurdat<\n";
        return ($nurpfad);
}


##-- ENDE Alles ---------------------------------------
