#!d:/xampp/perl/bin/perl
#!/usr/bin/perl
#######################################################
## editFAQ.pl
## uebernommen von FAQ.pl
## uebernommen von Start.pl
## uebernommen von whoamip-web.pl
##
## Startseite der Bearbeitung der FAQ-Kategorien ausgeben.
## Bearbeitung gleich hier drin?
## 	Ja!
## 	dann muss ich die Parameter auswerten
##
## Was muss die Startseite enthalten?
## - Liste der Kategorien mit Links und ev. wieviele Eintraege
## - Link zum Bearbeiten der Kategorien
## - Fragen von erste Kategorie gleich zeigen?
##
#######################################################
    
##-- Einleitung ---------------------------------------
$| = 1;
$scriptname = $ENV{ 'SCRIPT_FILENAME' };
$slash = "\\";
$aktdir = &holpfad0($scriptname);
if( $aktdir eq '' ) { $aktdir = '.'; }
push (@INC, $aktdir);
require "thpl.pl";
require "cgi-lib.pl";
chdir ($aktdir);

require "webtools.pl";
require "checkdate.pl";

## packe ich bei webtools mit rein
#require "globals.pl";
%globals = &getglobals;
print &PrintHeader();

@i18n_lang = %i18n_lang = ();
$i18n_lang = $globals{ 'i18n_lang' };
$i18n_conf = $globals{ 'i18n_conf' };
if ( !getI18n(*i18n_lang, *i18n_conf) ) {
	webabbruch (trans("Fehler beim Holen der Spracheinstellungen") . ". $globals{'adminmes'}.");
}

## Kommentare holen, keine Fehlermeldung noetig
#%rem = &holrem();

## nur global festlegen
#%opt = ();

$head = &UbmCgiHead(trans("FAQ - Edit Kategorien") );  ##  - Thomas Hofmann; Tel. 146 - T.H. Okt 2005
$langLinks = ' <small class="langLinks">' . linkLang() . '</small> ';
$head =~ s|(</h1>)|$langLinks$1|i;
if( $encoding ) { $head =~ s|ISO\-8859\-1|$encoding|; }
print $head;
print &webtag('p', "class=editfaqkatblock", &weblinkclass(trans("[zur�ck zu den FAQ]"),"faq.pl",'editfaqkatlink') . " " . &weblinkclass(trans("[Start FAQ-Edit Kategorien]"),"editfaqkat.pl",'editfaqkatlink') );


## sind die Dateien da?
## 	s. faq.pl
## Dateien einlesen

($fkat, $ftit, $finh) = ($globals{"faq-kat"},$globals{"faq-tit"},$globals{"faq-inh"});

## vorher definieren wichtig? oder muss ich in sub nochmal definieren?
## scheint nicht so.
#@fkat = @ftit = @finh = ();
#%fkat = %ftit = %finh = ();
#%fnrkat = ();

if (! &holfaq(*fkat, *ftit, *finh, *fnrkat) ) {
	&webabbruch (trans("Fehler beim Holen der Daten") . ". $globals{'adminmes'}.");
}

$keft = "";
if ($globals{"kateditformtype"}) {
	$keft = $globals{"kateditformtype"};
	#print &webtag("globals(kateditformtype)=$keft");
} else {
	$keft = "einzeln";
	#print &webtag("kateditformtype(standard)=$keft");
}

## check if set params in system
if ( $ENV{'FAQ_PRESET'} ) {
	$ENV{'REQUEST_METHOD'} = 'GET';
	$ENV{'QUERY_STRING'} = $ENV{'FAQ_PRESET'};
	$ENV{'QUERY_STRING'} =~ s/\*/&/g;
}

