#!d:/xampp/perl/bin/perl
#!/usr/bin/perl
#######################################################
## FAQeditSic.pl
## uebernommen von editFAQ.pl
## uebernommen von FAQ.pl
## uebernommen von Start.pl
## uebernommen von whoamip-web.pl
##
## Sichern der von FAQedit.pl bearbeiteten Felder
##
## Was muss diese Seite enthalten?
## - Link zurueck zum Bearbeiten der FAQ
## - FAQ speichern und bestaetigen
## - Ausgabe bearbeitete Frage
##
#######################################################
    
##-- Einleitung ---------------------------------------
$| = 1;
$scriptname = $ENV{ 'SCRIPT_FILENAME' };
$slash = "\\";
$aktdir = &holpfad0($scriptname);
push (@INC, $aktdir);
require "thpl.pl";
require "cgi-lib.pl";
chdir ($aktdir);

require "webtools.pl";
require "checkdate.pl";

%globals = &getglobals;
print &PrintHeader();

@i18n_lang = %i18n_lang = ();
$i18n_lang = $globals{ 'i18n_lang' };
$i18n_conf = $globals{ 'i18n_conf' };
if ( !getI18n(*i18n_lang, *i18n_conf) ) {
	webabbruch (trans("Fehler beim Holen der Spracheinstellungen") . ". $globals{'adminmes'}.");
}

	## actions for spoiler
	our $spoileridx = 1;


## Kommentare holen, keine Fehlermeldung noetig
#%rem = &holrem();

$head = &UbmCgiHead(trans("FAQ - Edit FAQ Frage sichern") );  ##  - Thomas Hofmann; Tel. 146 - T.H. Okt 2005
my $headsave = $head;
## actions to header for Spoiler-feature
my $onoffscript = getonoffscript();
$head =~ s|(</head>)|$onoffscript$1|is;

$langLinks = ' <small class="langLinks">' . linkLang() . '</small> ';
$head =~ s|(</h1>)|$langLinks$1|i;
if( $encoding ) { $head =~ s|ISO\-8859\-1|$encoding|; }
print $head;
print &webtag(&weblink(trans("[zurück zu Edit Fragen]"),"editfaq.pl") );


($fkat, $ftit, $finh) = ($globals{"faq-kat"},$globals{"faq-tit"},$globals{"faq-inh"});


if (! &holfaq(*fkat, *ftit, *finh, *fnrkat) ) {
	&webabbruch (trans("Fehler beim Holen der Daten. ")."$globals{'adminmes'}.");
}


