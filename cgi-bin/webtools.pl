#!d:/xampp/perl/bin/perl -w
#!/usr/bin/perl -w
#######################################################
## webtools.pl
## Thomas Hofmann Sep 2005
## Routinen fuer das Einbinden in Web-Projekte auf dem Intraget Webserver
#######################################################

1;

#---Fehlerausgabe in HTML-Seite------------------------------------
sub webfehler {
	## Uebergabe: Nachricht
	local ( $message, @rest) = @_;
#	if ( defined( @{%i18n_lang} ) ) {
	if ( %i18n_lang ) {
		print "\n<p class='webfehler'><strong class='fehltit'>".trans("Fehler:")."</strong> $message</p>\n";
	} else {
		print "\n<p class='webfehler'><strong class='fehltit'>Fehler:</strong> $message</p>\n";
	}
}

#---Fehlerausgabe in HTML-Seite und Abbruch------------------------------------
sub webabbruch {
	## Uebergabe: Nachricht
	local ( $message, @rest ) = @_;
#	if ( defined(%i18n_lang) ) {
	if ( %i18n_lang ) {
		print "\n<p class='webfehler'><strong class='fehltit'>".trans("Abbruch, Fehler:")."</strong> $message</p>\n";
	} else {
		print "\n<p class='webfehler'><strong class='fehltit'>Abbruch, Fehler:</strong> $message</p>\n";
	}
	exit;
}

#---Hinweisausgabe in HTML-Seite------------------------------------
sub webhinweis {
	## Uebergabe: Nachricht
	local ( $message, @rest) = @_;
#	if ( defined(%i18n_lang) ) {
	if ( %i18n_lang ) {
		print "\n<p class='webhinweis'><strong class='hinwtit'>".trans("Hinweis:")."</strong> $message</p>\n";
	} else {
		print "\n<p class='webhinweis'><strong class='hinwtit'>Hinweis:</strong> $message</p>\n";
	}
}

#---Hinweisausgabe in HTML-Seite mit Link --------------------------
sub webhinweislink {
	## Uebergabe: Nachricht, Linktext, Link
	local (@mes) = @_;
	print "\n<p class='webhinweis'><strong class='hinwtit'>Hinweis:</strong> $mes[0] <a href=\"$mes[2]\">$mes[1]</a></p>\n";
}

#---Rueckgabe des Codes fuer einen Link in HTML --------------------------
sub weblink {
	## Uebergabe: Linktext, Link
	local ( $linktext, $linkurl, @rest) = @_;
	return ("<a href=\"$linkurl\">$linktext</a>");
}

#---Rueckgabe des Codes fuer ein Element in HTML mit Attributen --------------------------
sub webtag {
	## Uebergabe: Element, Attribute, Inhalt
	## Attribute nach Schema: var1=val1\tvar2=val2 ...
	## gar nichts da: .. leeres P
	## nur 1 Uebergabe: als Inhalt in P
	## 2 Uebergabe: 1=Element, 2=Inhalt
	## 3 Uebergabe: 1=Element, 2=Attribute, 3=Inhalt
	## 3 Uebergabe, empty Tag: 1=Element, 2=Attribute, 3=#EMPTY#
	## 3 Uebergabe, Ende-Tag: 1=Element, 2=leer, 3=#ENDETAG#
	
	local (@par) = @_;
	local ($el, $att, $cont, $starttag, $umbruch) = ("P", "", "", "", "");
	## siehe auch blockel in: faq2htm
	local ($blockel) = "P|H1|H2|H3|H4|H5|H6|UL|OL|PRE|DL|DIV|NOSCRIPT|BLOCKQUOTE|FORM|HR|TABLE|FIELDSET|ADDRESS|TR|TD|TH|FRAME|FRAMESET|NOFRAMES|LI|DD|DT|SELECT|OPTION";
	
	if ($#par < 0) {
		## gar nix tun
	} elsif ($#par == 0) {
		$cont = $par[0];
	} elsif ($#par == 1) {
		$el = $par[0];
		$cont = $par[1];
	} elsif ($#par == 2) {
		$el = $par[0];
		local $temp = $par[1];
		local @temp = split(/\t/, $temp);
		local ($k, $v);
		$att = "";
		foreach $temp (@temp) {
			($k, $v) = split (/=/, $temp, 2);
			$att .= " $k\=\"$v\"";
		}
		$cont = $par[2];
	}
	$starttag = "<$el$att>";
	if ("\U$el" =~ m/^($blockel)$/i) { $umbruch = "\n"; }
	
	if ("\U$cont" eq "#EMPTY#") {
		return ("$starttag");
	} elsif ("\U$cont" eq "#ENDETAG#") {
		return ("</$el>$umbruch");
	} else {
		return ("$starttag$cont</$el>$umbruch");
	}
}

#---Optionen lesen-------------------------------------------
#-- 21.09.2005
## ist das gut hier? lieber Neuanlegen oder Loeschung ueber Zuweisung des Ergebnisses der SUB (Hash)
#undef(*opt);