$input="";
@input=();
%input=();
## wurde was uebergeben?
## 	Uebergabe (je nach globals(katformedittype)):
## 	---katformedittype=alles------------------
## 		kattit    = (Name der neuen Kategorie) 			
## 		kattit_nr = (Name der geaenderten Kategorie mit Nr) 	
## 		aktion_nr = (�ndern 1|L�schen 1|Neu|Logout) ( mit Nr)			
## 		neunr     = (Nr der neuen Kategorie)
## 	gibt das zu viele Parameter?, lieber doch jedet Kat ein form?
## 		zunaechst steuerbar ueber globale Variable (getglobals) {'kateditformtype' = (einzeln|alles)}
## 	---katformedittype=einzeln------------------
## 		kattit    = (Name der neuen o. geaenderten Kategorie) 			
## 		aktion    = (�ndern|L�schen|Neu|Logout) 			
## 		neunr     = (Nr der neuen Kategorie)
## 		katnr     = (Nr der geaenderten Kategorie)
## 	---------------------
## 	ACHTUNG!
## 		form auf beide Varianten angepasst zu steuern ueber Variable
## 		Verarbeitung NUR fuer 'einzeln' programmiert!
$aktion = $neunr = $katnr = $kattit = "";
$wer = $womit = "";
if (&ReadParse(*input)) {
	
	#print &webtag("pre","", "#EMPTY#");
	#&printHash(%input);
	#print &webtag("pre","", "#ENDETAG#");
	
	$wer = $input{"wer"};
	$womit = $input{"womit"};
#	webhinweis("\$input{aktion}: $input{aktion}");
	if ($input{"aktion"}) {
		if (!(&isrightdate($wer,$womit))) { &webabbruch(trans("Falscher Nutzer oder Pa�wort") . " [$wer|$womit]"); }
		$aktion = $input{"aktion"};
	    ##--- eigentlich eingerueckt, aber hier ausgerueckt -------------------------------
	    ## 	momentan nur "alles" weiterentwickelt, 
	    ## 		d.h. Variable nicht umstellen, bevor nicht zu Ende programmiert
	    ##--- DAS HIER NICHT!  s.u. -------------------------------
	    if ($keft eq "einzeln") {  ## keft ne 'alles', geht nicht bei Passwortabfrage
#		if ($aktion eq "Neu") {
#			## Uebergabe (notwendig): neunr und kattit
#			if (!($input{"neunr"})) { &webabbruch("Fehlende neunr"); }
#			if (!($input{"kattit"})) { &webabbruch("Fehlendes kattit"); }
#			if ($input{"kattit"} eq "") { &webabbruch("Parameter kattit leer"); }
#			if ($input{"neunr"} eq "") { &webabbruch("Parameter neunr leer"); }
#			if ($input{"neunr"} <= 0) { &webabbruch("Parameter neunr <= 0"); }
#			$neunr = $input{"neunr"};
#			$kattit = $input{"kattit"};
#			## muss ich neunr nochmal pruefen, ob sie auch frei ist?
#			if ($neunr !~ m/^[0-9]+$/i) { &webabbruch("Parameter neunr ist keine Zahl [$neunr]"); }
#			if ($fkat{$neunr}) { &webabbruch("Kategorie Nr ist bereits vergeben [$neunr]"); }
#		} elsif ($aktion eq "�ndern") {
#			## Uebergabe (notwendig): katnr und kattit
#			if (!($input{"katnr"})) { &webabbruch("Fehlende katnr"); }
#			if (!($input{"kattit"})) { &webabbruch("Fehlendes kattit"); }
#			if ($input{"kattit"} eq "") { &webabbruch("Parameter kattit leer"); }
#			if ($input{"katnr"} eq "") { &webabbruch("Parameter katnr leer"); }
#			if ($input{"katnr"} <= 0) { &webabbruch("Parameter katnr <= 0"); }
#			$katnr = $input{"katnr"};
#			$kattit = $input{"kattit"};
#			## muss ich katnr nochmal pruefen, ob sie auch vorhanden ist?
#			if (!($fkat{$katnr})) { &webabbruch("Kategorie Nr ist nicht vorhanden [$katnr]"); }
#		} elsif ($aktion eq "L�schen") {
#			## Uebergabe (notwendig): katnr
#			## 	Kategorie 1 darf man nicht loeschen
#			if (!($input{"katnr"})) { &webabbruch("Fehlende katnr"); }
#			if ($input{"katnr"} eq "") { &webabbruch("Parameter katnr leer"); }
#			if ($input{"katnr"} <= 0) { &webabbruch("Parameter katnr <= 0"); }
#			$katnr = $input{"katnr"};
#			## muss ich katnr nochmal pruefen, ob sie auch vorhanden ist?
#			if (!($fkat{$katnr})) { &webabbruch("Kategorie Nr ist nicht vorhanden [$katnr]"); }
#			if ($katnr == 1) { &webabbruch("Kategorie Nr 1 darf man nicht loeschen"); }
#		} else {
#			&webabbruch("Falsche Aktion [$aktion]");
#		}
	    } else {  ## keft eq 'alles', notwendig bei Passwortabfrage
    	    ##--- ELSE eigentlich eingerueckt, aber hier ausgerueckt -------------------------------
	    ## 	momentan nur "alles" weiterentwickelt, 
	    ## 		d.h. Variable nicht umstellen, bevor nicht zu Ende programmiert
		if ($aktion =~ m/Neu|New/) {
			## Uebergabe (notwendig): neunr und kattit
			if (!($input{"neunr"})) { &webabbruch(trans("Fehlende neunr")); }
			if (!($input{"kattit"})) { &webabbruch(trans("Fehlendes kattit")); }
			if ($input{"kattit"} eq "") { &webabbruch(trans("Parameter kattit leer")); }
			if ($input{"neunr"} eq "") { &webabbruch(trans("Parameter neunr leer")); }
			if ($input{"neunr"} <= 0) { &webabbruch(trans("Parameter neunr") . " <= 0"); }
			$neunr = $input{"neunr"};
			$kattit = $input{"kattit"};
			## muss ich neunr nochmal pruefen, ob sie auch frei ist?
			if ($neunr !~ m/^[0-9]+$/i) { &webabbruch(trans("Parameter neunr ist keine Zahl") . " [$neunr]"); }
			if ($fkat{$neunr}) { &webabbruch(trans("Kategorie Nr ist bereits vergeben") . " [$neunr]"); }
			&webhinweis (trans("Neue Kategorie Nr") . " [$neunr]" . trans(" mit Titel ") . "[$kattit]" . trans(" anlegen.") );
			$fkat{$neunr} = $kattit;
		} elsif ($aktion =~ m/^(�ndern|Change) ([0-9]+)$/) {
			## Uebergabe (notwendig): katnr und kattit
			$katnr = $2;
			if (!($input{"kattit_$katnr"})) { &webabbruch(trans("Fehlendes kattit")); }
			if ($input{"kattit_$katnr"} eq "") { &webabbruch(trans("Parameter kattit leer")); }
			$kattit = $input{"kattit_$katnr"};
			## muss ich katnr nochmal pruefen, ob sie auch vorhanden ist?
			if (!($fkat{$katnr})) { &webabbruch(trans("Kategorie Nr ist nicht vorhanden") . " [$katnr]"); }
			&webhinweis (trans("Kategorie Nr") . " [$katnr] " . trans("mit altem Titel ") . "[$fkat{$katnr}]" . trans(" �ndern in ") . "[$kattit]." );
			$fkat{$katnr} = $kattit;
		} elsif ($aktion =~ /^(L�schen|Delete|Remove) ([0-9]+)$/) {
			## Uebergabe (notwendig): katnr
			## 	Kategorie 1 darf man nicht loeschen
			$katnr = $2;
			## muss ich katnr nochmal pruefen, ob sie auch vorhanden ist?
			if (!($fkat{$katnr})) { &webabbruch(trans("Kategorie Nr ist nicht vorhanden") . " [$katnr]"); }
			if ($katnr == 1) { &webabbruch(trans("Kategorie Nr 1 darf man nicht loeschen")); }
			## muss ich katnr nochmal pruefen, ob auch keine Fragen dazu da sind? 
			## 	Die w�rden sonst in der Luft haengen
			foreach (keys(%fnrkat)) {
				if ($fnrkat{$_} eq $katnr ) { &webabbruch(trans("Zu Kategorie Nr sind noch Fragen vorhanden, kann nicht l�schen") . ". [$katnr]"); }
			}
			&webhinweis (trans("Kategorie Nr") . " [$katnr] " . trans("mit Titel") . " [$fkat{$katnr}]" . trans(" l�schen.") );
			delete ($fkat{$katnr});
		} elsif ($aktion =~ m/Logout|Logout/) {  ## german and english the same phrase in translation?
			&killdating(&whoamip);
		} else {
			&webabbruch(trans("Falsche Aktion") . " [$aktion]");
		}
	    }
	    ##--- ENDE eigentlich eingerueckt, aber hier ausgerueckt -------------------------------
		if ($aktion !~ m/Logout|Logout/) {  ## german and english the same phrase in translation?
			## hier kommt nichts mehr, oder?
			if ( !( &schreibfaq (*fkat, *ftit, *finh, *fnrkat) ) ) {
				&webabbruch(trans("FAQ schreiben ist fehlgeschlagen"));
			}
		}
	} elsif ($aktion eq "") {
			&webabbruch(trans("Aktion leer"));
	}
}



## Kategorien ausgeben mit Links zu den anderen Kategorien und Link zum Aendern---------------------------------------
#webhinweis("\$input{aktion}: $input{aktion}");
&ausgabekatedit(*fkat);


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
