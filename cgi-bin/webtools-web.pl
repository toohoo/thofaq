#!d:/xampp/perl/bin/perl
#!/usr/bin/perl
#######################################################
## webtools.pl
## Thomas Hofmann Sep 2005
## Routinen fuer das Einbinden in Web-Projekte auf dem Intraget Webserver
#######################################################

1;

#---Fehlerausgabe in HTML-Seite------------------------------------
sub webfehler {
	## Uebergabe: Nachricht
	local (@mes) = @_;
	print "\n<p class='webfehler'><strong class='fehltit'>Fehler:</strong> $mes[0]</p>\n";
}

#---Fehlerausgabe in HTML-Seite und Abbruch------------------------------------
sub webabbruch {
	## Uebergabe: Nachricht
	local (@mes) = @_;
	print "\n<p class='webfehler'><strong class='fehltit'>Abbruch, Fehler:</strong> $mes[0]</p>\n";
	exit;
}

#---Hinweisausgabe in HTML-Seite------------------------------------
sub webhinweis {
	## Uebergabe: Nachricht
	local (@mes) = @_;
	print "\n<p class='webhinweis'><strong class='hinwtit'>Hinweis:</strong> $mes[0]</p>\n";
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
	local (@mes) = @_;
	return ("<a href=\"$mes[1]\">$mes[0]</a>");
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
## ist das gut hier? lieber Neuanlegen oder L�schung �ber Zuweisung des Ergebnisses der SUB (Hash)
#undef(*opt);

sub holopt {
#---Parameter:
#--     Konfigurationsdatei
#--     errmes als globale Variable zuweisen? dann schon im Hauptprogramm festlegen?
	local (@par) = @_;
	local ($k,$v,%myopt);
	## falls %opt schon au�erhalb festgelegt war
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
	print "<tr><td> </td><td>", &webtag("input","type=submit\tvalue=�ndern","#EMPTY#") , "</td></tr>\n";
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
	## falls %rem schon au�erhalb festgelegt war
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
	    if (($z !~ m/^[ \t]*$/i) && ($z !~ m/^[ \t]*#/i)) {
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
	"admintel",	"146",
	"adminmail",	"thofmann\@ubmedia.de",
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
	if (! $head) { &webabbruch("UbmCgiHead: Kein Titel �bergeben."); }
	$head = &HtmlTop($head);
	## Markup im Title entfernen
	if ( $head =~ m|<title>(.*?)<\/title>|i ) {
		$temp = $1;
		$temp =~ s|<[^>]+>||ig;
		$head =~ s|(<title>).*?(<\/title>)|$1$temp$2|i
	}
	## Doctype einfuegen
	$head =~ s|(<html>)|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">\n\1|i;
	## Charset
	$head =~ s|(<head>)|\1\n<META http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">|i;
	## Styles
	$head =~ s|(<\/head>)|\n<link rel=\"stylesheet\" type=\"text/css\" href=\"ubmintra.css\">\n\1|i;
	## Cache auf 0 setzen
	$head =~ s|(<\/head>)|\n<meta http-equiv=\"expires\" content=\"0\">\n\1|i;
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
		&webabbruch("Kann SGM-Datei im Pool nicht sch�tzen: [" . &hinterlegt($ziel) . "]");
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
	## 	sinngem��: "Holen und Sichern im Pool ist nicht noetig, steckt schon in GAG Autoren."
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
		&webabbruch("Kann Kopie SGM-Datei in bearb nicht l�schen: [" . &hinterlegt($bearb) . "]");
	}

	return ($sgm);
}

#---Holen der Daten der FAQ-------------------------------------------
sub holfaq {
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
		@f = %f = ();
		if ( !(open (DAT, $datei[$i]) ) ) {
			&webabbruch ("Kann Datei nicht lesen [$datei[$i]]. $globals{'adminmes'}");
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
	local ($aktkat,$isedit,%ka) = @_;
	local ($k, $v, @ke, $t);
	
	@ke = sort (keys (%ka) );
	if (($aktkat eq "") || !defined($aktkat)) { $aktkat=1; }
	print &webtag("div", "class=katwahl", "#EMPTY#");
	if ($isedit) {
	    print &webtag("h3", "class=katwahltit", "Kategorien <br>" . &webtag("small",&weblink("[zur�ck zu den FAQ]","faq.pl")) );
	} else {  ## normal nicht edit
	    print &webtag("h3", "class=katwahltit", "Kategorien <br>" . &webtag("small",&weblink("[EDIT]","editfaqkat.pl")) );
	}
	#print &webtag("p", &weblink("[EDIT]","editfaqkat.pl"));
	#print &webtag("blah");
	print &webtag("ol", "type=1", "#EMPTY#");

	foreach $k (@ke) {
		if ($aktkat eq $k) {
			#$t = &webtag("b", &weblink("$ka{$k}", "faq.pl?kat=$k"));
			print &webtag("li", "value=$k", &webtag("b", "*$ka{$k}*") );
		} else {
		    if ($isedit) {
			print &webtag("li", "value=$k", &weblink("$ka{$k}", "editfaq.pl?kat=$k") );
		    } else {  ## normal nicht edit
			print &webtag("li", "value=$k", &weblink("$ka{$k}", "faq.pl?kat=$k") );
		    }
		}
	}
	
	print &webtag("ol", "", "#ENDETAG#");
	print &webtag("div", "", "#ENDETAG#");
}

#---Ausgabe der Fragen der aktuellen Kategorie-------------------------------------------
#&ausgabefaq($aktkat, *fkat, *ftit, *finh, *fnrkat);
sub ausgabefaq {
	local ($akat, $isedit, *kat, *tit, *inh, *nrkat) = @_;
	local (@fke) = sort(keys(%nrkat));
	local (@aktfaq) = ();
	local ($k, $temp);
	
	## erst Liste der Fragen ausgeben mit Links zu den Fragen unten
	## dabei schon eine Liste der FAQ merken, die der Kategorie entsprechen
	## zum Schluss die FAQ ausgeben
	print &webtag("div", "class=faq", "#EMPTY#");

	print &webtag("div", "class=faqfragen", "#EMPTY#");
	if ($isedit) {
	    print &webtag("h3", "class=faqfragtit", &webtag("a","name=fragen","Fragen") . " zum Thema: ''$kat{$aktkat}'' " . &webtag("small",&weblink("[zur�ck zu den FAQ]","faq.pl"))  . " " . &webtag("small",&weblink("[alle Kategorien]","editfaq.pl?kat=alle")) );
	} else {  ## normal nicht edit
	    print &webtag("h3", "class=faqfragtit", &webtag("a","name=fragen","Fragen") . " zum Thema: ''$kat{$aktkat}'' " . &webtag("small",&weblink("[EDIT]","editfaq.pl")) . " " . &webtag("small",&weblink("[alle Kategorien]","faq.pl?kat=alle")) );
	}
	print &webtag("ol", "type=1", "#EMPTY#");
	foreach $k (@fke) {
		if ($nrkat{$k} eq $akat) {
			push (@aktfaq, $k);
			print &webtag("li", "value=$k", &weblink("$tit{$k}", "#faq$k") );
		} elsif ($akat eq "alle") {
			push (@aktfaq, $k);
			print &webtag("li", "value=$k", &weblink("$tit{$k}", "#faq$k") );
		}
	}
	if ($#aktfaq < 0) {
		if ($isedit) {
			print &webtag("a", "href=faqedit.pl?fnr=neu\tclass=faqtitedit", "[neue Frage]");
		}
		&webhinweis("Keine FAQ in dieser Kategorie");
	}
	print &webtag("ol", "", "#ENDETAG#");
	print &webtag("div", "", "#ENDETAG#");

	if ($#aktfaq >= 0) {
		print &webtag("div", "class=faqantworten", "#EMPTY#");
		if ($isedit) {
		    print &webtag("h3", "class=editfaqanttit", "Antworten " . &webtag("a", "href=faqedit.pl?fnr=neu\tclass=faqtitedit", "[neue Frage]"));
		} else {
		    print &webtag("h3", "class=faqanttit", "Antworten");
		}
		print &webtag("dl", "", "#EMPTY#");
		foreach $k (@aktfaq) {
			if ($isedit) {
			    if ($akat eq "alle") { 
			    	$temp = &webtag("dt", &webtag("a","name=faq$k", "$k\. $tit{$k} ") 
			    		. &webtag("small", " (Kat. $nrkat{$k}) ") 
			    		. &webtag("a", "href=faqedit.pl?fnr=$k\tclass=faqtitedit", "[Edit]") );
			    } else {
			    	$temp = &webtag("dt", &webtag("a","name=faq$k", "$k\. $tit{$k} ") 
			    		. &webtag("a", "href=faqedit.pl?fnr=$k\tclass=faqtitedit", "[Edit]"));
			    }
			    print $temp;
			} else {
			    if ($akat eq "alle") { 
			    	$temp = &webtag("dt", &webtag("a","name=faq$k", "$k\. $tit{$k}") 
			    		. &webtag("small", " (Kat. $nrkat{$k})") );
			    } else {
			    	$temp = &webtag("dt", &webtag("a","name=faq$k", "$k\. $tit{$k}") );
			    }
			    print $temp;
			}
			print &webtag("dd", &faq2htm($inh{$k}) . "<br>" . &webtag ("a", "href=#fragen\tclass=zufragen", "&uArr; zu den Fragen") );
		}
		print &webtag("dl", "", "#ENDETAG#");
		print &webtag("div", "", "#ENDETAG#");
	}

	print &webtag("div", "", "#ENDETAG#");
	
	return(1);
}

#---Ausgabe der Bearbeitung der FAQ-Kategorien-------------------------------------------
sub ausgabekatedit {
	local (*ka) = @_;
	local ($k, $v, @ke, $t, $katmax, @katfrei, @katnr, $i, $katneuende);
	local ($keft);
	local ($who);

	local ($breit, $breitkurz, $breitlang, $breitfeld, $hoch) = (20, 5, 40, 50, 8);
	if ($globals{"breit"    }) { $breit     = $globals{"breit"    }; }
	if ($globals{"breitkurz"}) { $breitkurz = $globals{"breitkurz"}; }
	if ($globals{"breitlang"}) { $breitlang = $globals{"breitlang"}; }
	if ($globals{"breitfeld"}) { $breitfeld = $globals{"breitfeld"}; }
	if ($globals{"hoch"     }) { $hoch      = $globals{"hoch"     }; }

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
	@katnr = sort(keys(%ka));
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
	push(@katfrei,"anf�gen");

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
	print &webtag("h3", "class=kateditchecktit", "Benutzer");
	print &webtag("div", "class=kateditcheck", "#EMPTY#");
	        print &webtag("p","","#EMPTY#");
	        ## hier koennte man pruefen ob schon eingeloggt
	        ## s.a. ausgabefaqedit
	        ## 	wo wird das einloggen ausgewertet? - editfaqkat.pl
	        ## 	das geht weiter zu &isrightdate, 
	        ## 	dort koennte man auch eingeloggte Benutzer hinterlegen
		if ($who = &isdating(&whoamip)) {
			print "Name: " , &rofeld("wer", $who, $breit), " ist eingeloggt \&nbsp; ";
			print &webtag("input", "type=submit\tname=aktion\tvalue=Logout", "#EMPTY#" );
			#return($who);
		} else {
			print "Name: " , &webtag("input", "type=text\tname=wer\tsize=$breit", "#EMPTY#" );
			print " \&nbsp; Parole: " , &webtag("input", "type=password\tname=womit\tsize=$breit", "#EMPTY#" );
		}
	        print &webtag("p","","#ENDETAG#");
	print &webtag("div", "", "#ENDETAG#");  ## kateditcheck

	print &webtag("h3", "class=katedittit", "Kategorien");
	print &webtag("ol", "type=1", "#EMPTY#");

	foreach $k (@katnr) {
		print &webtag("li", "value=$k", "#EMPTY#" );
		if ($keft eq "alles") {
			print &webtag("input", "type=text\tname=kattit_$k\tvalue=$ka{$k}\tsize=$breitlang", "#EMPTY#" );
			#print &webtag("input", "type=hidden\tname=katnr\tvalue=$k", "#EMPTY#" );
			print &webtag("input", "type=submit\tname=aktion\tvalue=�ndern $k", "#EMPTY#" );
			## dann ein Link zum Loeschen
			## 	ausser bei Kategorie 1, die darf man nicht loeschen
			if ($k != 1) {
				print &webtag("input", "type=submit\tname=aktion\tvalue=L�schen $k", "#EMPTY#" );
			}
		} else {  ## keft eq 'einzeln'
			## erst ein form zum Aendern des Titels der Kat.
			print &webtag("form", "aktion=editfaqkat.pl", "#EMPTY#" );
			print &webtag("input", "type=text\tname=kattit\tvalue=$ka{$k}\tsize=$breitlang", "#EMPTY#" );
			print &webtag("input", "type=hidden\tname=katnr\tvalue=$k", "#EMPTY#" );
			print &webtag("input", "type=submit\tname=aktion\tvalue=�ndern", "#EMPTY#" );
			print &webtag("input", "type=submit\tname=aktion\tvalue=L�schen", "#EMPTY#" );
			print &webtag("form", "", "#ENDETAG#" );
		}
		print &webtag("li", "", "#ENDETAG#" );
	}
	
	print &webtag("ol", "", "#ENDETAG#");

	## dann ein Form zum Anlegen einer neuen Kat gleich mit Auswahl
	print &webtag("h3", "class=kateditneutit", "neue Kategorie");
	print &webtag("div", "class=kateditneu", "#EMPTY#");
	if ($keft eq "einzeln") {  ## != alles
		print &webtag("form", "aktion=editfaqkat.pl", "#EMPTY#" );
	}
	print &webtag("select", "name=neunr", "#EMPTY#" );
	foreach $v (@katfrei) {
		if ($v ne "anf�gen") {
			print &webtag("option", "", $v );
		} else {
			print &webtag("option", "value=$katneuende", $v );
		}
	}
	print &webtag("select", "", "#ENDETAG#" );
	print &webtag("input", "type=text\tname=kattit\tsize=$breitlang", "#EMPTY#" );
	print &webtag("input", "type=submit\tname=aktion\tvalue=Neu", "#EMPTY#" );
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
	&webhinweis ("FAQ gesichert.");
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

	local ($breit, $breitkurz, $breitlang, $breitfeld, $hoch) = (20, 5, 40, 50, 8);
	if ($globals{"breit"    }) { $breit     = $globals{"breit"    }; }
	if ($globals{"breitkurz"}) { $breitkurz = $globals{"breitkurz"}; }
	if ($globals{"breitlang"}) { $breitlang = $globals{"breitlang"}; }
	if ($globals{"breitfeld"}) { $breitfeld = $globals{"breitfeld"}; }
	if ($globals{"hoch"     }) { $hoch      = $globals{"hoch"     }; }

	## Problem:
	## 	welche Nr nehm ich bei "neu"?
	## 	muss ich aehnlich Kategorien erst die freien ermitteln?

	## sollte Benutzername/Passwort hier einbringen koennen

	## besser ein form ueber alles


	## Bearbeitungshinweise Pseudocode
	$phinweis=<<PSEUDOHINWEISENDE;
[link=linkziel]Linktitel[/link] - 
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
	

	## welche Kategorie-Nummern sind frei?
	## frei sind auch alle oberhalb der hoechsten Nummer
	$katmax = 1;
	@katfrei = @katvorh = ();
	@katnr = sort(keys(%kat));
	## jetzt ist oben auf @katnr die groesste Zahl
	$katmax = $katnr[$#katnr];

	## hier mu� ich an den Zweck denken.
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
			} else {
				push(@katvorh, "$i $kat{$i}\=$i");
			}
		}
	}
	$katneuende = $katmax + 1;
	## hier geht es nur um @katvorh
	push(@katfrei,"anf�gen=$katneuende");


	## welche FAQ-Nummern sind frei?
	## frei sind auch alle oberhalb der hoechsten Nummer
	$faqmax = 1;
	@faqfrei = @faqvorh = ();
	@faqnr = sort(keys(%tit));
	## jetzt ist oben auf @faqnr die groesste Zahl
	$faqmax = $faqnr[$#faqnr];

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
	push(@faqfrei,"anf�gen=$faqneuende");


	print &webtag("form", "action=faqeditsic.pl\tmethod=post", "#EMPTY#" );

	print &webtag("div", "class=faqedit", "#EMPTY#");
	## Benutzer eingeben
	## 	setzt voraus, dass form alles in einem gemacht wird
	## 	sonst muss es ohne Benutzer arbeiten, dann Kontrollzeile in editfaqkat.pl ausREMen
	## Noch ein Problem:
	## 	bei Passwortabfrage muss ich form auf method=post setzen, sonst ist es gleich umsonst, s.o.
	print &webtag("h3", "class=faqeditchecktit", "Benutzer");
	print &webtag("div", "class=faqeditcheck", "#EMPTY#");
	        print &webtag("p","","#EMPTY#");
	        ## hier koennte man pruefen ob schon eingeloggt
	        ## s.a. ausgabekatedit
	        ## 	wo wird das einloggen ausgewertet? - faqeditsic.pl
	        ## 	das geht weiter zu &isrightdate, 
	        ## 	dort koennte man auch eingeloggte Benutzer hinterlegen
		if ($who = &isdating(&whoamip)) {
			print "Name: " , &rofeld("wer", $who, $breit), " ist eingeloggt \&nbsp; ";
			print &webtag("input", "type=submit\tname=aktion\tvalue=Logout", "#EMPTY#" );
			#return($who);
		} else {
			print "Name: " , &webtag("input", "type=text\tname=wer\tsize=$breit", "#EMPTY#" );
			print "\n \&nbsp; Parole: " , &webtag("input", "type=password\tname=womit\tsize=$breit", "#EMPTY#" );
		}
	        print &webtag("p","","#ENDETAG#");
	print &webtag("div", "", "#ENDETAG#");  ## faqeditcheck

	## Unterschied: 	neu oder vorhanden
	## Ausgabe: 		Nr. (fest bei vorh. und dropdown bei neu), Kategorie (dropdown), Titel, Text
	print &webtag("h3", "class=faqedittit", "Frage " . &webtag("small", &webtag("a", "href=faq.pl?kat=5#faq7\ttarget=_blank\tname=phinweis\ttitle=$phinweis", "(Bearbeitungs-Hinweise)")) );
	if ($nr eq "neu") {
		## (name, selected, feld) ## selected kann auch im feld ueber "=selected" erkannt werden
		print &webtag("p","","#EMPTY#");
		print "\nneue Frage<br>";
		print "\nFAQ-Nr.: ", &HTMLdropdown("nr","", @faqfrei), " \&nbsp; ";
		print "\nKategorie-Nr.: ", &HTMLdropdown("kat","", @katvorh), " <br><br>";
		print "\nFrage: <br>", &inputfeld("tit", "", $breitfeld), " <br>";
		print "\nText: <br>", &inputarea("text", "", $breitfeld, $hoch), " <br>";
		print &webtag("input", "type=submit\tname=aktion\tvalue=Anlegen", "#EMPTY#");
		print &webtag("p","","#ENDETAG#");
	} else {
		if (!($nrkat{$nr})) { &webabbruch ("FAQ-Nr. existiert nicht [$nr]."); }
		print &webtag("p","","#EMPTY#");
		print "\nFAQ-Nr.: ", &rofeld("nr", $nr, $breitkurz), " \&nbsp; ";
		print "\nKategorie-Nr.: ", &HTMLdropdown("kat","", @katvorh), " <br><br>";
		print "\nFrage: <br>", &inputfeld("tit", $tit{$nr}, $breitfeld), " <br>";
		$inh{$nr} =~ s/\x02/\n/ig;
		## Achtung: Probleme mit Entities. 
		## 	Wenn Entities vorhanden sind, werden sie in der Bearbeitung als das jeweilige Zeichen ausgegeben.
		## 	Das Zeichen '&' muss geschuetzt werden.
		## 	Daher das '&' als '&amp;' maskieren.
		## 	Aber dennoch die Variable im uebergebenen Hash nicht veraendern
		$tempstring = $inh{$nr};
		$tempstring =~ s/\&/\&amp;/ig;
		print "\nText: <br>", &inputarea("text", $tempstring, $breitfeld, $hoch), " <br>\n";
		print &webtag("input", "type=submit\tname=aktion\tvalue=�ndern", "#EMPTY#");
		print &webtag("input", "type=submit\tname=aktion\tvalue=L�schen", "#EMPTY#");
		print &webtag("p","","#ENDETAG#");
	}

	print &webtag("div", "", "#ENDETAG#");  ## faqedit

	print &webtag("form", "", "#ENDETAG#" );
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
	## siehe auch blockel in: webtag
	local ($blockel) = "P|H1|H2|H3|H4|H5|H6|UL|OL|PRE|DL|DIV|NOSCRIPT|BLOCKQUOTE|FORM|HR|TABLE|FIELDSET|ADDRESS|TR|TD|TH|FRAME|FRAMESET|NOFRAMES|LI|DD|DT|SELECT|OPTION";
	
	## ein \n vor BR rein, damit man den Quelltext verfolgen kann
    	$text =~ s|\x02|\n<BR>|ig;

    	## Links steuern:
    	## 	nach innen gehende (ohne Protokoll http://) und Mail-Links (mailto:) ohne neues Fenster
    	$text =~ s|\[link=(mailto:[^\]]+)\](.*?)\[\/link\]|<a href="$1">$2<\/a>|ig;
    	$text =~ s~\[link=(http\:\/\/|ftp\:\/\/)([^\]]+)\](.*?)\[\/link\]~<a href="$1$2" target="_blank">$3<\/a>~ig;
    	$text =~ s|\[link=([^\]]+)\](.*?)\[\/link\]|<a href="$1">$2<\/a>|ig;
    	
    	$text =~ s|\[b\](.*?)\[\/b\]|<b>$1<\/b>|ig;
    	$text =~ s|\[i\](.*?)\[\/i\]|<i>$1<\/i>|ig;
    	$text =~ s|\[(\/)?list\]|<$1ul>|ig;
    	$text =~ s|\[\*\]|<li>|ig;
    	$text =~ s|\[(\/)?list=1\]|<$1ol>|ig;
    	$text =~ s|\[list=([1ai])\]|<ol type="$1">|ig;
    	$text =~ s|\[\/list=([1ai])\]|<\/ol>|ig;
    	$text =~ s|\[img=([^\]]+)\]|<img src="$1">|ig;
    	$text =~ s|\[(\/)?code\]|<$1code>|ig;
    	$text =~ s|\[(\/)?quote\]|<$1blockquote>|ig;

	## Ausnahmen/Erweiterungen zu HTML-Input
	## 	Namen/Linkziele
    	$text =~ s|\[name=([^\]]+)\](.*?)\[\/name\]|<a name="$1" id="$1">$2<\/a>|ig;
	
    	## das Umwandeln von \x02 in BR macht viele BR, wo sie nicht noetig sind, z.B. vor allen Blockelementen
    	$text =~ s/<BR>(<\/?($blockel)[ >\t])/$1/ig;

	return ($text);	

}

#---Umwandeln (Pseudocode) einer FAQ in HTML-------------------------------------------
##   - bestimmte HTML-Tags umwandeln in Pseudomarkup
## 	\t		\x20
##    	<BR>		02 (oder 127?)
##    	<a href="xyz">abc</a>		[link=xyz]abc[/link]
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
    	$text =~ s|<b>(.*?)<\/b>|\[b\]$1\[\/b\]|ig;
    	$text =~ s|<i>(.*?)<\/i>|\[i\]$1\[\/i\]|ig;
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

#--- ENDE Alles ------------------------------------
	