sub holopt {
#---Parameter:
#--     Konfigurationsdatei
#--     errmes als globale Variable zuweisen? dann schon im Hauptprogramm festlegen?
	local (@par) = @_;
	local ($k,$v,%myopt);
	## falls %opt schon ausserhalb festgelegt war
	%myopt = %opt;

	if ($#par < 0) {
		&webabbruch ("holopt: Kein oder zuwenig Parameter [$#par] uebergeben! Richtig: konfigurations-dateiname-und-pfad");
	}
	local $optdat = $par[0];
	if (!(-f $optdat)) {
		&webabbruch ("holopt: Konfigurationsdatei [$optdat] nicht vorhanden!\n");
	}

	#-- Konfigurations-Datei $conf
	open (OPT, $optdat) || &webabbruch("Kann Konfigurationsdatei [$optdat] nicht lesen!\n");
	while ($z = <OPT>) {
		chop ($z) if ($z =~ m/\n$/i);
	    #-- leere Zeile und Kommentar
	    if (($z !~ m/^[ \t]*$/i) && ($z !~ m/^[ \t]*#/i)) {
		if ($z =~ m/\t/i) {
			($k,$v) = split(/\t/, $z, 2);
		} else {
			$k = $z;
			$v = undef();
		}
		#-- Kleinschreibung bei Key
		$k = "\l$k";
		if (defined($myopt{$k})) {
			#-- ist die Unterscheidung nach defined und $myopt{$k} noetig?
			if ($myopt{$k}) {
				if ($v) {
					$myopt{$k} .= "\t$v";
				}
			} else {
				if ($v) {
					$myopt{$k} = "$v";
				}
			}
		} else {
			$myopt{$k} = "$v";
		}
	    }  #-- of is Kommentar or leere Zeile
	}
	close (OPT);

	return(%myopt);	
}

#---Optionen schreiben------------------------------------

sub schreibopt {
#---Parameter:
#--     Konfigurationsdatei, Optionen (Hash)

	local ($optdat, %myopt) = @_;
	local ($k,$v);

	#&webhinweis ("schreibopt, \@_ Anzahl=" . @_ );
	#&webhinweis ("schreibopt, \$optdat=" . $optdat );
	#&webhinweis ("schreibopt, myopt Anzahl=" . keys(%myopt));
	
	open (OPT, ">$optdat") || &webabbruch("Kann Konfigurationsdatei [$optdat] nicht schreiben!\n");
	## ich muss wahrscheinlich die Kommentare wegfallen lassen. sonst zuviel Aufwand
	while (($k,$v) = each %myopt) {
		print OPT "$k\t$v\n";
	}
	close (OPT);
	return(1);
}	

##---Optionen mit Standard vorbelegen--------------------------------------------------
sub optstandard {
## Parameter: keine

## - welche Optionen?
##   - Arbeitsverzeichnis
##   - Dateiname
##   - ID
##   - Zielverzeichnis

	local %myopt = (
		"bearb", 	"c:\\ubmdaten\\bearb",
		"datei", 	"g000001",
		"id", 		"id000001",
		"ziel", 	"f:\\lektorat\\sgml\\autoren\\bearb",
		"sic", 	"sic",
	);
	return (%myopt);
}

##---Ausgabe der Optionen mit Formular zum Bearbeiten und Speichern--------------------------------------------------
sub ausgabeopt {
## Parameter: Optionen (Hash)

## - welche Optionen?
##   - Arbeitsverzeichnis
##   - Dateiname
##   - ID
##   - Zielverzeichnis

	local (%myopt) = @_;
	local ($k,$v);
	local ($taste,$rest);

	print "<form action=\"optaend.pl\">\n";
	print "<fieldset id=\"optionen\">\n";
	print "<legend>Optionen</legend>\n";
	print "<table border=\"0\">\n";
	foreach $k (sort(keys(%myopt))) {
		$taste = substr($k, 0, 1);
		#$taste = "\U$taste";
		$rest = substr($k, 1);
		print "<tr><td><u>\u$taste</u>$rest: </td>\n\t<td>", &webtag("input","type=text\tname=$k\tvalue=$myopt{$k}\tsize=40\taccesskey=$taste","#EMPTY#") , "</td>\n\t<td>&nbsp; $rem{$k}</td></tr>\n";
	}
	print "<tr><td> </td><td>", &webtag("input","type=submit\tvalue=\xC4ndern","#EMPTY#") , "</td></tr>\n";
	print "</table>\n";
	print "</fieldset>\n";
	print "</form>\n";

	return (1);
}

#---Kommentare lesen-------------------------------------------
#-- 21.09.2005

sub holrem {
#---Parameter: keine
#-- Rueckgabe: Kommentare (Hash)
	local (@par) = @_;
	local ($k,$v,%myrem);
	## falls %rem schon ausserhalb festgelegt war
	%myrem = %rem;

	local $remdat = "rem.txt";
	if (!(-f $remdat)) {
		&webfehler ("holrem: Kommentardatei [$remdat] nicht vorhanden! $globals{'adminmes'}\n");
		return;
	}

	#-- Kommentare-Datei
	open (REMARK, $remdat) || &webabbruch("Kann Konfigurationsdatei [$remdat] nicht lesen!\n");
	while ($z = <REMARK>) {
		chop ($z) if ($z =~ m/\n$/i);
	    #-- leere Zeile und Kommentar
	    if (($z !~ m/^[ \t]*$/i) && ($z !~ m/^[ \t]*\#/i)) {
			if ($z =~ m/\t/i) {
				($k,$v) = split(/\t/, $z, 2);
			} else {
				$k = $z;
				$v = undef();
			}
			#-- Kleinschreibung bei Key
			$k = "\l$k";
			if (defined($myrem{$k})) {
				#-- ist die Unterscheidung nach defined und $myrem{$k} noetig?
				if ($myrem{$k}) {
					if ($v) {
						$myrem{$k} .= "\t$v";
					}
				} else {
					if ($v) {
						$myrem{$k} = "$v";
					}
				}
			} else {
				$myrem{$k} = "$v";
			}
	    }  #-- of is Kommentar or leere Zeile
	}
	close (REMARK);

	return(%myrem);	
}


#---DTD holen-------------------------------------------
sub holdtd {    
## uebernommen von holdtd.pl
local ($von,$nach,$quiet) = @_;
local ($ubmn, $ubmq, $ubmz, $z, @dtd, $anz, $orgein, $i, $f, $temp);

	if (! ($nach)) {
		&webabbruch("holdtd: Quell-Verzeichnis und/oder Ziel-Verzeichnis fehlt.");
	}
	
	$ubmn = 'ubm.dtd';
	$ubmq = "$von$slash$ubmn";
	$ubmz = "$nach$slash$ubmn";
	
	@dtd = ();
	
	if (! $quiet) {&webhinweis ( "Hole ubm.dtd " . &hinterlegt($ubmq) );}
	
	open (Q, $ubmq) || &webabbruch( "Kann Quelle [$ubmq] nicht lesen!" );
	open (Z, ">$ubmz") || &webabbruch( "Kann Ziel [$ubmz] nicht schreiben!" );
	
	while ($z = <Q>) {
		if ($z =~ m|<!ENTITY %      ([^ \.]+\.dtd)|i) {
			push (@dtd, $1);
		}
		print Z $z;
	}
	
	close (Q);
	close (Z);
	
	$anz = $#dtd + 1;
	if (! $quiet) {&webhinweis( "Gefunden: [" . &hinterlegt($anz) . "] DTD's; Hole DTD's ...");}
	
	$orgein = $/;
	undef ($/);
	$i = 0;
	foreach $f (@dtd) {
		$i++;
		#print "\r  $i  ";
		open (Q, "$von$slash$f") || &webabbruch( "Kann DTD [$von$slash$f] nicht lesen!"); 
		$temp = <Q>;
		close (Q);
		open (Z, ">$nach$slash$f") || &webabbruch( "Kann DTD [$nach$slash$f] nicht schreiben!"); 
		print Z $temp;
		close (Z);
	}
	$/ = $orgein;

	if (! $quiet) {&webhinweis ("DTD " .&hinterlegt($anz). " geholt von " . &hinterlegt($von) . " und gespeichert in " . &hinterlegt($nach));}
	return ($anz);
}


#---eine Phrase als hinterlegt ausgeben-------------------------------------------
sub hinterlegt {    
## uebernommen von holdtd.pl
local ($text) = $_[0];

	return (&webtag ("em", "class=hinterlegt", $text));
}


#---einen Wert einer Variable als INPUT ausgeben-------------------------------------------
sub inputfeld {    
local ($nam,$val,$siz) = @_;

	if (! defined($val)) {
		&webabbruch("inputfeld: Variablenname und/oder Wert fehlt.");
	}
	if ($siz) {
		return (&webtag("input", "name=$nam\ttype=text\tvalue=$val\tsize=$siz", "#EMPTY#"));
	} else {
		return (&webtag("input", "name=$nam\ttype=text\tvalue=$val", "#EMPTY#"));
	}
}


#---einen Wert einer mehrzeiligen Variable als TEAXTAREA ausgeben-------------------------------------------
sub inputarea {    
local ($nam,$val,$width,$height) = @_;

	if (! defined($val)) {
		&webabbruch("inputarea: Variablenname und/oder Wert fehlt.");
	}
	if ($height) {
		return (&webtag("textarea", "name=$nam\tcols=$width\trows=$height", $val));
	} elsif ($width) {
		return (&webtag("textarea", "name=$nam\tcols=$width", $val));
	} else {
		return (&webtag("textarea", "name=$nam", $val));
	}
}

#---einen Wert einer Variable als readonly INPUT ausgeben-------------------------------------------
sub rofeld {    
local ($nam,$val,$siz) = @_;

	if (! ($val)) {
		&webabbruch("rofeld: Variablenname und/oder Wert fehlt.");
	}
	if ($siz) {
		return (&webtag("input", "name=$nam\ttype=text\tvalue=$val\treadonly=readonly\tsize=$siz", "#EMPTY#"));
	} else {
		return (&webtag("input", "name=$nam\ttype=text\tvalue=$val\treadonly=readonly", "#EMPTY#"));
	}
}


#---einen Wert einer mehrzeiligen Variable als readonly TEAXTAREA ausgeben-------------------------------------------
sub roarea {    
local ($nam,$val,$width,$height) = @_;

	if (! ($val)) {
		&webabbruch("roarea: Variablenname und/oder Wert fehlt.");
	}
	if ($height) {
		return (&webtag("textarea", "name=$nam\treadonly=readonly\tcols=$width\trows=$height", $val));
	} elsif ($width) {
		return (&webtag("textarea", "name=$nam\treadonly=readonly\tcols=$width", $val));
	} else {
		return (&webtag("textarea", "name=$nam\treadonly=readonly", $val));
	}
}



#---globale Variablen festlegen-------------------------------------------
sub getglobals {    
#	local ($breit, $breitkurz, $breitlang, $breitfeld, $hoch) = (20, 5, 40, 50, 8);
#	if ($globals{"breit"    }) { $breit     = $globals{"breit"    }; }
#	if ($globals{"breitkurz"}) { $breitkurz = $globals{"breitkurz"}; }
#	if ($globals{"breitlang"}) { $breitlang = $globals{"breitlang"}; }
#	if ($globals{"breitfeld"}) { $breitfeld = $globals{"breitfeld"}; }
#	if ($globals{"hoch"     }) { $hoch      = $globals{"hoch"     }; }
local %meine = (
	"admin",	"Thomas Hofmann",
	"admintel",	"1573",
	"adminmail",	"thomas.hofmann\@draexlmaier.com",
	"parsdir",	"D:\\Inetpub\\wwwroot\\sich\\markup\\opt\\sgmls",
	"dtddir",	"D:\\Inetpub\\wwwroot\\sich\\markup\\opt\\dtd",
	"dtdhome",	"D:\\Inetpub\\wwwroot\\sich\\markup\\opt\\dtd\\home",
	"faq-tit",	"faq-tit.dat",
	"faq-kat",	"faq-kat.dat",
	"faq-inh",	"faq-inh.dat",
	## geht nicht einzeln, da ich sonst nicht Benutzername Passwort abfragen kann
	#"kateditformtype", "einzeln",
	"kateditformtype", "alles",
	"breit"     ,   "20",
	"breitkurz" ,   "5",
	"breitlang" ,   "40",
	"breitfeld" ,   "75",
	"hoch"      ,   "10",
	"breittiny" ,   "18",
	"i18n_conf" ,   "faq_i18n.conf",
	"i18n_lang" ,	"DE",
	);
$meine{"adminmes"} = "Bitte informieren Sie $meine{'admin'} (Tel. $meine{'admintel'}).";

return (%meine);
}

#---wichtige Userdaten ausgeben-------------------------------------------
sub userdaten {    
	local ($anhaengen) = $_[0];
	local ($ud) = <<userdatenENDE;
	<form action="userdaten.pl">
	<fieldset id="userdaten">
	<legend>User-Daten</legend>
userdatenENDE
	$ud .=
	&webtag (
		"p","IP:&nbsp;" . 
		&rofeld("ip", $remote_addr) .
		"\n\t Optionsdatei:&nbsp;"  .
		&rofeld("optdat", $optdat) .
		$anhaengen .
		""
		);
	$ud .= <<userdatenEND2;
	</fieldset>
	</form>
userdatenEND2
	return ($ud);
}

#---Head fuer UB MEDIA CGI-Anwendungen-------------------------------------------
## erweiterter PrintHeader aus cgi-lib
## ergaenzen um: 
## - sofortiger Verfall
## - Stylesheet
## - Doctype
## - Content-Type wegen Zeichensatz  

sub UbmCgiHead {
## Uebergabe: Zeichenkette fuer TITLE und H1
	local ($head) = $_[0];
	local ($temp);
	if (! $head) { &webabbruch("UbmCgiHead: Kein Titel \xFCbergeben."); }
	$head = &HtmlTop($head);
	## Markup im Title entfernen
	if ( $head =~ m|<title>(.*?)<\/title>|i ) {
		$temp = $1;
		$temp =~ s|<[^>]+>||ig;
		$head =~ s|(<title>).*?(<\/title>)|$1$temp$2|i
	}
	## Doctype einfuegen
	$head =~ s|(<html>)|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">\n$1|i;
	## Charset
	$head =~ s|(<head>)|$1\n<META http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">|i;
	## Styles
	$head =~ s|(<\/head>)|\n<link rel=\"stylesheet\" type=\"text/css\" href=\"ubmintra.css\">\n$1|i;
	## Cache auf 0 setzen
	$head =~ s|(<\/head>)|\n<meta http-equiv=\"expires\" content=\"0\">\n$1|i;
	return ($head);
}


#---holen einer SGM-Datei vom Datenpool ins Bearbeitungsverzeichnis-------------------------------------------
sub holeSGM {
	## sollte ich Sicherungen einbauen?
	## siehe dazu auch sub sichereSGM
	## 	kann nur holen, wenn nicht selbst in Bearbeitung (nicht selbst in bearb)
	## 	kann nur holen, wenn nicht von jemand anders in Bearbeitung (Schreibschutz im Pool)
	## 	bei Holen im Pool ins Unterverz. opt{sic} kopieren
	## 	bei Holen im Pool Schreibschutz setzen
	## 	holen (lesen und in bearb schreiben
	## 	nach Bearbeitung im bearb ins Unterverz. opt{sic} kopieren
	## 	nach Bearbeitung im Pool Schreibschutz loeschen
	## 	sichern im Pool
	## 	nach sichern in bearb loeschen
	local ($sgm) = $opt{'datei'};
	local ($bearb, $ziel, $orgein, $sgminhalt) = ("", "", $/, "");

	if ( (!(defined($sgm))) || ($sgm eq "")) { 
		&webabbruch("Fehler in Name SGM-Datei: [" . &hinterlegt($sgm) . "]");
	}
	$sgm .= ".sgm";
	$bearb = $opt{"bearb"} . "$slash$sgm";
	$ziel  = $opt{"ziel"}  . "$slash$sgm";
	$bearbsic = "$opt{'bearb'}$slash$opt{'sic'}$slash$sgm";
	$zielsic  = "$opt{'ziel'}$slash$opt{'sic'}$slash$sgm";
	if (!(-f $ziel)) {
		&webabbruch("SGM-Datei im Pool nicht vorhanden: [" . &hinterlegt($ziel) . "]");
	}

	## soll ich erst auf Schreibschutz testen?
	## damit koennte man die Datei im Pool als in Bearbeitung kennzeichnen
	## siehe Kommentar bei sichern

	## 	kann nur holen, wenn nicht selbst in Bearbeitung (nicht selbst in bearb)
	if (-f $bearb) {
		&webabbruch("SGM-Datei bereits in Bearbeitung (in bearb vorhanden): [" . &hinterlegt($bearb) . "]");
	}

	## 	kann nur holen, wenn nicht von jemand anders in Bearbeitung (Schreibschutz im Pool)
	#($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)
	@allstat = stat($ziel);

#	($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = @allstat;
#	@allstat = (
#		"dev    =". $dev,
#		"ino    =". $ino    ,
#		"mode   =". $mode   ,
#		"nlink  =". $nlink  ,
#		"uid    =". $uid    ,
#		"gid    =". $gid    ,
#		"rdev   =". $rdev   ,
#		"size   =". $size   ,
#		"atime  =". $atime  ,
#		"mtime  =". $mtime  ,
#		"ctime  =". $ctime  ,
#		"blksize=". $blksize,
#		"blocks =". $blocks ,
#		);
#	if (-w _) { push (@allstat, "writeable=Ja"); }
#	else { push (@allstat, "writeable=Nein"); }
#$temp = join("\n", @allstat);
#print &roarea("stat", $temp, 40, 10);

	if (!(-w _)) { 
		&webabbruch("SGM-Datei bereits in Bearbeitung (Pool hat Schreibschutz): [" . &hinterlegt($ziel) . "]");
	}


	if (!(open (SGM, $ziel))) {
		&webabbruch("Kann SGM-Datei im Pool nicht lesen: [" . &hinterlegt($ziel) . "]");
	}
	undef($/);
	$sgminhalt = <SGM>;
	close (SGM);
	$/ = $orgein;

	## 	bei Holen im Pool ins Unterverz. opt{sic} kopieren
	if (!(open (SGM, ">$zielsic"))) {
		&webabbruch("Kann SGM-Datei im Pool nicht sichern: [" . &hinterlegt($zielsic) . "]");
	}
	print SGM $sgminhalt;
	close (SGM);

	## 	bei Holen im Pool Schreibschutz setzen
	if (!(chmod ( 0444, $ziel))) {
#	if (!(chmod ( 0744, "c:\\temp\\bloedsinn.txt"))) {
		&webabbruch("Kann SGM-Datei im Pool nicht sch\xFCtzen: [" . &hinterlegt($ziel) . "]");
	}

	## 	holen (lesen und in bearb schreiben

	if (!(open (SGM, ">$bearb"))) {
		&webabbruch("Kann SGM-Datei in Bearb nicht schreiben: [" . &hinterlegt($bearb) . "]");
	}
	print SGM $sgminhalt;
	close (SGM);
	&webhinweis("SGM-Datei nach Bearb geholt: [" . &hinterlegt($bearb) . "]");

	return ($sgm);
}


#---Sichern einer SGM-Datei vom Bearbeitungsverzeichnis im Datenpool-------------------------------------------
sub sichereSGM {
	## sollte ich Sicherungen einbauen?
	## siehe dazu auch sub holeSGM
	local ($sgm) = $opt{'datei'};
	local ($bearb, $ziel, $orgein, $sgminhalt) = ("", "", $/, "");

	if ( (!(defined($sgm))) || ($sgm eq "")) { 
		&webabbruch("Fehler in Name SGM-Datei: [" . &hinterlegt($sgm) . "]");
	}
	$sgm .= ".sgm";
	$bearb = $opt{"bearb"} . "$slash$sgm";
	$ziel  = $opt{"ziel"}  . "$slash$sgm";
	$bearbsic = "$opt{'bearb'}$slash$opt{'sic'}$slash$sgm";
	$zielsic  = "$opt{'ziel'}$slash$opt{'sic'}$slash$sgm";
	if (!(-f $bearb)) {
		&webabbruch("SGM-Datei in Bearb nicht vorhanden: [" . &hinterlegt($bearb) . "]");
	}
	## soll ich erst auf Schreibschutz testen?
	## damit koennte man die Datei im Pool als in Bearbeitung kennzeichnen
	## AH am 27.09.2005: 
	## 	sinngemaess: "Holen und Sichern im Pool ist nicht noetig, steckt schon in GAG Autoren."
	## 	Das ist natuerlich Quatsch.
	## 	Wie ist es? von der GAG wird beim Holen eine Sicherung in F:\Lektorat\SGML\AUTOREN\SICHER angelegt.


	if (!(open (SGM, $bearb))) {
		&webabbruch("Kann SGM-Datei in Bearb nicht lesen: [" . &hinterlegt($bearb) . "]");
	}
	undef($/);
	$sgminhalt = <SGM>;
	close (SGM);
	$/ = $orgein;

	## 	nach Bearbeitung im bearb ins Unterverz. opt{sic} kopieren
	if (!(open (SGM, ">$bearbsic"))) {
		&webabbruch("Kann SGM-Datei in bearb nicht sichern: [" . &hinterlegt($bearbsic) . "]");
	}
	print SGM $sgminhalt;
	close (SGM);

	## 	nach Bearbeitung im Pool Schreibschutz loeschen
	if (!(chmod ( 0666, $ziel))) {
#	if (!(chmod ( 0666, "c:\\temp\\bloedsinn.txt"))) {
		&webabbruch("Kann Schutz SGM-Datei im Pool nicht aufheben: [" . &hinterlegt($ziel) . "]");
	}

	## 	sichern im Pool
	if (!(open (SGM, ">$ziel"))) {
		&webabbruch("Kann SGM-Datei im Pool nicht schreiben: [" . &hinterlegt($ziel) . "]");
	}
	print SGM $sgminhalt;
	close (SGM);
	&webhinweis("SGM-Datei in den Pool gesichert: [" . &hinterlegt($ziel) . "]");

	## 	nach sichern in bearb loeschen
	if (!(unlink ($bearb))) {
		&webabbruch("Kann Kopie SGM-Datei in bearb nicht l\xF6schen: [" . &hinterlegt($bearb) . "]");
	}

	return ($sgm);
}

#---Holen der Spracheinstellungen-------------------------------------------
sub getI18n {
	local (*lang, *conf, @rest) = @_;
	# 3 things to do:
	# 	a) get language from i18n_conf
	# 	b) get words from i18n_lang_{lang}
	# 	c) get the other languages as list from the i18n_lang_{lang} files
	# 	d) set encoding from lang-file

	# 	a) get language from i18n_conf
	if ( !(-f $conf) ) {
		webabbruch ("Spracheinstellungs-Datei nicht gefunden [$conf]. $globals{'adminmes'}");
	}
	if ( !(open (LANGCONF, $conf) ) ) {
		webabbruch ("Kann Spracheinstellungs-Datei nicht lesen [$conf]. $globals{'adminmes'}");
	}
	@f = %f = ();
		@f = <LANGCONF>;
		close (LANGCONF);
	$lang = $f[0];
	chomp( $lang );

	# 	b) get words from i18n_lang_{lang}
	my $lang_name = $conf;
	$lang_name =~ s/(\.conf)$/-$lang$1/;
	#webhinweis("\$lang: $lang -- \$lang_name: $lang_name");

	if ( !(-f $lang_name) ) {
		webabbruch ("Sprach-Datei nicht gefunden [$lang_name]. $globals{'adminmes'}");
	}
	if ( !(open (LANGDICT, $lang_name) ) ) {
		webabbruch ("Kann Sprach-Datei nicht lesen [$lang_name]. $globals{'adminmes'}");
	}
	@f = %f = ();
	$isUTF8 = '';

	if( $lang =~ m/^DE$/i ) { $f{'FAQ'} = 'FAQ'; }  ## avoid a error message in case of lang == DE
	my @fdest =();  ## array for extra saving keys in right followship

		@f = <LANGDICT>;
		close (LANGDICT);
		everylinelang:
		foreach $z (@f) {
			# Attention: if the file is UTF-8 then in begins with the 3 chars for xEFxBBxBF 
			
			chomp( $z );
			if ( $z =~ m/^\xEF\xBB\xBF/ ) { $z = substr( $z, 3 ); $isUTF8 = 1; }
			if ($z =~ m/^[ \t]*#/i) { next everylinelang; }
			$z =~ s/\\=/__equals__/g;
			if ($z !~ m/^.+=.+$/i) { next everylinelang; }
			( $k, $v ) = split( /=/, $z, 2 );
			$k =~ s/__equals__/=/g;
			$v =~ s/__equals__/=/g;
			push( @fdest, $k );  ## saving keys in right followship in extra array
			$f{$k} = $v;
		}
		
		$count = keys( %f );
		if ( $count == 0 && $lang eq "DE" ) {
			$count++;
			%f = { 'FAQ' => 'Faq' };
		}
		if ( $count == 0 ) {
			&webabbruch ("Sprach-Datei ist leer [$lang_name]. $globals{'adminmes'}");
		}

		@lang = @fdest;
		%lang = %f;

	# 	c) get the other languages as list from the i18n_lang_{lang} files
	my $lang_dir = '.';
	opendir( DIR, $lang_dir ) || &webabbruch ("Kann Konfigurationsverzeichnis nicht lesen. [$lang_dir]. $globals{'adminmes'}");
	my @dirent = readdir( DIR );
	closedir( DIR );
	@langs = ();
	my $lang_name_pos = index( $globals{ 'i18n_conf' }, '.conf' );
	my $lang_name_begin = substr( $globals{ 'i18n_conf' }, 0, $lang_name_pos );
	#webhinweis("\$lang_name_begin: $lang_name_begin -- \$globals{ 'i18n_conf' }: $globals{'i18n_conf'}");
	foreach my $dirent ( @dirent ) {
		chomp( $dirent );
		if ( $dirent =~ m/$lang_name_begin\-([^\.]+)\.conf/ ) {
			push( @langs, $1 );
		}
	}
	#webhinweis("\@langs: " . join( '--', @langs ) );

	# 	d) set encoding from lang-file
	if( $isUTF8 ) { $encoding = 'UTF-8'; }
	if( $lang{'__encoding__'} ) { $encoding = $lang{'__encoding__'}; }
#	print "\n<p> __encoding__ <input type=\"text\" readonly=\"readonly\" value=\"$encoding\" />\n";
#	print "\n<p> lang{__encoding__} <input type=\"text\" readonly=\"readonly\" value=\"". $lang{'__encoding__'} ."\" />\n";
#	print "\n<pre>\n";
#	printHash( %lang );
#	print "\n</pre>\n";

	return(1);
}

#---Holen der Daten der FAQ-------------------------------------------
sub holfaq {
	local (*kat, *tit, *inh, *nrkat) = @_;
	my (@datei) = ($kat, $tit, $inh);
	my ($d, $i, @f, %f, $z, $k, $v, $t, $ke, $va);
	
	#webhinweis( "IN holfaq: [kat/tit/inh]: [$kat/$tit/$inh]" );
	foreach $d (@datei) {
		if ( !(-f $d) ) {
			webabbruch ("Datei nicht gefunden [$d]. $globals{'adminmes'}");
		}
	}
	
	## noch pruefen, ob man sie oeffnen kann? oder einzeln in den Modulen pruefen?
	for ($i=0; $i<3; $i++) {
		@f = %f = ();
		if ( !(open (DAT, $datei[$i]) ) ) {
			webabbruch ("Kann Datei nicht lesen [$datei[$i]]. $globals{'adminmes'}");
		}
		@f = <DAT>;
		close (DAT);
		jedezeileholfaq:
		foreach $z (@f) {
			if ($z =~ m/\n$/i) { chop($z); }
			## hier besser kein Match, 
			## in ftit sind drei Felder, er koennte die beiden ersten zusammen fassen
			## besser split
			if ($z !~ m/^.+\t.+$/i) { next jedezeileholfaq; }
			($k,$v) = split(/\t/,$z, 2);
			$f{$k} = $v;
		}
		
		$t = keys(%f);
		if ($t == 0) {
			&webabbruch ("Datei ist leer [$datei[$i]]. $globals{'adminmes'}");
		}
		if ($i==0) {  ## kat
			@kat = @f;
			%kat = %f;
		}
		elsif ($i==1) {  ## tit
		## Achtung, value enthaelt zwei Felder!
			## faq-tit
			## 	FAQNr, KatNr, Titel der Frage
			## 		aus dieser Datei muss ich 2 Felder machen: 
			## 		ftit fuer FAQNr, Titel der Frage
			## 		fnrkat fuer FAQNr, KatNr
			@tit = @f;
			%tit = %f;
			while (($ke, $va) = each %tit) {
				($k, $v) = split(/\t/,$va, 2);
				$nrkat{$ke} = $k;
				$tit{$ke} = $v;
			}
		}
		else {  ## inh
		## i sollte jetzt 2 sein
			@inh = @f;
			%inh = %f;
		}
	}
	return(1);
}


#---Ausgabe der Kategorien der FAQ-------------------------------------------
sub ausgabekat {
	local ( $aktkat, $isedit, %ka ) = @_;
	my ( $k, $v, @ke, $t );
	my $aktkatsic = $aktkat;
#webhinweis("<b>IN</b> ausgabekat") if $debug;
	
	my ( $hasharray, @hasharray ) = ( undef, undef );
	my $hashcloud = undef;
	my $hashcloudsmall = undef;
	my %hashcloud;
	my %hashcloudsmall;
	if ( defined( $ka{ 'hashtags' } ) ) {
		$hasharray = $ka{ 'hashtags' };
		delete $ka{ 'hashtags' };
		@hasharray = @{ $hasharray };
	}
	if ( defined( $ka{ 'hashcloud' } ) ) {
		$hashcloud = $ka{ 'hashcloud' };
		delete $ka{ 'hashcloud' };
		%hashcloud = %{ $hashcloud };
	}
	if ( defined( $ka{ 'hashcloudsmall' } ) ) {
		$hashcloudsmall = $ka{ 'hashcloudsmall' };
		delete $ka{ 'hashcloudsmall' };
		%hashcloudsmall = %{ $hashcloudsmall };
	}

	my $sst = undef;
	if ( defined( $ka{ 'sst' } ) ) {
		$sst = $ka{ 'sst' };
		delete $ka{ 'sst' };
	}
	if ( !$sst ) { $sst = ''; }

#webhinweis("<b>sort keys \%ka</b> before") if $debug;
	@ke = sort{$a <=> $b} (keys (%ka) );
#webhinweis("<b>sort keys \%ka</b> after") if $debug;

	if (($aktkat eq "") || !defined($aktkat)) { $aktkat=1; }
	print webtag("div", "class=katwahl", "#EMPTY#");
	if ($isedit) {
	    print webtag("h3", "class=katwahltit", trans("Kategorien") . " <br>" . webtag("small",weblink( trans("[zur\xFCck zu den FAQ]"),"faq.pl?kat=$aktkat")) );
	} else {  ## normal nicht edit
	    print webtag("h3", "class=katwahltit", trans("Kategorien") . " <br>" . webtag("small",weblink( trans("[EDIT]"),"editfaqkat.pl")) );
	}
	#print webtag("p", weblink("[EDIT]","editfaqkat.pl"));
	#print webtag("blah");
	print webtag("ol", "type=1", "#EMPTY#");

#webhinweis("<b>foreach \$k</b> before") if $debug;
	foreach $k (@ke) {
		if ($aktkat eq $k) {
			#$t = webtag("b", &weblink("$ka{$k}", "faq.pl?kat=$k"));
			print webtag("li", "value=$k", webtag("b", "*$ka{$k}*") );
		} else {
		    if ($isedit) {
				print webtag("li", "value=$k", weblink("$ka{$k}", "editfaq.pl?kat=$k") );
		    } else {  ## normal nicht edit
				print webtag("li", "value=$k", weblink("$ka{$k}", "faq.pl?kat=$k") );
		    }
		}
	}
#webhinweis("<b>foreach \$k</b> after") if $debug;

	print webtag("ol", "", "#ENDETAG#");

	#if (($aktkat eq "") || !defined($aktkat)) { $aktkatsic = 'alle'; }
	ausgabesearchbox( $aktkatsic, '', $sst );
#webhinweis("<b>ausgabesearchbox</b> after") if $debug;
	
	#webhinweis( "\$0: $0" );
	my $scriptname = getfilename( $0 );
#	webhinweis( "\$0 : $0 " );
#	webhinweis( "\$scriptname : $scriptname " );
	#webhinweis( "scriptname: $scriptname" );
	if ( !$toedit && $input{ 'toedit' } ) { $toedit = $input{ 'toedit' }; }
	if ( !$toedit ) { $toedit = ''; }
	#webhinweis( "toedit / input{toedit}: $toedit / $input{toedit}" );
#webhinweis( "<b>if ! \$hash...</b> before" ) if $debug;
	if ( !$hasharray || !$hashcloud || !$hashcloudsmall ) {
		my $sicsst = $sst; if ( !defined( $sicsst ) ) { $sicsst = ''; }
		$sicsst =~ s/\#/\%23/i;
		print '&nbsp;' . webtag( "small", '#EMPTY#' );
		print weblink( "Hashtags","$scriptname?kat=$aktkat\&hashtags=on\&sst=$sicsst\&toedit=$toedit" ) if !$hasharray;
		print ' - ' if ( !$hasharray && !$hashcloud );
		print weblink( "Hashcloud","$scriptname?kat=$aktkat\&hashcloud=on\&sst=$sicsst\&toedit=$toedit" ) if !$hashcloud;
		print ' - ' if ( ( !$hasharray || !$hashcloud ) && !$hashcloudsmall );
		print weblink( "HashcloudSmall","$scriptname?kat=$aktkat\&hashcloudsmall=on\&sst=$sicsst\&toedit=$toedit" ) if !$hashcloudsmall;
		print            webtag( "small", '#ENDETAG#' );
	}
#webhinweis( "<b>if ! \$hash...</b> after" ) if $debug;

#webhinweis( "<b>gethashtagsblock</b> before" ) if $debug;
	print gethashtagsblock( $hasharray );
#webhinweis( "<b>gethashtagsblock</b> after" ) if $debug;

#webhinweis( "<b>gethashtagcloud</b> before" ) if $debug;
	print gethashtagcloud( $hashcloud );
#webhinweis( "<b>gethashtagcloud</b> after" ) if $debug;

#webhinweis( "<b>gethashtagcloudsmall</b> before" ) if $debug;
	print gethashtagcloudsmall( $hashcloudsmall );
#webhinweis( "<b>gethashtagcloudsmall</b> after" ) if $debug;
	
	print webtag("div", "", "#ENDETAG#");  ## of class=katwahl
#webhinweis("<b>IN</b> ausgabekat <b>ENDE</b>") if $debug;

}

#---Ausgabe der Fragen der aktuellen Kategorie-------------------------------------------
#ausgabefaq($aktkat, *fkat, *ftit, *finh, *fnrkat);
sub ausgabefaq {
	local ($akat, $isedit, *kat, *tit, *inh, *nrkat) = @_;
	local (@fke) = sort{$a <=> $b}(keys(%nrkat));
	local (@aktfaq) = ();
	local ($k, $temp);

	my $scriptname = getfilename( $0 );

	## actions for spoiler
	our $spoileridx = 1;

	#webhinweis( "aktkat in ausgabefaq: [$aktkat]" );
	#webhinweis( "scriptname in ausgabefaq: [$scriptname]" );
	
	## erst Liste der Fragen ausgeben mit Links zu den Fragen unten
	## dabei schon eine Liste der FAQ merken, die der Kategorie entsprechen
	## zum Schluss die FAQ ausgeben
	print webtag("div", "class=faq", "#EMPTY#");

	print webtag("div", "class=faqfragen", "#EMPTY#");
	if ($isedit) {
	    print webtag("h3", "class=faqfragtit", webtag("a","name=fragen",trans("Fragen")) . trans(" zum Thema: ")."''$kat{$aktkat}'' " . webtag("small",weblink(trans("[zur\xFCck zu den FAQ]"),"faq.pl?kat=$aktkat"))  . " " . webtag("small",weblink(trans("[alle Kategorien]"),"editfaq.pl?kat=alle")) );
	} else {  ## normal nicht edit
	    print webtag("h3", "class=faqfragtit", webtag("a","name=fragen",trans("Fragen")) . trans(" zum Thema: ")."''$kat{$aktkat}'' " . webtag("small",weblink(trans("[EDIT]"),"editfaq.pl?kat=$aktkat")) . " " . webtag("small",weblink(trans("[alle Kategorien]"),"faq.pl?kat=alle")) );
	}
	print webtag("ol", "type=1", "#EMPTY#");
	foreach $k (@fke) {
		if ($nrkat{$k} eq $akat) {
			push (@aktfaq, $k);
			print webtag("li", "value=$k", weblink("$tit{$k}", "#faq$k") );
		} elsif ($akat eq "alle") {
			push (@aktfaq, $k);
			print webtag("li", "value=$k", weblink("$tit{$k}", "#faq$k") );
		}
	}
	if ($#aktfaq < 0) {
		if ($isedit) {
			print webtag("a", "href=faqedit.pl?fnr=neu\&kat=$aktkat\tclass=faqtitedit", trans("[neue Frage]"));
		}
		webhinweis(trans("Keine FAQ in dieser Kategorie"));
	}
	print webtag("ol", "", "#ENDETAG#");
	print webtag("div", "", "#ENDETAG#");
	  if ( !defined( $sicsst ) ) { $sicsst = ''; }
	  if ( !defined( $input{'hashtags'} ) ) { $input{'hashtags'} = ''; }
	  if ( !defined( $toedit ) ) { $toedit = ''; }
	if ($#aktfaq >= 0) {
		print webtag("div", "class=faqantworten", "#EMPTY#");
		if ($isedit) {
		    print webtag("h3", "class=editfaqanttit", trans("Antworten ") . webtag("a", "href=faqedit.pl?fnr=neu\&kat=$aktkat\tclass=faqtitedit", trans("[neue Frage]")));
		} else {
		    print webtag("h3", "class=faqanttit", trans("Antworten"));
		}
		print webtag("dl", "class=faqantwortencontent", "#EMPTY#");
		foreach $k (@aktfaq) {
			if ($isedit) {
			    if ($akat eq "alle") { 
			    	$temp = webtag("dt", 'class=faqantworthead' , webtag("a","name=faq$k", "$k\. $tit{$k} ") 
			    		. webtag("small", " (" 
			    			. weblink( trans("Kat. ") . $nrkat{$k}, "$scriptname?kat=$nrkat{$k}\&hashtags=$input{'hashtags'}\&sst=$sicsst\&toedit=$toedit\&onlypickedkat=1" ) 
			    			. ") ") 
			    		. webtag("a", "href=faqedit.pl?fnr=$k\tclass=faqtitedit", trans("[Edit]")) 
			    	);
			    } else {
			    	$temp = webtag("dt", 'class=faqantworthead' , webtag("a","name=faq$k", "$k\. $tit{$k} ") 
			    		. webtag("a", "href=faqedit.pl?fnr=$k\tclass=faqtitedit", trans("[Edit]")));
			    }
			    print $temp;
			} else {
			    if ($akat eq "alle") { 
			    	$temp = webtag("dt", 'class=faqantworthead' , webtag("a","name=faq$k", "$k\. $tit{$k}") 
			    		. webtag("small", 
			    			" (" 
			    			. weblink( trans("Kat. ") . $nrkat{$k}, "$scriptname?kat=$nrkat{$k}\&hashtags=$input{'hashtags'}\&sst=$sicsst\&toedit=$toedit\&onlypickedkat=1" ) 
			    			. ") "
			    		)
			    	);
			    } else {
			    	$temp = webtag("dt", 'class=faqantworthead' , webtag("a","name=faq$k", "$k\. $tit{$k}") );
			    }
			    print $temp;
			}
			print webtag("dd", faq2htm($inh{$k}) . "<br>" . webtag ("a", "href=#fragen\tclass=zufragen", trans("&uArr; zu den Fragen")) );
		}
		print webtag("dl", "", "#ENDETAG#");
		print webtag("div", "", "#ENDETAG#");
	}

	print webtag("div", "", "#ENDETAG#");
	
	return(1);
}

#---Ausgabe der Suchergebnisse der Fragen der aktuellen/aller Kategorie-------------------------------------------
#&ausgabefaq($aktkat, *fkat, *ftit, *finh, *fnrkat);
sub ausgabefaqfound {
	local ( $akat, $isedit, $sst, *kat, *tit, *inh, *nrkat ) = @_;
	my ( @fke ) = sort{$a <=> $b}(keys(%nrkat));
	my ( @aktfaq ) = ();
	my ( $k, $temp );
	my $foundbg = '#00ffff';
	my $countfound = 0;

	my $scriptname = getfilename( $0 );

	## actions for spoiler
	our $spoileridx = 1;

	#webhinweis( "scriptname in ausgabefaq: [$scriptname]" );
	#webhinweis( "sst in ausgabefaqfound: [$sst]" );
	#webhinweis( "IN ausgabefaqfound; akat: [$akat]" );
	
	## erst Liste der Fragen ausgeben mit Links zu den Fragen unten
	## dabei schon eine Liste der FAQ merken, die der Kategorie entsprechen
	## zum Schluss die FAQ ausgeben
	print webtag( "div", "class=faq", "#EMPTY#");

	print webtag( "div", "class=faqfragen", "#EMPTY#");
	if ($isedit) {
	    print webtag( "h3", "class=faqfragtit", 
	    	webtag( "a","name=fragen", trans("Fragen")) 
    		. trans(" zum Thema:") . " ''$kat{$aktkat}'' " 
    		. webtag( "small",
    			weblink( trans("[zur\xFCck zu den FAQ]"),"faq.pl?kat=$aktkat") ) 
    		. " " 
    		. webtag( "small", 
    			weblink( trans("[alle Kategorien]"),"editfaq.pl?kat=alle") ) 
	    );
	} else {  ## normal nicht edit
	    print webtag( "h3", "class=faqfragtit", 
	    	webtag( "a", "name=fragen", trans("Fragen")) 
	    	. trans(" zum Thema: ") . "''$kat{$aktkat}'' " 
	    	. webtag( "small", 
	    		weblink( trans("[EDIT]"), "editfaq.pl?kat=$aktkat") ) 
	    	. " " 
	    	. webtag( "small", 
	    		weblink( trans("[alle Kategorien]"),"faq.pl?kat=alle") ) 
	    );
	}

	webhinweis( trans("In Kategorie: ") . $akat . trans(" - Suche: ") . $sst );
	#webhinweis( "IN ausgabefaqfound; akat: [$akat]" );

	print webtag( "ol", "type=1", "#EMPTY#" );

	## erstmal fundstellen finden
	## dazu erstmal Parser des sst aufrufen
	#webhinweis( "vor parsesearch" );
	my @searchwords = parsesearch( $sst );
	#webhinweis( "searchwords: [".join(' - ', @searchwords)."] anzahl: ".($#searchwords + 1) );

	my $matched = undef;
	
	foreach $k (@fke) {
		if ($nrkat{$k} eq $akat) {
			#webfehler( "tit[$k]: $tit{$k}" ) if ( $k == 60 );
			#webfehler( "ismatch( tit[$k] ): " . ismatch( $tit{ $k } ) ) if ( $k == 60 );
			if( ismatch( $tit{ $k } .' '. $inh{ $k }, @searchwords ) ) {
				push (@aktfaq, $k);
				print webtag("li", "value=$k", weblink("$tit{$k}", "#faq$k") );
				$countfound++;
			}
		} elsif ($akat eq "alle") {
			if( ismatch( $tit{ $k } .' '. $inh{ $k }, @searchwords ) ) {
				push (@aktfaq, $k);
				print webtag("li", "value=$k", weblink("$tit{$k}", "#faq$k") );
				$countfound++;
			}
		}
	}
	if ($#aktfaq < 0) {
		if ($isedit) {
			print webtag("a", "href=faqedit.pl?fnr=neu\&kat=$aktkat\tclass=faqtitedit", trans("[neue Frage]"));
		}
		webhinweis(trans("Keine FAQ in dieser Kategorie"));
	}
	print webtag("ol", "", "#ENDETAG#");
	webhinweis( trans("Anzahl gefundene Eintr&auml;ge: $countfound") );
	print webtag("div", "", "#ENDETAG#");

	my $sicsst = $sst; if ( !defined( $sicsst ) ) { $sicsst = ''; }
	$sicsst =~ s/\#/\%23/g;

	my ( $titout, $inhout ) = ( undef, undef );
	if ($#aktfaq >= 0) {
		print webtag("div", "class=faqantworten", "#EMPTY#");
		if ($isedit) {
		    print webtag("h3", "class=editfaqanttit", trans("Antworten ") . webtag("a", "href=faqedit.pl?fnr=neu\&kat=$aktkat\tclass=faqtitedit", trans("[neue Frage]")));
		} else {
		    print webtag("h3", "class=faqanttit", trans("Antworten"));
		}
		print webtag("dl", "", "#EMPTY#");
		foreach $k (@aktfaq) {
			#webhinweis( $tit{$k} ) ;
			#webfehler( ismatch( $tit{$k}, (@searchwords, 'sonder') ) ) ;
			if ( !($titout = ismatch( $tit{$k}, @searchwords )) ) {
				$titout = $tit{$k};
			}
			if ($isedit) {
			    if ($akat =~ m/^alle|all$/) { 
			    	$temp = webtag("dt", webtag("a","name=faq$k", "$k\. " . $titout ) 
			    		. webtag("small", 
			    			" (" 
			    			. weblink( trans("Kat. $nrkat{$k}"), "$scriptname?kat=$nrkat{$k}\&hashtags=$input{'hashtags'}\&sst=$sicsst\&toedit=$toedit\&onlypickedkat=1" ) 
			    			. ") "
			    		)
			    		. webtag("a", "href=faqedit.pl?fnr=$k\tclass=faqtitedit", trans("[Edit]")) );
			    } else {
			    	$temp = webtag("dt", &webtag("a","name=faq$k", "$k\. " . $titout ) 
			    		. webtag("a", "href=faqedit.pl?fnr=$k\tclass=faqtitedit", trans("[Edit]")) );
			    }
			    print $temp;
			} else {
			    if ($akat eq "alle") { 
			    	$temp = webtag("dt", webtag("a","name=faq$k", "$k\. " . $titout )  
			    		. webtag("small", 
			    			" (" 
			    			. weblink( trans("Kat. $nrkat{$k}"), "$scriptname?kat=$nrkat{$k}\&hashtags=$input{'hashtags'}\&sst=$sicsst\&toedit=$toedit\&onlypickedkat=1" ) 
			    			. ") "
			    		)
			    	);
			    } else {
			    	$temp = webtag("dt", webtag("a","name=faq$k", "$k\. " . $titout ) );
			    }
			    print $temp;
			}
			$inhtemp = faq2htm($inh{$k}, $k);
			if ( !($inhout = ismatch( $inhtemp, @searchwords )) ) {
				$inhout = $inhtemp;
			}
			print webtag("dd", $inhout . "<br>" . webtag ("a", "href=#fragen\tclass=zufragen", trans("&uArr; zu den Fragen")) );
		}
		print webtag("dl", "", "#ENDETAG#");
		print webtag("div", "", "#ENDETAG#");
	}

	print webtag("div", "", "#ENDETAG#");
	
	return(1);
}
#---Ausgabe der Bearbeitung der FAQ-Kategorien-------------------------------------------
sub ausgabekatedit {
	local (*ka) = @_;
	local ($k, $v, @ke, $t, $katmax, @katfrei, @katnr, $i, $katneuende);
	local ($keft);
	local ($who);

	local ($breit, $breitkurz, $breitlang, $breitfeld, $hoch) = (20, 5, 40, 70, 20);
	if ($globals{"breit"    }) { $breit     = $globals{"breit"    }; }
	if ($globals{"breitkurz"}) { $breitkurz = $globals{"breitkurz"}; }
	if ($globals{"breitlang"}) { $breitlang = $globals{"breitlang"}; }
	if ($globals{"breitfeld"}) { $breitfeld = $globals{"breitfeld"}; }
	if ($globals{"hoch"     }) { $hoch      = $globals{"hoch"     }; }
	#($breitfeld, $hoch) 	= (100, 20);

	## sollte Benutzername/Passwort hier einbringen koennen

	## besser ein form ueber alles
	## 	problematisch, da viele Parameter entstehen, 
	## 	die erst noch verarbeitet werden muessen,
	## 	da ich oft die Nr. mit uebergebe
	## ich mache zwei Varianten im Quelltext
	## 	diese werden gekennzeichnet mit "form-alles" bzw. "form-einzeln"
	## 	eine davon ist auszuREMen
	## 	oder besser ueber globale Schaltervariable?
	## 		zunaechst steuerbar ueber globale Variable (getglobals) {'kateditformtype' = (einzeln|alles)}
	## 		es wird vorausgesetzt, dass getglobals im Hauptprogramm schon ausgefuehrt wurde
	if ($globals{"kateditformtype"}) {
		$keft = $globals{"kateditformtype"};
		#print &webtag("globals(kateditformtype)=$keft");
	} else {
		$keft = "einzeln";
		#print &webtag("kateditformtype(standard)=$keft");
	}

	## welche Kategorie-Nummern sind frei?
	## frei sind auch alle oberhalb der hoechsten Nummer
	$katmax = 1;
	#print &webtag("katmax vor Schleife: $katmax");
	@katfrei = ();
	@katnr = sort{$a <=> $b}(keys(%ka));
	## jetzt ist oben auf @katnr die groesste Zahl
	$katmax = $katnr[$#katnr];
	#print &webtag("katnr+1: " . ($#katnr+1));

	## von 1 bis zur hoechsten Nummer
	## Luecken entstehen nur durch Loeschen
	for ($i=1; $i<=$katmax; $i++) {
		#print &webtag("katmax VOR IF: $katmax");
		if (!defined($ka{$i})) {
			push(@katfrei,$i);
		}
	}
	#print &webtag("katmax nach Schleife: $katmax");
	$katneuende = $katmax + 1;
	push(@katfrei,trans("anf\xFCgen"));

	## besser ein form ueber alles
	if ($keft eq "alles") {
		## 	bei Passwortabfrage muss ich form auf method=post setzen, sonst ist es gleich umsonst, s.o.
		#print &webtag("form", "aktion=editfaqkat.pl", "#EMPTY#" );
		print &webtag("form", "aktion=editfaqkat.pl\tmethod=post", "#EMPTY#" );
	}

	print &webtag("div", "class=katedit", "#EMPTY#");
	## Benutzer eingeben
	## 	setzt voraus, dass form alles in einem gemacht wird
	## 	sonst muss es ohne Benutzer arbeiten, dann Kontrollzeile in editfaqkat.pl ausREMen
	## Noch ein Problem:
	## 	bei Passwortabfrage muss ich form auf method=post setzen, sonst ist es gleich umsonst, s.o.
	print &webtag("h3", "class=kateditchecktit", trans("Benutzer"));
	print &webtag("div", "class=kateditcheck", "#EMPTY#");
	        print &webtag("p","","#EMPTY#");
	        ## hier koennte man pruefen ob schon eingeloggt
	        ## s.a. ausgabefaqedit
	        ## 	wo wird das einloggen ausgewertet? - editfaqkat.pl
	        ## 	das geht weiter zu &isrightdate, 
	        ## 	dort koennte man auch eingeloggte Benutzer hinterlegen
		if ($who = &isdating(&whoamip)) {
			print trans("Name: ") , &rofeld("wer", $who, $breit), trans(" ist eingeloggt \&nbsp; ");
			print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("Logout"), "#EMPTY#" );
			#return($who);
		} else {
			print trans("Name: ") , &webtag("input", "type=text\tname=wer\tsize=$breit", "#EMPTY#" );
			print trans(" \&nbsp; Parole: ") , &webtag("input", "type=password\tname=womit\tsize=$breit", "#EMPTY#" );
		}
	        print &webtag("p","","#ENDETAG#");
	print &webtag("div", "", "#ENDETAG#");  ## kateditcheck

	print &webtag("h3", "class=katedittit", trans("Kategorien"));
	print &webtag("ol", "type=1", "#EMPTY#");

	foreach $k (@katnr) {
		print &webtag("li", "value=$k", "#EMPTY#" );
		if ($keft eq "alles") {
			print &webtag("input", "type=text\tname=kattit_$k\tvalue=$ka{$k}\tsize=$breitlang", "#EMPTY#" );
			#print &webtag("input", "type=hidden\tname=katnr\tvalue=$k", "#EMPTY#" );
			print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("\xC4ndern $k"), "#EMPTY#" );
			## dann ein Link zum Loeschen
			## 	ausser bei Kategorie 1, die darf man nicht loeschen
			if ($k != 1) {
				print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("L\xF6schen $k"), "#EMPTY#" );
			}
		} else {  ## keft eq 'einzeln'
			## erst ein form zum Aendern des Titels der Kat.
			print &webtag("form", "aktion=editfaqkat.pl", "#EMPTY#" );
			print &webtag("input", "type=text\tname=kattit\tvalue=$ka{$k}\tsize=$breitlang", "#EMPTY#" );
			print &webtag("input", "type=hidden\tname=katnr\tvalue=$k", "#EMPTY#" );
			print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("\xC4ndern"), "#EMPTY#" );
			print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("L\xF6schen"), "#EMPTY#" );
			print &webtag("form", "", "#ENDETAG#" );
		}
		print &webtag("li", "", "#ENDETAG#" );
	}
	
	print &webtag("ol", "", "#ENDETAG#");

	## dann ein Form zum Anlegen einer neuen Kat gleich mit Auswahl
	print &webtag("h3", "class=kateditneutit", trans("neue Kategorie"));
	print &webtag("div", "class=kateditneu", "#EMPTY#");
	if ($keft =~ m/einzeln|single/) {  ## != alles
		print &webtag("form", "aktion=editfaqkat.pl", "#EMPTY#" );
	}
	print &webtag("select", "name=neunr", "#EMPTY#" );
	foreach $v (@katfrei) {
		if ($v !~ m/anf\xFCgen|append/) {
			print &webtag("option", "", $v );
		} else {
			print &webtag("option", "value=$katneuende", trans($v) );
		}
	}
	print &webtag("select", "", "#ENDETAG#" );
	print &webtag("input", "type=text\tname=kattit\tsize=$breitlang", "#EMPTY#" );
	print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("Neu"), "#EMPTY#" );
	if ($keft eq "einzeln") {  ## != alles
		print &webtag("form", "", "#ENDETAG#" );
	}

	print &webtag("div", "", "#ENDETAG#");  ## kateditneu
	print &webtag("div", "", "#ENDETAG#");  ## katedit

	if ($keft eq "alles") {
		print &webtag("form", "", "#ENDETAG#" );
	}
}