$input="";
@input=();
%input=();
## wurde was uebergeben?
$nr = $tit = $kat = $inh = "";
$wer = $womit = "";
$aktion = "";
if (&ReadParse(*input)) {
	
	#print &webtag("pre","", "#EMPTY#");
	#&printHash(%input);
	#print &webtag("pre","", "#ENDETAG#");
	
	$wer = $input{"wer"};
	$womit = $input{"womit"};
	if (defined($input{"aktion"})) {
		$aktion = $input{"aktion"};
	} else {
		&webabbruch(trans("Fehlende Aktion."));
	}
	if ($aktion eq "") {
		&webabbruch(trans("Aktion leer."));
	}
	if (!(&isrightdate($wer,$womit))) { &webabbruch(trans("Falscher Nutzer oder Paßwort")); }

    ##---eigentlich eingerueckt----------------------------------------------------
    if ($aktion =~ m/^(Ändern|Anlegen|Change|Create)$/i) {
	
	if (
#		!$input{"nr"} &&
#		!$input{"kat"} &&
#		!$input{"tit"} &&
#		!$input{"text"} 
		!(
		  $input{"nr"} &&
		  $input{"kat"} &&
		  $input{"tit"} &&
		  $input{"text"} 
		)
	) {
		my $printvar = &PrintVariables(%input);
		my $missingvar = '';
		$missingvar .= " FAQ-Nr," if !$input{"nr"};
		$missingvar .= " Kategorie-Nr," if !$input{"kat"};
		$missingvar .= " Frage," if !$input{"tit"};
		$missingvar .= " Antwort" if !$input{"text"};
		&webabbruch(trans("Fehlende Daten, Daten nicht vollständig:") . trans($missingvar)); #  . $printvar  #  " (FAQ-Nr, Kategorie-Nr, Frage, Antwort)."
	}

	$nr = $input{"nr"};
	$kat = $input{"kat"};
	$tit = $input{"tit"};
	$inh = $input{"text"};

	print &webtag(&weblink(trans("[zurück zu Edit Fragen in Kategorie $kat]"),"editfaq.pl?kat=$kat") );
	
	## Schutz bei Titel und Inhalt vornehmen
	## 	titel: Umbrueche, Tabs, Markup raus
	## 	inhalt: Umbrueche umwandeln, Tabs=" ", Pseudomarkup umwandeln, Rest-Markup raus
	$tit =~ s/[\t\n]/ /ig;
	$tit =~ s/<[^ ].*?>//ig;
	$ftit{$nr} = $tit;
	$fnrkat{$nr} = $kat;
	$inh = &input2faq($inh);
	$finh{$nr} = $inh;

	if ( !( &schreibfaq (*fkat, *ftit, *finh, *fnrkat) ) ) {
		&webabbruch(trans("FAQ schreiben ist fehlgeschlagen."));
	}
	## der Hinweis kommt schon aus der Routine selbst
	#&webhinweis("FAQ Frage gesichert.");
	
	print &webtag("div", "class=faqantworten", "#EMPTY#");
	print &webtag("h3", "class=faqanttit", trans("Antworten"));
	print &webtag(trans("Kategorie Nr.: $kat"));
	print &webtag("dl", "", "#EMPTY#");

	print &webtag("dt", &webtag("a","name=faq$nr", "$nr\. $ftit{$nr}") );
	print &webtag("dd", &faq2htm($finh{$nr}) . "<br>"  );
	
	print &webtag("dl", "", "#ENDETAG#");
	print &webtag("div", "", "#ENDETAG#");
    } elsif ($aktion =~ m/Löschen|Delete/) {
    ##---ELSIF eigentlich eingerueckt----------------------------------------------------
    	## erst schauen, ob es Nr 1 ist. Nr. 1 darf nicht geloescht werden.
    	## am Ende ausgeben
    	## auch hier alle Felder pruefen
    	## FAQ sichern
	if (
		!$input{"nr"} &&
		!$input{"kat"} &&
		!$input{"tit"} &&
		!$input{"text"} 
	) {
		&PrintVariables(%input);
		&webabbruch(trans("Fehlende Daten, Daten nicht vollständig ") . trans("(FAQ-Nr, Kategorie-Nr, Frage, Antwort)."));
	}

	$nr = $input{"nr"};
	$kat = $input{"kat"};
	$tit = $input{"tit"};
	$inh = $input{"text"};

	print &webtag(&weblink(trans("[zurück zu Edit Fragen in Kategorie $kat]"),"editfaq.pl?kat=$kat") );

	if ($nr == 1) {
		&webabbruch(trans("Frage Nr. 1 darf nicht geloescht werden."));
	}
	## was muss ich loeschen?
	## 	&holfaq(*fkat, *ftit, *finh, *fnrkat)
	## 	ftit, finh, fnrkat
	delete $ftit{$nr};
	delete $finh{$nr};
	delete $fnrkat{$nr};

	if ( !( &schreibfaq (*fkat, *ftit, *finh, *fnrkat) ) ) {
		&webabbruch(trans("FAQ schreiben ist fehlgeschlagen."));
	}

	print &webtag("h3", "class=faqdeletetit", trans("gelöschte FAQ"));
	print &webtag(trans("Kategorie Nr.: $kat"));
	print &webtag("dl", "", "#EMPTY#");

	print &webtag("dt", &webtag("a","name=faq$nr", "$nr\. $tit") );
	print &webtag("dd", &faq2htm($inh) . "<br>"  );
	
	print &webtag("dl", "", "#ENDETAG#");
    	
    } elsif ($aktion =~ m/Logout|Logout/) {  ## further may be othet translation in english
    ##---ELSIF eigentlich eingerueckt----------------------------------------------------
    	&killdating(&whoamip);
    } else {
    ##---ELSE eigentlich eingerueckt----------------------------------------------------
    	&webabbruch(trans(trans("Falsche Aktion")) . " [$aktion].");
    }
    ##---ENDE eigentlich eingerueckt----------------------------------------------------

} else {
	&PrintVariables(%input);
	&webabbruch(trans("Fehlende Daten, Daten nicht vollständig ") . trans("(FAQ-Nr, Kategorie-Nr, Frage, Antwort)."));
}


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
