#!D:/xampp/perl/bin/perl -w
#!/usr/bin/perl
#######################################################
## editFAQ.pl
## uebernommen von FAQ.pl
## uebernommen von Start.pl (markup)
## uebernommen von whoamip-web.pl
## Startseite der FAQ zum Bearbeiten ausgeben.
##
## Was muss die Bearbeitungsseite enthalten?
## - Liste der Kategorien mit Links und ev. wieviele Eintraege
## (- Link zum Bearbeiten der Kategorien)
## - Fragen von erste Kategorie gleich zeigen?
## - zu jeder Frage beim Inhalt einen Link zum Editieren 
##
## Parameter: evtl. zu zeigende Kategorie
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

## packe ich bei webtools mit rein
#require "globals.pl";
%globals = &getglobals;

## nur global festlegen
#%opt = ();

print &PrintHeader();
$head = &UbmCgiHead("FAQ - Edit Fragen");  ##  - Thomas Hofmann; Tel. 146 - T.H. Okt 2005
print $head;

$aktkat = 1;
$input="";
@input=();
%input=();
## wurde was uebergeben?
if (&ReadParse(*input)) {
	if ($input{'kat'}) {
		$aktkat = $input{'kat'};
	}
}

## sind die Dateien da?
## 	siehe faq.pl an dieser Stelle (Zeile oben)


($fkat, $ftit, $finh) = ($globals{"faq-kat"},$globals{"faq-tit"},$globals{"faq-inh"});

#@fkat = @ftit = @finh = ();
#%fkat = %ftit = %finh = ();
#%fnrkat = ();

## 	d.h. arbeiten mit Referenzen
if (! &holfaq(*fkat, *ftit, *finh, *fnrkat) ) {
	&webabbruch ("Fehler beim Holen der Daten. $globals{'adminmes'}.");
}

## Kommentare holen, keine Fehlermeldung noetig
#%rem = &holrem();


## Kategorien ausgeben mit Links zu den anderen Kategorien und Link zum Aendern---------------------------------
## 	hier brauch ich neue Routine oder einen zusaetzlichen Parameter
$fueredit = 1;
&ausgabekat($aktkat, $fueredit, %fkat);

## FAQ ausgeben mit Link zum Aendern---------------------------------------
## brauch ich hier die Kategorien zu uebergeben?
&ausgabefaq($aktkat, $fueredit, *fkat, *ftit, *finh, *fnrkat);


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