#---Schreiben geaenderter Daten der FAQ-------------------------------------------
sub schreibfaq {
	local (*kat, *tit, *inh, *nrkat) = @_;
	local (@datei) = ($kat, $tit, $inh);
	local ($d, $i, @f, %f, $z, $k, $v, $t, $ke, $va);
	
	foreach $d (@datei) {
		if ( !(-f $d) ) {
			&webabbruch ("Datei nicht gefunden [$d]. $globals{'adminmes'}");
		}
	}
	
	## noch pruefen, ob man sie oeffnen kann? oder einzeln in den Modulen pruefen?
	for ($i=0; $i<3; $i++) {
		## die Arrays brauch ich hier nicht, nur die Hashes schreiben
		#@f = %f = ();
		%f = ();
		if ( !(open (DAT, ">$datei[$i]") ) ) {
			&webabbruch ("Kann Datei nicht schreiben [$datei[$i]]. $globals{'adminmes'}");
		}


		if ($i==0) {  ## kat
			%f = %kat;
		}
		elsif ($i==1) {  ## tit
		## Achtung, value enthaelt am Ende zwei Felder!
			## faq-tit
			## 	FAQNr, KatNr, Titel der Frage
			## 		in diese Datei muss ich bei value 2 Felder verknuepfen: 
			## 		nrkat tit (fuer "KatNr der FAQ" und "Titel der Frage")
			%f = %tit;
			while (($ke, $va) = each %f) {
				$t = $nrkat{$ke};
				$f{$ke} = join ("\t", $t, $va);
			}
		}
		else {  ## inh
		## i sollte jetzt 2 sein
			%f = %inh;
		}

		foreach $z (keys(%f)) {
			print DAT "$z\t$f{$z}\n";
		}


		close (DAT);
		
	}
	&webhinweis (trans("FAQ gesichert."));
	return(1);
}

