#!D:/xampp/perl/bin/perl -w
#!/usr/bin/perl
#######################################################
## faqsearch.pl
## uebernommen von FAQ.pl
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
print PrintHeader();

@i18n_lang = %i18n_lang = ();
$i18n_lang = $globals{ 'i18n_lang' };
$i18n_conf = $globals{ 'i18n_conf' };
if ( !getI18n(*i18n_lang, *i18n_conf) ) {
	webabbruch (trans("Fehler beim Holen der Spracheinstellungen") . ". $globals{'adminmes'}.");
}


## nur global festlegen
#%opt = ();

$head = UbmCgiHead(trans("FAQ - Suche"));  ##  - Thomas Hofmann; Tel. 146 - T.H. Okt 2005
$langLinks = ' <small class="langLinks">' . linkLang() . '</small> ';
$head =~ s|(</h1>)|$langLinks$1|i;
if( $encoding ) { $head =~ s|ISO\-8859\-1|$encoding|; }
print $head;

$aktkat 		= 1;
$input 			= "";
@input 			= ();
%input 			= ();
$searchstring 	= '';
$onlypickedkat	= undef;
$hashtags = 'off';  ## or simply '' but NOT 'on'
$hashcloud = 'off';  ## or simply '' but NOT 'on'
$hashcloudsmall = 'off';  ## or simply '' but NOT 'on'
## wurde was uebergeben?
if ( ReadParse( *input ) ) {
	if ($input{'kat'}) {
		$aktkat = $input{'kat'};
	}
	if ($input{'searchstring'}) {
		$searchstring = $input{'searchstring'};
	}
	if ( $input{'onlypickedkat'}) {
		$onlypickedkat = $input{'onlypickedkat'};
	} else {
		$aktkat = 'alle';
	}
	if( !defined( $input{"hashtags"} ) ) { $input{"hashtags"} = ''; }
	if ( $input{'hashtags'} =~ m/on/i ) {
		$hashtags = 'on';
	}
	if( !defined( $input{"hashcloud"} ) ) { $input{"hashcloud"} = ''; }
	if ( $input{'hashcloud'} =~ m/on/i ) {
		$hashcloud = 'on';
	}
	if( !defined( $input{"hashcloudsmall"} ) ) { $input{"hashcloudsmall"} = ''; }
	if ( $input{'hashcloudsmall'} =~ m/on/i ) {
		$hashcloudsmall = 'on';
	}
	if ($input{'fueredit'}) {
		$fueredit = $input{'fueredit'};
	}
}

#webhinweis( "searchstring in faqsearch.pl: [$searchstring]" );
#webhinweis( "IN faqsearch.pl; aktkat/onlypickedkat: [$aktkat/$onlypickedkat]" );

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

($fkat, $ftit, $finh) = ($globals{"faq-kat"},$globals{"faq-tit"},$globals{"faq-inh"});

#@fkat = @ftit = @finh = ();
#%fkat = %ftit = %finh = ();
#%fnrkat = ();

if (! holfaq(*fkat, *ftit, *finh, *fnrkat) ) {
	webabbruch (trans("Fehler beim Holen der Daten.") . " $globals{'adminmes'}.");
}

## Kommentare holen, keine Fehlermeldung noetig
#%rem = &holrem();

my ( %hashtag, @hashtags );
if ( $hashtags eq 'on' or $hashcloud eq 'on' or $hashcloudsmall eq 'on' ) {
	%hashtag = gethashtags( \%finh ) ;
	@hashtags = keys( %hashtag );
}

## Kategorien ausgeben mit Links zu den anderen Kategorien und Link zum Aendern---------------------------------------
$fkat{ 'hashtags' } = \@hashtags if $hashtags eq 'on';  ## tell ausgabekat, it has to write out the hastags
$fkat{ 'hashcloud' } = \%hashtag if $hashcloud eq 'on';  ## tell ausgabekat, it has to write out the hascloud
$fkat{ 'hashcloudsmall' } = \%hashtag if $hashcloudsmall eq 'on';  ## tell ausgabekat, it has to write out the hascloudsmall
#$fueredit = undef;  ## siehe oben
#$input{'fueredit'} = $fueredit;  ## siehe oben
## searchstring uebergeben
$fkat{'searchstring'} = $searchstring;
ausgabekat($aktkat, $fueredit, %fkat);
delete $fkat{'searchstring'} if defined( $fkat{'searchstring'} );
delete $fkat{ 'hashtags' } if defined( $fkat{ 'hashtags' } );  ## take away the false kat
delete $fkat{ 'hashcloud' } if defined( $fkat{ 'hashcloud' } );  ## take away the false kat
delete $fkat{ 'hashcloudsmall' } if defined( $fkat{ 'hashcloudsmall' } );  ## take away the false kat

## FAQ ausgeben mit Link zum Aendern---------------------------------------
## brauch ich hier die Kategorien zu uebergeben?
#webhinweis( "searchstring vor ausgabefaqfound: [$searchstring]" );
ausgabefaqfound($aktkat, $fueredit, $searchstring, *fkat, *ftit, *finh, *fnrkat);


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

        $vpfad = $par[0] ? $par[0] : '';
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
