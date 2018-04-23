#!D:/xampp/perl/bin/perl
#!/usr/bin/perl
#######################################################
## FAQedit.pl
## uebernommen von editFAQ.pl
## uebernommen von FAQ.pl
## uebernommen von Start.pl (markup)
## uebernommen von whoamip-web.pl
##
## Seite zum Bearbeiten einer FAQ ausgeben, Nr. wird uebergeben
##
## Was muss die Bearbeitungsseite enthalten?
## - Link zurueck zum Bearbeiten der Kategorien, dabei die Kategorie der Frage uebergeben
## - Link zum Loeschen der Frage
## - Felder zum Bearbeiten
##   - Titel der Frage
##   - Nr. der Kategorie
##   - Text der Frage
## - Eingabe pruefen
##   - bestimmte HTML-Tags umwandeln in Pseudomarkup
##    	<BR>		02 (oder 127?)
##    	<a href="xyz">abc</a>		[link=xyz]abc[/link]
##    	<a href="xyz" target="_blank">abc</a>		[linkx=xyz]abc[/link]
##    	<b>abc</b>		[b]abc[/b]
##    	<i>abc</i>		[i]abc[/i]
##    	<ul>		[list]
##    	</ul>		[/list]
##    	<li>		[*]
##    	<ol>		[list=1]
##    	<ol type="1">		[list=1]
##    	<ol type="a">		[list=a]
##    	<ol type="A">		[list=A]
##    	<ol type="i">		[list=i]
##    	<ol type="I">		[list=I]
##    	<img src="xyz">		[img=xyz]
##    	<pre>		[code]
##    	</pre>		[/code]
##    	<code>		[code]
##    	</code>		[/code]
##    	<blockquote>		[quote]
##    	</blockquote>		[/quote]
##   - kein HTML annehmen, Rest HTML raus
##   - Umbrüche umwandeln		s. <BR>
## - bei Ausgabe Pseudomarkup in HTML umwandeln (faq.pl u. editfaq.pl? oder webtools.pl?)
##   genau umgedreht wie oben? Ja.
## - am Ende sichern - macht das von hier aufgerufene Script
##
## Parameter: Nr. zu bearbeitende Frage o. "neu"
##
#######################################################
    
##-- Einleitung ---------------------------------------
$scriptname = $ENV{ 'SCRIPT_FILENAME' };
$slash = "\\";
$aktdir = &holpfad0($scriptname);
push (@INC, $aktdir);
require "thpl.pl";
require "cgi-lib.pl";
chdir ($aktdir);

require "webtools.pl";
require "checkdate.pl";

## packe ich bei webtools mit rein
#require "globals.pl";
%globals = &getglobals;

@i18n_lang = %i18n_lang = ();
$i18n_lang = $globals{ 'i18n_lang' };
$i18n_conf = $globals{ 'i18n_conf' };
if ( !getI18n(*i18n_lang, *i18n_conf) ) {
	webabbruch (trans("Fehler beim Holen der Spracheinstellungen") . ". $globals{'adminmes'}.");
}


## nur global festlegen
#%opt = ();

print &PrintHeader();
$head = &UbmCgiHead(trans("FAQ - Edit FAQ Frage"));  ##  - Thomas Hofmann; Tel. 146 - T.H. Okt 2005
print $head;

print &webtag( &weblink(trans("[zurück zu Edit Fragen]"), "editfaq.pl") );

#print "<p>_____faqedit.pl_____</p>\n";

$aktkat = 1;
$input="";
@input=();
%input=();
$faqnr = 0;
## wurde was uebergeben?
## wenn nicht dann Fehler, es muss die Nr. uebergeben werden
if (&ReadParse(*input)) {
	if ($input{'kat'}) {
		$aktkat = $input{'kat'};
	}
	if ($input{'fnr'}) {
		$faqnr = $input{'fnr'};
	}
} else {
	&webabbruch(trans("Keine Nr. zum Bearbeiten uebergeben.")); 
}

($fkat, $ftit, $finh) = ($globals{"faq-kat"},$globals{"faq-tit"},$globals{"faq-inh"});

#@fkat = @ftit = @finh = ();
#%fkat = %ftit = %finh = ();
#%fnrkat = ();
if (! &holfaq(*fkat, *ftit, *finh, *fnrkat) ) {
	&webabbruch (trans("Fehler beim Holen der Daten. ")."$globals{'adminmes'}.");
}

## Kommentare holen, keine Fehlermeldung noetig
#%rem = &holrem();

#print &webtag( "p", "", "vor ausgabefaqedit: faqnr[$faqnr]" );

## jetzt kann ich Link zum Bearbeiten der Fragen in der richtigen Kategogie ausgeben
## 	ausser es ist "neu"
if ($faqnr =~ m/neu|new/) {
	&ausgabefaqedit($faqnr, *fkat, *ftit, *finh, *fnrkat);
} else {
	if (!($fnrkat{$faqnr})) { &webabbruch (trans("FAQ-Nr. existiert nicht [$faqnr].")); }
	$kat = $fnrkat{$faqnr};
	print &webtag( &weblink(trans("[zurück zu Edit Fragen in Kategorie $kat]"), "editfaq.pl?kat=$kat") );
	&ausgabefaqedit($faqnr, *fkat, *ftit, *finh, *fnrkat);
}

## Kategorien ausgeben mit Links zu den anderen Kategorien und Link zum Aendern---------------------------------
## 	hier brauch ich neue Routine oder einen zusaetzlichen Parameter
#$fueredit = 1;
#&ausgabekat($aktkat, $fueredit, %fkat);

## FAQ ausgeben mit Link zum Aendern---------------------------------------
## brauch ich hier die Kategorien zu uebergeben?
#&ausgabefaq($aktkat, $fueredit, *fkat, *ftit, *finh, *fnrkat);


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