#---Ausgabe der Bearbeitung einer Frage-------------------------------------------
sub ausgabefaqedit {
	local ($nr, *kat, *tit, *inh, *nrkat) = @_;
	local ($k, $v, @ke, $t, $katmax, @katfrei, @katnr, $i, $katneuende, @katvorh);
	local ($faqmax, @faqfrei, @faqnr, $faqneuende, @faqvorh);
	#local ($keft);
	local ($tempstring) = "";
	local ($who) = undef;
	
	#print "<p>_____ausgabefaqedit_____</p>\n"; 

	local ($breit, $breitkurz, $breitlang, $breitfeld, $hoch) = (20, 5, 40, 70, 20);
	if ($globals{"breit"    }) { $breit     = $globals{"breit"    }; }
	if ($globals{"breitkurz"}) { $breitkurz = $globals{"breitkurz"}; }
	if ($globals{"breitlang"}) { $breitlang = $globals{"breitlang"}; }
	if ($globals{"breitfeld"}) { $breitfeld = $globals{"breitfeld"}; }
	if ($globals{"hoch"     }) { $hoch      = $globals{"hoch"     }; }
	($breitfeld, $hoch) 	= (100, 20);

	## Problem:
	## 	welche Nr nehm ich bei "neu"?
	## 	muss ich aehnlich Kategorien erst die freien ermitteln?

	## sollte Benutzername/Passwort hier einbringen koennen

	## besser ein form ueber alles


	## Bearbeitungshinweise Pseudocode
	$phinweis=<<PSEUDOHINWEISENDE;
[link=linkziel]Linktitel[/link] - 
[linkx=(linkziel neues fenster)]Linktitel[/link] - 
[b]fett[/b] - 
[i]kursiv[/i] - 
[list] (->ul) - 
[*]  (->li) - 
[/list] (->/ul) - 
[list=1] (->ol) - 
[/list=1] (->/ol) - 
[list=a] (->ol mit typ) - 
[list=A] - 
[list=i] - 
[list=I] - 
[img=bildadresse] - 
[code]abc[/code] (->festbreitenschrift) - 
[quote]abc[/quote] (->blockquote)
PSEUDOHINWEISENDE
	$phinweis = trans($phinweis);	

	## welche Kategorie-Nummern sind frei?
	## frei sind auch alle oberhalb der hoechsten Nummer
	$katmax = 1;
	@katfrei = @katvorh = ();
	@katnr = sort{$a <=> $b}(keys(%kat));
	## jetzt ist oben auf @katnr die groesste Zahl
	#print &webtag( "p", "", "katnr_A: [" . join( '|', @katnr ) . "]" );
	#print &webtag( "p", "", "katnr_Imax: [$#katnr]" );
	
	$katmax = $katnr[$#katnr];
	#print &webtag( "p", "", "katmax: [$katmax]" );

	## hier muss ich an den Zweck denken.
	# 	der Benutzer sollte im Dropdown auch erkennen, wie die Kategogie heisst
	# 	also Titel der Kategorie dazu und mit value arbeiten

	## von 1 bis zur hoechsten Nummer
	## Luecken entstehen nur durch Loeschen
	for ($i=1; $i<=$katmax; $i++) {
		if (!defined($kat{$i})) {
			push(@katfrei,$i);
		} else {
			if ($i == $nrkat{$nr}) {
				push(@katvorh, "$i $kat{$i}\=$i\=selected");
			} elsif ( $nr =~ m/neu|new/ && $i == $aktkat ) {
				push(@katvorh, "$i $kat{$i}\=$i\=selected");
			} else {
				push(@katvorh, "$i $kat{$i}\=$i");
			}
		}
	}
	## ----------- debug
	## es wird bei "neu" anscheinend gar kein selected gesetzt => in diesem Fall auf aktkat setzen
#	my $katvorh = join( "\n", @katvorh );
#	$katvorh =~ s/</\&lt;/g;
#	print webtag( "textarea", "rows=6\tcols=60", $katvorh );
	## ----------- /debug
	$katneuende = $katmax + 1;
	## hier geht es nur um @katvorh
	push(@katfrei,trans("anf\xFCgen=$katneuende"));


	## welche FAQ-Nummern sind frei?
	## frei sind auch alle oberhalb der hoechsten Nummer
	$faqmax = 1;
	@faqfrei = @faqvorh = ();
	@faqnr = sort{$a <=> $b}(keys(%tit));
	my $faqnrjoin = join( '|', @faqnr );
	#print "<p>___faqnrjoin:[$faqnrjoin]___</p>\n";
	## jetzt ist oben auf @faqnr die groesste Zahl

	#print &webtag( "p", "", "faqnr_A: " . &rofeld( "faqnrjoin", $faqnrjoin ) );
	#print &webtag( "p", "", "faqnr_Imax: " . &rofeld( "faqnr_Imax", $#faqnr ) );

	$faqmax = $faqnr[$#faqnr];
	#print &webtag( "p", "", "faqmax: " . &rofeld( "faqmax_S", $faqmax ) );

	## von 1 bis zur hoechsten Nummer
	## Luecken entstehen nur durch Loeschen
	for ($i=1; $i<=$faqmax; $i++) {
		if (!defined($tit{$i})) {
			push(@faqfrei,$i);
		} else {
			if ($i == $nr) {
				push(@faqvorh, "$i\=selected");
			} else {
				push(@faqvorh, $i);
			}
		}
	}
	$faqneuende = $faqmax + 1;
	push(@faqfrei,trans("anf\xFCgen=$faqneuende"));


	print &webtag("form", "action=faqeditsic.pl\tmethod=post", "#EMPTY#" );

	print &webtag("div", "class=faqedit", "#EMPTY#");
	## Benutzer eingeben
	## 	setzt voraus, dass form alles in einem gemacht wird
	## 	sonst muss es ohne Benutzer arbeiten, dann Kontrollzeile in editfaqkat.pl ausREMen
	## Noch ein Problem:
	## 	bei Passwortabfrage muss ich form auf method=post setzen, sonst ist es gleich umsonst, s.o.
	print &webtag("h3", "class=faqeditchecktit", trans("Benutzer"));
	print &webtag("div", "class=faqeditcheck", "#EMPTY#");
	        print &webtag("p","","#EMPTY#");
	        ## hier koennte man pruefen ob schon eingeloggt
	        ## s.a. ausgabekatedit
	        ## 	wo wird das einloggen ausgewertet? - faqeditsic.pl
	        ## 	das geht weiter zu &isrightdate, 
	        ## 	dort koennte man auch eingeloggte Benutzer hinterlegen
		if ($who = &isdating(&whoamip)) {
			print trans("Name: ") , &rofeld("wer", $who, $breit), trans(" ist eingeloggt \&nbsp; ");
			print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("Logout"), "#EMPTY#" );
			#return($who);
		} else {
			print trans("Name: ") , &webtag("input", "type=text\tname=wer\tsize=$breit", "#EMPTY#" );
			print trans("\n \&nbsp; Parole: ") , &webtag("input", "type=password\tname=womit\tsize=$breit", "#EMPTY#" );
		}
	        print &webtag("p","","#ENDETAG#");
	print &webtag("div", "", "#ENDETAG#");  ## faqeditcheck

	## Unterschied: 	neu oder vorhanden
	## Ausgabe: 		Nr. (fest bei vorh. und dropdown bei neu), Kategorie (dropdown), Titel, Text
	print &webtag("h3", "class=faqedittit", trans("Frage ") . &webtag("small", &webtag("a", "href=faq.pl?kat=5#faq7\ttarget=_blank\tname=phinweis\ttitle=$phinweis", trans("(Bearbeitungs-Hinweise)"))) );
	if ($nr =~ m/neu|new/) {
		## (name, selected, feld) ## selected kann auch im feld ueber "=selected" erkannt werden
		print &webtag("p","","#EMPTY#");
		print trans("\nneue Frage<br>");
		print trans("\nFAQ-Nr.: "), &HTMLdropdown("nr","", @faqfrei), " \&nbsp; ";
		print trans("\nKategorie-Nr.: "), &HTMLdropdown("kat","", @katvorh), " <br><br>";
		print trans("\nFrage: <br>"), &inputfeld("tit", "", $breitfeld), " <br>";
		print trans("\nText: <br>"), &inputarea("text", "", $breitfeld, $hoch), " <br>";
		print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("Anlegen"), "#EMPTY#");
		print &webtag("p","","#ENDETAG#");
	} else {
		if (!($nrkat{$nr})) { &webabbruch (trans("FAQ-Nr. existiert nicht [$nr].")); }
		print &webtag("p","","#EMPTY#");
		print trans("\nFAQ-Nr.: "), &rofeld("nr", $nr, $breitkurz), " \&nbsp; ";
		print trans("\nKategorie-Nr.: "), &HTMLdropdown("kat","", @katvorh), " <br><br>";
		print trans("\nFrage: <br>"), &inputfeld("tit", $tit{$nr}, $breitfeld), " <br>";
		$inh{$nr} =~ s/\x02/\n/ig;
		## Achtung: Probleme mit Entities. 
		## 	Wenn Entities vorhanden sind, werden sie in der Bearbeitung als das jeweilige Zeichen ausgegeben.
		## 	Das Zeichen '&' muss geschuetzt werden.
		## 	Daher das '&' als '&amp;' maskieren.
		## 	Aber dennoch die Variable im uebergebenen Hash nicht veraendern
		$tempstring = $inh{$nr};
		$tempstring =~ s/\&/\&amp;/ig;
		print trans("\nText: <br>"), &inputarea("text", $tempstring, $breitfeld, $hoch), " <br>\n";
		print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("\xC4ndern"), "#EMPTY#");
		print &webtag("input", "type=submit\tname=aktion\tvalue=".trans("L\xF6schen"), "#EMPTY#");
		print &webtag("p","","#ENDETAG#");
	}

	print &webtag("div", "", "#ENDETAG#");  ## faqedit

	print &webtag("form", "", "#ENDETAG#" );
}

