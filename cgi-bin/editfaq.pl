#!c:/xampp/perl/bin/perl -w
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
if( $aktdir eq '' ) { $aktdir = '.'; }
push (@INC, $aktdir);
require "thpl.pl";
require "cgi-lib.pl";
chdir ($aktdir);

require "webtools.pl";

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


## nur global festlegen
#%opt = ();

$head = &UbmCgiHead(trans("FAQ - Edit Fragen"));  ##  - Thomas Hofmann; Tel. 146 - T.H. Okt 2005
my $headsave = $head;
## actions to header for Spoiler-feature
my $onoffscript = getonoffscript();
$head =~ s|(</head>)|$onoffscript$1|is;

$langLinks = ' <small class="langLinks">' . linkLang() . '</small> ';
$head =~ s|(</h1>)|$langLinks$1|i;
if( $encoding ) { $head =~ s|ISO\-8859\-1|$encoding|; }
# put the FORM around the h1
$head =~ s|(<h1([^>]*)>)|\n\t<form action="faq.pl">\n<h1 class="wholetitle" $2>|i;
$head =~ s|(<\/h1>)|$1\n\t</form>\n|i;
print $head;

$aktkat = 1;
$input="";
@input=();
%input=();
my $hashtags = 'off';  ## or simply '' but NOT 'on'
my $hashcloud = 'off';  ## or simply '' but NOT 'on'
my $hashcloudsmall = 'off';  ## or simply '' but NOT 'on'

## check if set params in system
if ( $ENV{'FAQ_PRESET'} ) {
	$ENV{'REQUEST_METHOD'} = 'GET';
	$ENV{'QUERY_STRING'} = $ENV{'FAQ_PRESET'};
	$ENV{'QUERY_STRING'} =~ s/\*/&/g;
}

## wurde was uebergeben?
if (&ReadParse(*input)) {
	if ($input{'kat'}) {
		$aktkat = $input{'kat'};
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
}

## sind die Dateien da?
## 	siehe faq.pl an dieser Stelle (Zeile oben)


($fkat, $ftit, $finh) = ($globals{"faq-kat"},$globals{"faq-tit"},$globals{"faq-inh"});

#@fkat = @ftit = @finh = ();
#%fkat = %ftit = %finh = ();
#%fnrkat = ();

## 	d.h. arbeiten mit Referenzen
if (! holfaq(*fkat, *ftit, *finh, *fnrkat) ) {
	webabbruch (trans("Fehler beim Holen der Daten. ")."$globals{'adminmes'}.");
}

## Kommentare holen, keine Fehlermeldung noetig
#%rem = &holrem();

my ( %hashtag, @hashtags );
if ( $hashtags eq 'on' or $hashcloud eq 'on' or $hashcloudsmall eq 'on' ) {
	%hashtag = gethashtags( \%finh ) ;
	@hashtags = keys( %hashtag );
}

## Kategorien ausgeben mit Links zu den anderen Kategorien und Link zum Aendern---------------------------------
## 	hier brauch ich neue Routine oder einen zusaetzlichen Parameter
$fkat{ 'hashtags' } = \@hashtags if $hashtags eq 'on';  ## tell ausgabekat, it has to write out the hastags
$fkat{ 'hashcloud' } = \%hashtag if $hashcloud eq 'on';  ## tell ausgabekat, it has to write out the hascloud
$fkat{ 'hashcloudsmall' } = \%hashtag if $hashcloudsmall eq 'on';  ## tell ausgabekat, it has to write out the hascloudsmall
$toedit = 1;
$input{'toedit'} = $toedit;
ausgabekat($aktkat, $toedit, %fkat);
delete $fkat{ 'hashtags' } if defined( $fkat{ 'hashtags' } );  ## take away the false kat
delete $fkat{ 'hashcloud' } if defined( $fkat{ 'hashcloud' } );  ## take away the false kat
delete $fkat{ 'hashcloudsmall' } if defined( $fkat{ 'hashcloudsmall' } );  ## take away the false kat

## FAQ ausgeben mit Link zum Aendern---------------------------------------
## brauch ich hier die Kategorien zu uebergeben?
ausgabefaq($aktkat, $toedit, *fkat, *ftit, *finh, *fnrkat);


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