#---Ausgabe des Suchfeldes-------------------------------------------
sub ausgabesearchbox {
	# kat[0..|alle] prefix sst
	my ($kat, $prefix, $searchval, @rest) = @_; ## , $sst - hab ich hier noch gar nicht
	#my ($k, $v, @ke, $t, $katmax, @katfrei, @katnr, $i, $katneuende, @katvorh);
	#my ($faqmax, @faqfrei, @faqnr, $faqneuende, @faqvorh);
	my ($tempstring) = "";
	my ($who) = undef;
	my ( $helpkat, $helpfaq ) = ( 5, 68 );
	
	#print "<p>_____ausgabefaqedit_____</p>\n"; 

	my ($breit, $breitkurz, $breitlang, $breitfeld, $hoch, $breittiny) = (20, 5, 40, 70, 20, 18);
	if ($globals{"breit"    }) { $breit     = $globals{"breit"    }; }
	if ($globals{"breitkurz"}) { $breitkurz = $globals{"breitkurz"}; }
	if ($globals{"breitlang"}) { $breitlang = $globals{"breitlang"}; }
	if ($globals{"breitfeld"}) { $breitfeld = $globals{"breitfeld"}; }
	if ($globals{"hoch"     }) { $hoch      = $globals{"hoch"     }; }
	if ($globals{"breittiny"}) { $breittiny = $globals{"breittiny"}; }
	($breitfeld, $hoch) 	= (100, 20);

	## Bearbeitungshinweise Pseudocode
	##   Achtung! nicht mit Tab arbeiten, daraus macht webtag Attribute
	my $shinweis = <<SEARCHHINWEIS;
    UND-Suche,
    Es gibt keine Phrasensuche.
    Sonderzeichen werden entfernt.
    Hashtag-Suche mit: #(hashtag),
    alles case-insensitive
SEARCHHINWEIS
	$shinweis = trans($shinweis);	

	print webtag("form", "action=faqsearch.pl\tmethod=post", "#EMPTY#" );

	print webtag("div", "class=searchbox", "#EMPTY#");

	print ' &nbsp;';

	## Ausgabe:
	##		Prefix wenn vorhanden, 
	##		Kategorie hidden wenn belegt - sonst alle, 
	##		search input, 
	##		submit button

	my $searchbuttonval = '&nbsp;?&nbsp;';
	if ( !$searchval ) { $searchval = ''; }
	if ( !$kat ) { $kat = "alle"; }
	if ( $prefix ) {
		print 	webtag("span", "class=searchboxprefix", 
		 			webtag("a", "href=faq.pl?kat=$helpkat#faq$helpfaq\ttarget=_blank\tname=searchhinweis\ttitle=$shinweis", "$prefix")
		 		);
	}

	print webtag("span","class=searchinput","#EMPTY#");

		print inputfeld("sst", "$searchval", $breittiny);
		print "&nbsp;";
		print webtag("input", "type=hidden\tname=kat\tvalue=$kat", "#EMPTY#" );
		print '&nbsp;';
		print webtag("input", "type=submit\tname=aktion\tvalue=$searchbuttonval", "#EMPTY#");

		print webtag("span","class=searchinputext","#EMPTY#");
			#print webtag("br","#ENDETAG#");
			if ( !$prefix ) {
				print webtag( "small", ' &nbsp;&nbsp;' . 
				  webtag("a", "href=faq.pl?kat=$helpkat#faq$helpfaq\ttarget=_blank\tname=searchhinweis\ttitle=$shinweis", trans("nur gew\&auml;hlte Kat.")) . ' ' );
				#print weblink( webtag("small"," &nbsp;&nbsp;nur gew&auml;hlte Kat. ") , "faq.pl?kat=$helpkat#faq$helpfaq" );
			} else {
				print webtag("small"," &nbsp;&nbsp;".trans("nur gew\&auml;hlte Kat."))
			}
			print webtag("input", "type=checkbox\tname=onlypickedkat\tvalue=1", "#EMPTY#" );
		print webtag("span","","#ENDETAG#");

	print webtag("span","","#ENDETAG#");

	print webtag("div", "", "#ENDETAG#");  ## searchbox

	print webtag("form", "", "#ENDETAG#" );
}
#---Rueckgabe des HTML fuer ein Dropdown eines Feldes-------------------------------------------
sub HTMLdropdown {
	## name, selected, @feld
	local ($name, $sel, @feld) = @_;
	local ($s) = "";
	local ($i, $t, $issel);
	
	## Achtung: Value + Selected moeglich, Selected dann am Ende
	$s .= &webtag("select", "name=$name", "#EMPTY#");
	for ($i=0; $i<=$#feld; $i++) {
		$t = $feld[$i];
		$issel = undef;
		if ($t =~ s/=selected$//i) { $issel = "selected=selected"; }
		elsif ($sel == $i) { $issel = "selected=selected"; }
		if ($t =~ s/=(.*)$//i) { if ($issel) { $issel .= "\tvalue=$1"; } else { $issel = "value=$1"; } }
		$s .= &webtag("option", "$issel", $t);
	}
	$s .= &webtag("select", "", "#ENDETAG#");
	
	return($s);
}

#---Umwandeln (Pseudocode) einer FAQ in HTML-------------------------------------------
sub faq2htm {
## siehe input2faq, ABER: Ausnahmen/Erweiterungen unten
	local ($text) = $_[0];
	local ($fnr) = $_[1];  ## only for reporting issues
	
	## backup vars temporarily
	my $toeditbak	= $input{'toedit'};
	my $katbak 		= $input{'kat'};
	if( !defined( $input{'toedit'} ) )	{ $input{'toedit'} = ''; }
	if( !defined( $input{'kat'} ) )			{ $input{'kat'} = ''; }
	
	## siehe auch blockel in: webtag
	local ($blockel) = "P|H1|H2|H3|H4|H5|H6|UL|OL|PRE|DL|DIV|NOSCRIPT|BLOCKQUOTE|FORM|HR|TABLE|FIELDSET|ADDRESS|TR|TD|TH|FRAME|FRAMESET|NOFRAMES|LI|DD|DT|SELECT|OPTION";
	if ( !defined( $input{"toedit"} ) ) { $input{"toedit"} = ''; }
	## ein \n vor BR rein, damit man den Quelltext verfolgen kann
    	$text =~ s|\x02|\n<BR>|ig;

    	## Links steuern:
    	## 	nach innen gehende (ohne Protokoll http://) und Mail-Links (mailto:) ohne neues Fenster
    	$text =~ s|\[link=(mailto:[^\]]+)\](.*?)\[\/link\]|<a href="$1">$2<\/a>|igs;
    	$text =~ s~\[link=(https?\:\/\/|ftp\:\/\/)([^\]]+)\](.*?)\[\/link\]~<a href="$1$2" target="_blank">$3<\/a>~igs;
    	$text =~ s|\[link=([^\]]+)\](.*?)\[\/link\]|<a href="$1">$2<\/a>|igs;
    	## 	eXterne Links in neuem Frame oeffnen
    	$text =~ s|\[linkx=([^\]]+)\](.*?)\[\/link\]|<a href="$1" target="_blank">$2<\/a>|igs;
    	
    	$text =~ s|\[b\](.*?)\[\/b\]|<b>$1<\/b>|ig;
    	$text =~ s|\[i\](.*?)\[\/i\]|<i>$1<\/i>|ig;
    	$text =~ s|\[s\](.*?)\[\/s\]|<s>$1<\/s>|ig;
    	$text =~ s|\[u\](.*?)\[\/u\]|<u>$1<\/u>|ig;
    	$text =~ s|\[button\](.*?)\[\/button\]|<span class="button">$1<\/span>|ig; # style="border:3px outset darkgrey;margin:0 2px 0 2px;padding:0 2px 0 2px;background:lightgrey;"
    	$text =~ s|\[(\/)list\]|<$1ul>|ig;
    	$text =~ s|\[list\]|<ul>|ig;
    	$text =~ s|\[\*\]|<li>|ig;
    	$text =~ s|\[(\/)list=1\]|<$1ol>|ig;
    	$text =~ s|\[list=1\]|<ol>|ig;
    	$text =~ s|\[list=([1ai])\]|<ol type="$1">|ig;
    	$text =~ s|\[\/list=([1ai])\]|<\/ol>|ig;
    	$text =~ s|\[img=([^\]]+)\]|<img src="$1">|ig;
    	$text =~ s|\[(\/)code\]|<$1code>|ig;
    	$text =~ s|\[code\]|<code>|ig;
    	$text =~ s|\[(\/)quote\]|<$1blockquote>|ig;
    	$text =~ s|\[quote\]|<blockquote>|ig;
    	$text =~ s|\[(\/)pre\]|<$1pre>|ig;
    	$text =~ s|\[pre\]|<pre>|ig;
    	
    ## hashtags verlinken
    my ( $sictext0, $sictext1, $sictext2 );
	    	#$sictext0 = $text;
	    	#$sictext0 =~ s/\</\&lt;/sg;
	    	#$sictext0 =~ s/\>/\&gt;/sg;
	    	$text =~ s/\#(faq\d+)([^\d])/~$1$2/isg;
	    	$text =~ s/(\.pl\?kat=\d+)\#([^\x22>]+)([\x22>])/$1~~$2$3~/isg;
	    	$text =~ s/(<a href=\")([^\"#]+)\#/$1$2~~~/igs;
	    	#$sictext1 = $text;
	    	#$sictext1 =~ s/\</\&lt;/sg;
	    	#$sictext1 =~ s/\>/\&gt;/sg;
	    	$text =~ s/\#(\w+)([^a-zA-Z0-9;_\-\]]|$)/<a href=\"faqsearch.pl?sst=\%23$1\&toedit=$input{'toedit'}\&kat=$input{'kat'}\" class=\"hashtag\">\#$1<\/a>$2 - /gs ;
	    	#$text =~ s/<a href=\"[^. \t>\r\n?&].pl?sst=\%23(faq\d+)\&toedit=[^. \t>\r\n?&]\&kat=[^. \t>\r\n?&]\" class=\"hashtag\">(\#faq\d+)<\/a>([^a-zA-Z0-9;_\-\]]|$) - /$2$3/igs ;
	    	$text =~ s/(<a href=\")([^\"#]+)\~\~\~/$1$2\#/igs;
	    	$text =~ s/(\.pl\?kat=\d+)\~\~([^\x22>]+)([\x22>])~/$1\#$2$3/isg;
	    	$text =~ s/\~(faq\d+)([^\d])/\#$1$2/isg;
	    	$text =~ s/(<a href=\")([^\"<]*)<a href=[^>]*>([^<]+)<\/a>/$1$2$3/igs;
	    	#$sictext2 = $text;
	    	#$sictext2 =~ s/\</\&lt;/sg;
	    	#$sictext2 =~ s/\>/\&gt;/sg;
	    	#$text .= "<textarea>$sictext0<\/textarea>\n";
	    	#$text .= "<textarea>$sictext1<\/textarea>\n";
	    	#$text .= "<textarea>$sictext2<\/textarea>\n";

	## Ausnahmen/Erweiterungen zu HTML-Input
	## 	Namen/Linkziele
    	$text =~ s|\[name=([^\]]+)\](.*?)\[\/name\]|<a name="$1" id="$1">$2<\/a>|ig;

	## any eval() expression?
		my ( $evalidx, $evalcompletephrase, $evalfound );
		transalleval:
		while( $text =~ m/(eval\((.*?)\)eval)/ ) {
			$evalcompletephrase = $1;
			$evalfound = $2;
#			webhinweis( "&gt;&gt;&gt; foundEval in FAQ Nr: $fnr --[$evalcompletephrase // $evalfound]-- " );
			if ( $evalfound =~ m/eval\(/ ) {
#				webfehler( "!!! foundEval in FAQ Nr: $fnr contains \"eval\(\" --[$evalcompletephrase // $evalfound]-- " );
				last transalleval;
			}
			if ( ($evalidx = index( $text, $evalcompletephrase )) < 0 ) {
				last transalleval;
			}
			substr( $text, $evalidx, length( $evalcompletephrase ) ) = eval( $2 );
		}

	my( $spoilcont, $foundspoil, $spoilpos );
	while( $text =~ m|\[spoiler\](.*?)\[\/spoiler\]|si ) {
		$spoilcont = $1; $foundspoil = $&;
		$spoilpos = index( $text, $foundspoil );
		#$foundcont =~ s|<BR>||sig;
		substr( $text, $spoilpos, length($foundspoil) ) = 
			"<button type=\"button\" value=\"Spoiler$spoileridx\_func\" id=\"Spoiler$spoileridx\_func\" onClick=\"OnOff('Spoiler$spoileridx');\">Spoiler$spoileridx\_On</button><br>\n" .
#			"<blockquote id=\"Spoiler$spoileridx\" style=\"visibility: hidden;\" class=\"spoiler\">" . $spoilcont . '</blockquote>'
			"<blockquote id=\"Spoiler$spoileridx\" style=\"display: none;\" class=\"spoiler\">" . $spoilcont . '</blockquote>'
			;
		$spoileridx++;
	}
	
    	## das Umwandeln von \x02 in BR macht viele BR, wo sie nicht noetig sind, z.B. vor allen Blockelementen
    	$text =~ s/<BR>([ \t]*<\/?($blockel)[ >\t])/$1/ig;
    	## correct spoilers on first break
    	$text =~ s/(<blockquote([ \t][^>])+?>)([ \t]*[\r\n]+[ \t]*<br>)/$1/ig;

    	## OK, in pre take it out again
	## 3 steps, find and mask PRE, take our BR, un-mask PRE
	my( $foundcont, $foundpre, $prepos );
	while( $text =~ m|<pre>((.*?)<BR>(.*?))<\/pre>|si ) {
		$foundcont = $1; $foundpre = $&;
		$prepos = index( $text, $foundpre );
		$foundcont =~ s|<BR>||sig;
		substr( $text, $prepos, length($foundpre) ) = '__pre__' . $foundcont . '__/pre__';
	}
	$text =~ s|__pre__|<pre>|sig;
	$text =~ s|__/pre__|</pre>|sig;


	return ($text);	

}

#---Umwandeln (Pseudocode) einer FAQ in HTML-------------------------------------------
##   - bestimmte HTML-Tags umwandeln in Pseudomarkup
## 	\t		\x20
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
sub input2faq {
	local ($text) = $_[0];
	
    	$text =~ s|\t| |ig;
    	$text =~ s|<BR>|\x02|ig;
    	$text =~ s|\n|\x02|ig;
    	## anscheinend Probleme mit \x0d
    	$text =~ s|\x0D||ig;
    	$text =~ s|<a href=[\"\']([^\"\']+)[\"\']>(.*?)<\/a>|\[link=$1\]$2\[\/link\]|ig;
		## Links in neue Fenster
    	$text =~ s~<a href=[\"\']([^\"\']+)[\"\'] target=\"(_blank|_new|new)\">(.*?)<\/a>~\[linkx=$1\]$3\[\/link\]~ig;
    	$text =~ s|<b>(.*?)<\/b>|\[b\]$1\[\/b\]|ig;
    	$text =~ s|<i>(.*?)<\/i>|\[i\]$1\[\/i\]|ig;
    	$text =~ s|<s>(.*?)<\/s>|\[s\]$1\[\/s\]|ig;
    	$text =~ s|<strike>(.*?)<\/strike>|\[s\]$1\[\/s\]|ig;
    	$text =~ s|<(\/)?ul>|[$1list]|ig;
    	$text =~ s|<li>|[*]|ig;
    	$text =~ s|<(\/)?ol>|[$1list=1]|ig;
    	$text =~ s|<ol type=[\"\']([1ai])[\"\']>|[list=$1]|ig;
    	$text =~ s|<img src=[\"\']([^\"\']+)[\"\']>|[img=$1]|ig;
    	$text =~ s|<(\/)?pre>|[$1code]|ig;
    	$text =~ s|<(\/)?code>|[$1code]|ig;
    	$text =~ s|<(\/)?blockquote>|[$1quote]|ig;

    	$text =~ s|<[^ >].*?>||ig;

	return ($text);	
}

#---IP des Besuchers feststellen-------------------------------------------

#######################################################
## whoamip.pl
## feststellen der IP des Abrufenden im Intranet
## Thomas Hofmann, Sep 2005
## IP-Adresse ueber Environment(REMOTE_ADDR)
#######################################################
sub whoamip {
	if ($remote_addr = $ENV{ 'REMOTE_ADDR' }) {
		return($remote_addr);
	} else {
		&webabbruch( "Fehler: IP nicht gefunden.");
	}
}

sub parsesearch{
	my ( $sst, @rest ) = @_;
	
	#webhinweis( "IN parsesearch; sst: [$sst]" );

	#if ( $sst =~ /^[ \t\r\n]*$/ ) { return( undef ); }

	## keine Phrasen (vorerst)
	##   Anfuehrung loeschen
	## Wortbestandteil Sonderzeichen kann sein: -_
	##   und alle Umlaute 
	## alles Andere ersetzen durch ' '
	## Achtung, hier erstmal kein case insensitive (doppelt pruefung)
	
	my $searchnormalized = $sst;
	#webhinweis( "searchnormalized vor substitute: [$searchnormalized]" );
	$searchnormalized =~ s/[^a-zA-Z0-9_\xE4\xF6\xFC\xC4\xD6\xDC\xDF\#\-\.]+/ /gs;   ## Zeichen '#' ausnehmen
	$searchnormalized =~ s/\#/\x23/gs;   ## Zeichen '#' maskieren, gilt sonst evtl. als Kommentar
	#webhinweis( "searchnormalized past substitute: [$searchnormalized]" );
	my @leeresfeld = ();
	if ( $searchnormalized =~ /^[ \t\r\n]*$/ ) { return( @leeresfeld ); }

	my @searchterms = split( / +/, $searchnormalized );
	
	## doppelt pruefung
	my %singledterms;
	parseeveryterm:
	foreach my $term( @searchterms ) {
		next parseeveryterm if ( $term =~ /^[ \t\r\n]*$/ );
		$singledterms{ $term } = 1;
	}
	@searchterms = keys( %singledterms );
	
	return( @searchterms );
}

sub ismatch{
	my ( $text, @searchterms ) = @_;
	my $foundstring = $text;
	my $term = undef;
	
	my $sst = join( ' ', @searchterms );
	my $dohint = undef;
	if ( $sst =~ s/ sonder//is ) {
		$dohint = 1;
		@searchterms = split( / /, $sst );
	}

	if ( $#searchterms < 0 ) {
		#webhinweis( "IN ismatch; searchterms: [".join(' - ', @searchterms)."] anzahl: ".($#searchterms + 1) );
		#exit;
		return( '' );
	}

	#$dohint = 1;
	webhinweis( "IN ismatch; searchterms: [".join(' - ', @searchterms)."] anzahl: ".($#searchterms + 1) ) if $dohint;
	
	EVERYTERM:
	foreach $term( @searchterms ) {
		if( ( $foundstring !~ m/([^~])($term)([^~])/is ) 
			&& ( $foundstring !~ m/([^~])($term)$/is ) 
			&& ( $foundstring !~ m/^($term)([^~])/is ) 
			&& ( $foundstring !~ m/^($term)$/is )
		) {
			#webfehler( "___ ismatch kein match auf [$term] in: --[" . $foundstring . "]--"  ) if ( $dohint );
			$foundstring = '';
			last EVERYTERM;
		} elsif ( $foundstring =~ m/([^~])($term)([^~])/is ) {
				  $foundstring =~ s/([^~])($term)([^~])/$1<span class="foundterm">~~$2~~<\/span>$3/igs;
		} elsif ( $foundstring =~ m/([^~])($term)$/is ) {
				  $foundstring =~ s/([^~])($term)$/$1<span class="foundterm">~~$2~~<\/span>/igs;
		} elsif ( $foundstring =~ m/^($term)([^~])/is ) {
				  $foundstring =~ s/^($term)([^~])/<span class="foundterm">~~$1~~<\/span>$2/igs;
		} elsif ( $foundstring =~ m/^($term)$/is ) {
				  $foundstring =~ s/^($term)$/<span class="foundterm">~~$1~~<\/span>/igs;
		}
	}
	do { $foundstring =~ s|(href=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$4|igs; 	} while $foundstring =~ m|(href=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|is;
	do { $foundstring =~ s|(name=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$4|igs; 	} while $foundstring =~ m|(name=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|is;
	do { $foundstring =~ s|(id=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$4|igs;   	} while $foundstring =~ m|(id=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|is;
	do { $foundstring =~ s|(src=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$4|igs;   } while $foundstring =~ m|(src=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|is;
	do { $foundstring =~ s|(onClick=\"OnOff\(')([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$4|igs;   	
	} while $foundstring =~ m|(onClick=\"OnOff\(')([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|is;
	do { $foundstring =~ s|(value=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$4|igs; } while $foundstring =~ m|(value=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|is;
	do { $foundstring =~ s|(class=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$4|igs; } while $foundstring =~ m|(class=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|is;
	do { $foundstring =~ s|(type=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$4|igs;	} while $foundstring =~ m|(type=\")([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|is;
	## for sst "button" and: <button ..>
	do { $foundstring =~ s|([<\[])([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)([ >\]])|$1$2$4$6|igs;} while $foundstring =~ m|([<\[])([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)([ >\]])|is;
	## for sst "name" and: <a name ..>

	## hide out the curly brackets
	$foundstring =~ s|\{|#lcb#|igs;
	$foundstring =~ s|\}|#rcb#|igs;
	do { $foundstring =~ s{(<a |\[)([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)}{$1$2$4}igs;	} while $foundstring =~ m{(<a |\[)([^<>\"]*)(<span class=\"foundterm\">)~~([^~]+)~~(</span>)}is;
	## bring the curly brackets back
	$foundstring =~ s|#lcb#|\{|igs;
	$foundstring =~ s|#rcb#|\}|igs;
	
	$foundstring =~ s|(<span class=\"foundterm\">)~~([^~]+)~~(</span>)|$1$2$3|igs;
	
	do { $foundstring =~ s|(href=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|$1$2$4|igs;    	} while $foundstring =~ m|(href=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|is;
	do { $foundstring =~ s|(name=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|$1$2$4|igs;  	} while $foundstring =~ m|(name=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|is;
	do { $foundstring =~ s|(id=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|$1$2$4|igs;    	} while $foundstring =~ m|(id=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|is;
	do { $foundstring =~ s|(src=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|$1$2$4|igs;    	} while $foundstring =~ m|(src=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|is;
	do { $foundstring =~ s|(onClick=\"OnOff\(')([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|$1$2$4|igs;    	
	} while $foundstring =~ m|(onClick=\"OnOff\(')([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|is;
	do { $foundstring =~ s|(value=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|$1$2$4|igs;    	} while $foundstring =~ m|(value=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|is;
	do { $foundstring =~ s|(class=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|$1$2$4|igs;    	} while $foundstring =~ m|(class=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|is;
	do { $foundstring =~ s|(type=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|$1$2$4|igs;    	} while $foundstring =~ m|(type=\")([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)|is;
	## for sst "button" and: <button ..> | [button ..
	do { $foundstring =~ s|([<\[])([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)([ >\]])|$1$2$4$6|igs;} while $foundstring =~ m|([<\[])([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)([ >\]])|is;
	## for sst "name" and: <a name ..>

	## hide out the curly brackets
	$foundstring =~ s|\{|#lcb#|igs;
	$foundstring =~ s|\}|#rcb#|igs;
	do { $foundstring =~ s{(<a |\[)([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)}{$1$2$4}igs;  	} while $foundstring =~ m{(<a |\[)([^<>\"]*)(<span class=\"foundterm\">)([^<]+)(</span>)}is;
	## bring the curly brackets back
	$foundstring =~ s|#lcb#|\{|igs;
	$foundstring =~ s|#rcb#|\}|igs;

	return( $foundstring );
}

sub gethashtags {
	# gethashtags( \%finh );
	my ( $faqinh, @rest ) = @_;
	
	my %hashtag = ();
	my @inhkeys = keys( %{ $faqinh } );
	my @faqhash = ();
	my ( $ikey, $fhash );
	foreach $ikey ( @inhkeys ) {
		#@faqhash = ( $$faqinh{ $ikey } =~ /(?:^|[^a-zA-Z_&?\-])(\#\w+)(?:[^a-zA-Z0-9;_\-\]]|$)/g );
		@faqhash = ( $$faqinh{ $ikey } =~ /(\#\w+)(?:[^a-zA-Z0-9;_\-\]]|$)/g );
		foreach $fhash ( @faqhash ) {
			#if( !defined(%hashtag) ) { webhinweis("!defined(\%hashtag)"); }
			#if( !defined($fhash) ) { webhinweis("!defined(\$fhash)"); }
			#if( !defined($hashtag{ $fhash }) ) { webhinweis("!defined(\$hashtag{ \$fhash })"); }
			
			#if( !defined($hashtag{ $fhash }) ) { $hashtag{ $fhash } = 0; }
			
			#if( $fhash =~ /\#?\d{8}/ ) {
			#	if($fhash !~ /\#\d{8}/) {
			#		webhinweis("fhash: $fhash - NOT match \\d{8}"); 
			#	} else {
			#		webhinweis("fhash: $fhash - DOES  match \\d{8}"); 
			#	}
			#	exit;
			#}
			if ( $fhash !~ /\#\d{8}/ ) {
				#webhinweis("fhash: $fhash - NOT match \\d{8}"); 
				if ( 
							!defined( $hashtag{ $fhash } ) 
				   ) {
					$hashtag{ $fhash } = 1;
				} elsif ( 
							($hashtag{ $fhash } >= 1) 
					    ) {
					$hashtag{ $fhash }++;
				}
			}
		}
	}
	
	return( %hashtag );
}

sub gethashtagsblock {
	# gethashtagsblock( $hasharray ); ## where $hasharray = \@hasharray;
	my ( $arref , @rest ) = @_;
#webhinweis("<b>IN gethastagsblock</b> ...") if $debug;
	
	my $hashblock = '';
	if ( !$arref ) {
		return( '' );
	}
	
	$hashblock .= "<div class=\"hashblock\">\n";
	
	# faqsearch.pl?sst=#hashtag
	my $hashcount = @{ $arref };
webhinweis("<b>hashcount:</b>  $hashcount") if $debug;
	#webhinweis( "IN gethashtagsblock - hashcount: $hashcount" );
#print "</ol>\n</td></tr>\n</table>\n" if $debug;
print "\n</div>\n" if $debug;
#webhinweis("<b>IN gethastagsblock</b> - <b>foreach \$hashtag</b> before") if $debug;
#exit;

print "<p>\n" if $debug;
print join( ' ~ ', sort( @{ $arref } ) ) if $debug;
print "\n</p>\n" if $debug;
print "\n<hr>\n" if $debug;

print "<p>\n" if $debug;
	my @hasharraysort = sort( @{ $arref } );
	my $hashtag = '';
	my $hindex = 0;
	
	eachhashtagshow:
	for( $hindex = 0; $hindex <= $#hasharraysort; $hindex++ ) {
			$hashtag = $hasharraysort[$hindex];
			$hashblock .= "<a href=\"faqsearch.pl?sst=\%23".substr($hashtag,1)."\&toedit=$input{'toedit'}\&kat=$input{'kat'}\">$hashtag</a> - \n";
			print "$hindex (".length($hashblock)."): ".substr($hashtag,1)." - " if $debug;
			if( $debug1 ) {
				last eachhashtagshow if ($hindex >= 450);
			}
	}

#	foreach $hashtag ( sort( @{ $arref } ) ) {
#			$hashblock .= "<a href=\"faqsearch.pl?sst=\%23".substr($hashtag,1)."\&toedit=$input{'toedit'}\&kat=$input{'kat'}\">$hashtag</a> - ";
#			print "".substr($hashtag,1)." - " if $debug;
#	}

print "\n</p>\n" if $debug;
webhinweis("<b>IN gethastagsblock</b> - <b>foreach \$hashtag</b> after") if $debug;
#exit if $debug;
	
	$hashblock .= "</div>\n";
	
	return( $hashblock );
}

sub gethashtagcloud {
	# gethashtagsblock( $hasharray ); ## where $hasharray = \@hasharray;
	my ( $hashref , @rest ) = @_;
	
	my $hashblock = '';
	if ( !$hashref ) {
		return( '' );
	}
	
	$hashblock .= "<div class=\"hashblock\">\n";
	
	# faqsearch.pl?sst=#hashtag
	my $hashcount = keys( %{ $hashref } );
	#webhinweis( "IN gethashtagcloud - hashcount: $hashcount" );
	my ( $hashtag, $maxcloud, $lvl ) = ( undef, 0, 0 );
	my @lvl = ( 0.2, 0.4, 0.85, 0.95, 1 );  ## lvls in percent of max count
	my @big = ( 0.6, 1.0, 1.3, 1.6, 1.8 );  ## font-size in em
	my $ilvl;
	
	foreach $hashtag ( keys(%{ $hashref }) )  {
		$maxcloud = $$hashref{$hashtag} if $$hashref{$hashtag} > $maxcloud;
	}
	foreach $hashtag ( sort( keys(%{ $hashref }) ) ) {
		$lvl = 0;
		#webfehler( "hashtag(count): $hashtag($$hashref{$hashtag})" );
		foreach $ilvl ( 1..$#lvl ) {
			if ( $$hashref{$hashtag} >= ($lvl[$ilvl-1] * $maxcloud) ) {
				$lvl = $ilvl;
				#webhinweis( "hashref{$hashtag} > lvl[".($ilvl-1)."] * maxcloud(".($lvl[$ilvl-1] * $maxcloud).") - lvl($lvl)" );
			} else {
				#webhinweis( "NOT hashref{$hashtag} > lvl[".($ilvl-1)."] * maxcloud(".($lvl[$ilvl-1] * $maxcloud).") - lvl($lvl)" );
			}
		}
		#$hashblock .= "<span style=\"font-size: $big[$lvl]em;\"><a href=\"faqsearch.pl?sst=\%23".substr($hashtag,1)."\&fueredit=$input{'fueredit'}\&kat=$input{'kat'}\">$hashtag($$hashref{$hashtag})</a></span> - ";
		$hashblock .= "<span style=\"font-size: $big[$lvl]em;\"><a href=\"faqsearch.pl?sst=\%23".substr($hashtag,1)."\&fueredit=$input{'fueredit'}\&kat=$input{'kat'}\" title=\"$$hashref{$hashtag}\">$hashtag</a></span> - ";
	}
	#exit;
	$hashblock .= "</div>\n";
	
	return( $hashblock );
}

sub gethashtagcloudsmall {
	# gethashtagsblock( $hasharray ); ## where $hasharray = \@hasharray;
	# cloud with every hastag bigger than lowest
	my ( $hashref , @rest ) = @_;
	
	my $hashblock = '';
	if ( !$hashref ) {
		return( '' );
	}
	
	$hashblock .= "<div class=\"hashblock\">\n";
	
	# faqsearch.pl?sst=#hashtag
	my $hashcount = keys( %{ $hashref } );
	#webhinweis( "IN gethashtagcloud - hashcount: $hashcount" );
	my ( $hashtag, $maxcloud, $lvl ) = ( undef, 0, 0 );
	my @lvl = ( 0.2, 0.4, 0.85, 0.95, 1 );  ## lvls in percent of max count
	my @big = ( 0.6, 1.0, 1.3, 1.6, 1.8 );  ## font-size in em
	my $ilvl;
	
	foreach $hashtag ( keys(%{ $hashref }) )  {
		$maxcloud = $$hashref{$hashtag} if $$hashref{$hashtag} > $maxcloud;
	}
	foreach $hashtag ( sort( keys(%{ $hashref }) ) ) {
		$lvl = 0;
		#webfehler( "hashtag(count): $hashtag($$hashref{$hashtag})" );
		foreach $ilvl ( 1..$#lvl ) {
			if ( $$hashref{$hashtag} >= ($lvl[$ilvl-1] * $maxcloud) ) {
				$lvl = $ilvl;
				#webhinweis( "hashref{$hashtag} > lvl[".($ilvl-1)."] * maxcloud(".($lvl[$ilvl-1] * $maxcloud).") - lvl($lvl)" );
			} else {
				#webhinweis( "NOT hashref{$hashtag} > lvl[".($ilvl-1)."] * maxcloud(".($lvl[$ilvl-1] * $maxcloud).") - lvl($lvl)" );
			}
		}
		#$hashblock .= "<span style=\"font-size: $big[$lvl]em;\"><a href=\"faqsearch.pl?sst=\%23".substr($hashtag,1)."\&fueredit=$input{'fueredit'}\&kat=$input{'kat'}\">$hashtag($$hashref{$hashtag})</a></span> - ";
		$hashblock .= "<span style=\"font-size: $big[$lvl]em;\"><a href=\"faqsearch.pl?sst=\%23".substr($hashtag,1)."\&fueredit=$input{'fueredit'}\&kat=$input{'kat'}\" title=\"$$hashref{$hashtag}\">$hashtag</a></span> - " if $lvl > $lvl[0];
	}
	#exit;
	$hashblock .= "</div>\n";
	
	return( $hashblock );
}

sub getpath {
## Uebergabe: vollstaendiges Verzeichnis/Dateiname
## Rueckgabe: Verzeichnis ohne Dateiname bzw. letztes Unterverzeichnis
## globale Variablen: nurpfad, nurdat, slash

        my ( $vpfad, @par ) = @_;
        $vpfad =~ m/^(.+)([\\\/])([^\\\/]*)$/;
        if (defined($1)) {
                $nurpfad = $1;
                $slash   = $2;
                $nurdat  = $3;
        } else {
                $nurpfad = '';
                $nurdat = $vpfad;
        }
        return ($nurpfad);
}

sub getfilename {
## Uebergabe: vollstaendiges Verzeichnis/Dateiname
## Rueckgabe: Verzeichnis ohne Dateiname bzw. letztes Unterverzeichnis
## globale Variablen: nurpfad, nurdat, slash

        my ( $vpfad, @par ) = @_;
#        webhinweis( ">>> getfilename: vpfad : $vpfad" );
#        $vpfad =~ m/^(.+)([\\\/])([^\\\/]*)$/;
#        if (defined($1)) {
        if ( $vpfad =~ m/^(.+)([\\\/])([^\\\/]*)$/ ) {
        	( $nurpfad, $slash, $nurdat ) = ( $1, $2, $3 );
#	        webhinweis( "\t+++ defined \$1 : [$nurpfad]" );
#                $nurpfad 	= $1;
#                $slash   	= $2;
#                $nurdat  	= $3;
        } else {
#	        webhinweis( "\t!!! NOT defined \$1 : [$vpfad] " );
                $nurdat 	= $vpfad;
                $nurpfad 	= '';
        }
#        webhinweis( "nurdat : $nurdat -- nurpfad : $nurpfad" );
        $nurdat =~ s/(\?.*)$//;
        return ($nurdat);
}

sub trans {
	my ( $text, @rest ) = @_;
#	foreach my $src ( keys( %i18n_lang ) ) {
	my $dest;
	foreach my $src ( @i18n_lang ) {  ## should be the keys
		$dest = $i18n_lang{"$src"};
#		webhinweis("\$text: $text -- \$src: $src -- \$i18n_lang{\"$src\"}: ". $i18n_lang{"$src"} . " -- \$dest: $dest");
		$text =~ s/$src/$dest/g;
	}
	return( $text );
}

sub linkLang {
#	my ( $lang, @rest ) = @_;
	if ( $#langs < 1 ) {
		return( trans("[Keine alternative Sprache vorhanden]") );
	}
	my $foundLang = 0;
	my ( $langLinks, @langLinks, @langOptions );
	foreach my $langPresent (@langs) {
#		if ( $lang eq $langPresent ) { $foundLang = 1; }
		## als einfache Links
		push ( @langLinks, "<a href=\"faq.pl?lang=$langPresent\">[$langPresent]</a>"  );
		## als select (DropDown)
		if ( $i18n_lang eq $langPresent ) {
			push ( @langOptions, "<option selected=\"selected\">$langPresent</option>"  );
		} else {
			push ( @langOptions, "<option>$langPresent</option>"  );
		}
	}
#	if ( !$foundLang ) {
#		return( trans("[Gew\xE4hlte Sprache nicht gefunden ")."($lang)]") ;
#	}
	## als einfache Links
#	return( join( ' ', @langLinks ) );
	## als select (DropDown)
#	return( "\n\t<form action=\"faq.pl\">\n\t<select name=\"lang\">\n\t\t" . join( "\n\t\t", @langOptions ) . "\n\t</select>\n\t <input type=\"submit\" value=\" &gt; \">\n\t</form>\n" );
	return( "\n\t<select name=\"lang\">\n\t\t" . join( "\n\t\t", @langOptions ) . "\n\t</select>\n\t <input type=\"submit\" value=\" &gt; \">\n" );
}
sub setLang {
	my ( $lang, @rest ) = @_;
	if ( $#langs < 1 ) {
		return( trans("[Keine alternative Sprache vorhanden]") );
	}
	my $foundLang = 0;
	my ( $langLinks, @langLinks );
	foreach my $langPresent (@langs) {
		if ( $lang eq $langPresent ) { $foundLang = 1; }
		push ( @langLinks, "<a href=\"faq.pl?lang=$langPresent\">[$langPresent]</a>"  );
	}
	if ( !$foundLang ) {
		return( trans("[Gew\xE4hlte Sprache nicht gefunden ")."($lang)]") ;
	}

	# set the language in the conf-file
	if( open( LANGCONF, ">$i18n_conf" ) ) {
		print LANGCONF "$lang\n";
		close(LANGCONF );
		## basically at this point, but then in false language, so better put it down
#		webhinweis(trans("Sprach-Konfiguration gesichert [$i18n_conf]"));  
	} else {
		webfehler(trans("Kann Sprach-Konfiguration nicht \xE4ndern [$i18n_conf]"));
		return(0);
	}
	
	# get the translations from lang-file
	if ( !getI18n(*i18n_lang, *i18n_conf) ) {
		webfehler (trans("Fehler beim Holen der Spracheinstellungen") . ". $globals{'adminmes'}.");
	}
	## basically at the point above, but then in false language, so better put it here
	webhinweis(trans("Sprach-Konfiguration gesichert [$i18n_conf]"));

#	return( join( ' ', @langLinks ) );
	return 1;
}


sub getonoffscript {
	my $scriptsrc = <<__ONOFF_SCRIPT__;
__ONOFF_SCRIPT__

	$scriptsrc = <<__ONOFF_2_SCRIPT__;
 <script type="text/javascript">
  function OnOff(theid){
	var id = theid;
	var obj = document.getElementById(id);
	var button = document.getElementById( id + '_func' );
   	if( obj.style.display == 'none' ) {
		obj.style.display = 'block';
		button.innerHTML = id + '_off';
	} else {
		obj.style.display = 'none';
		button.innerHTML = id + '_on';
	}
  }
 </script>

__ONOFF_2_SCRIPT__
	return( $scriptsrc );
}

#---Ausdruck einer Liste-----------------#pl#

sub printListe {

	local($z,$za,$c,$c2,$code,$zbs);
	$zbs=25;
	$z=1;$za=1;

print "\nAnzahl: ".@_."\n";
allevonprintListe:
foreach (@_) {
#       tr/\//\\/;
# war im Hauptprogramm gedacht zum Ersetzen von "/" durch "\" in DIRs
	if ($page && ($z >= ($zbs - 3))) {
		print "\nENTER = naechste Seite  ".
			"oder  'a' = Abbruch Liste ".
			"oder  'e' = Ende Programm: ";
		$c=<STDIN>;
		#$code=unpack("c",$c); #geht auch ord()?
		chop($c2=$c);
		if ($c ne "\n") {
			if ("e" eq $c2) { exit(0)};
			if ("a" eq $c2) { last(allevonprintListe)};
		}
		print "\n\n";
		$z=1;
	}
	print $za++ . "\t"; $z++;
	print $_."\n"
};
print "\nAnzahl: ".@_."\n";
};

#---Ausdruck eines Hash-----------------#ph#

sub printHash {

	local(%h)=@_;
	local($z,$za,$c,$c2,$code,$zbs,$temp);
	$zbs=25;
	$z=1;$za=1;
$temp=keys(%h);
print "Anzahl: $temp\n";
allevonprintHash:
foreach (keys %h) {
	if ($page && ($z >= ($zbs - 3))) {
		print "\nENTER = naechste Seite  ".
			"oder  'a' = Abbruch Liste ".
			"oder  'e' = Ende Programm: ";
		$c=<STDIN>;
		#$code=unpack("c",$c); #geht auch ord()?
		chop($c2=$c);
		if ($c ne "\n") {
			if ("e" eq $c2) { exit(0)};
			if ("a" eq $c2) { last(allevonprintHash)};
		}
		print "\n\n";
		$z=1;
	}
	print $za++ , ": $_\t\t$h{$_}\n"; $z++;
};
$za--;
print "\nAnzahl: $za\n";
};

#--- ENDE Alles ------------------------------------
1;
