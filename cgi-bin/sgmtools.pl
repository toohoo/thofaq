#!/xampp/perl/bin/perl

#***************************************
#	 sgmtools.pl	    t.h. jan 1998
# Tools zum Arbeiten mit SGM-Dateien
#***************************************



# ismixed (ElName)
	# ist das Element mit Name ElName ein Element mit mixed Content?
	# (Vorraussetzung ist vorheriger Aufruf von &holmixed,
	#  wird automatisch ausgefuehrt)

# isleer (ElName)
	# ist das Element mit Name ElName ein leeres Element?
	# (Vorraussetzung ist vorheriger Aufruf von &holleer,
	#  wird automatisch ausgefuehrt)

# elname (El)
	# hole den Element-Name von El

# endeel (Start, Parent)
	# hole aus Zeichenkette Parent die erste Position nach
	# dem Element, das an der Stelle Start beginnt

# bodyofel (El)
	# hole aus Element El alles ohne Anfangs- und Ende-Tag

# elvonid (ID, Text)
	# hole aus Text Element mit ID

# holmixed
	# hole aus Datei mixed.dat Elemente mit mixed Content

# holleer
	# hole aus Datei leer.dat leere Elemente

# liessgm (Pfad, *Var)
	# lese Datei Pfad ein in Variable Var
	# $feld (s.u.) entscheidet ob in Var ein Feld vorliegt oder ein String

# fehler (Nr, Meldung)
	# setzt $fehlmeld auf Fehlermeldung und
	# $fehlnr auf Fehlercode Nr
	# schreibt diese beiden Dinge nocheinmal in $fehldat ans Ende

# abbruch (Nr, Meldung)
	# gibt Fehlermeldung Meldung aus und
	# beendet Programm mit Fehlercode Nr

# idgross (Feld)
	# wandelt alle ID's in Feld in Grossbuchstaben um

# nextnel (Parent, Nr)
	# liefert das Nr-te Unter-Element vom Eltern-Element Parent

# nextwel (String, Nr)
	# liefert das Nr-te Element der Zeichenkette String

# nextnteil (Parent, Nr [, Elterninc])
	# liefert den Nr-ten Teil des Elementes Parent
	# und z„hlt, wenn Elterninc, Elternteilstart um Teilstart-alt hoch

# wortgruppe (parent, erstwort, anzwort)
	# liefert ausgehend von Zeichenkette parent Feld mit:
	# (Position erstwort Wort, Position hinter anzwort Worte ab erstwort)

# wortgruppe2 (parent, erstwort, anzwort)
	# liefert ausgehend von Zeichenkette parent Feld mit:
	# (Position erstwort Wort, Position hinter anzwort Worte ab erstwort)
	# war urspruenglich Ersatz fuer das nicht funktionierende wortgruppe

# report (Meldung)
	# schreibt Meldung in $fehldat ans Ende

# treeloc (Tree, Elter)
	# liefert aus Elter Element/Teilstring entsprechend Tree

# jetztzeit
	# liefert aktuelle Zeit im Format HH:MM:SS

# jetztdatum
	# liefert aktuelles Datum im Format TT.MM.JJJJ

# liesweb (Pfad, *Web)
	# lese Web-File Pfad ein in Array Web
	# $feld (s.o.) wird voruebergehend ausgeschaltet
	# Aufbau:
	#	 zuerst:	(docorsub, z.B.: DOC97)+-(dateiname)
	#	 dann:	      (docorsub)-+(id)-+(treeloc)-+(dataloc)-+(head)-+(note)
	#	 zu unterscheiden: erst '+-' dann '-+' Trenner

# ans2ent (Zeichenkette)
	# wandelt in Zeichenkette spezifische Umlaute und
	# Sonderzeichen in Entities um


#---Vorbelegung Variablen

#-- legt fest, ob in Array eingelesen wird oder in String
$feld = 0;

#-- Zustand fuer Datenfelder ueber leere El. und solche mit Mixed Content
$mixedgeholt = 0;
$leergeholt = 0;

#-- Mitfuehren globaler Variablen fuer Anfang und Ende aktuelle Teilzeichenkette
$globanf = 0;
$globend = 0;
$tagstart = 0;
$teilstart = 0;
$elternteilstart = 0;
$treepos = 0; #---brauch ich wahrscheinlich nicht, mache ich ueber tagstart
$ohnetag = 0;
$slash = "\\" if (!(defined($slash)));
$w = "c:\\temp" if (!(defined($w)));
#--Erlaeuterung siehe nextnteil

#--	   ... sowie fuer letztes entferntes Tag (bodyofel) bzw. uebergangenes
$lasttag = '';
@abnot = ("EMF","EMK","SUB","SUP");

#-- Fehler-Variablen
$fehlmeld = "Kein Fehler";
$fehlnr = 0;
$fehldat = "$w$slash" . "perlfehl.dat";

#---Hochzaehlen umgesetzte Abweichungen & Fehler
$umgesabw = 0;
$fehlanz = 0;
$evi = 0;
$fehltsgm = 0;

#---------------------------------------
sub ismixed {
	local ($eln) = $_[0];
	#-- Zeichenkette mit Name des Elementes uebergeben

	if (!($mixedgeholt)) {
		&holmixed;
	}

	if (index($eln,"\!\[")==0) {
		1;
		#--Marked Sections
	}elsif ($mixed =~ m/ $eln /i) {
		1;
	} else {
		0;
	}
}

#---------------------------------------
sub isleer {
	local ($eln) = $_[0];
	#-- Zeichenkette mit Name des Elementes uebergeben

	if (!($leergeholt)) {
		&holleer;
	}

	if (index($eln,"\!\[")==0) {
		1;
		#--Marked Sections, einfach raus!
	}elsif ($leer =~ m/ $eln /i) {
		1;
	} else {
		0;
	}
}

#---------------------------------------
sub elname {
	local ($el) = $_[0];
	#-- Zeichenkette mit gesammtem Element
	#-- einschliesslich Start- und Endtag

	&fehler (0,'');
	#-- wenn kein Tag am Anfang, dann Fehler
	if (!($el =~ m/^<([^ >\t\r\n]+)[ >\t\r\n]/i)) {
		&fehler (252, "ELNAME-Kein Tag am Anfang: ->$el");
		0;
	} else {
		$1;
	}
}

#---------------------------------------
sub endeel {
	#-- liefert Stelle nach letztem Zeichen von Endetag
	local ($start, $parent) = @_;
	#-- uebergeben :
	#--	   1. Startposition (Stelle erstes Zeichen anfangstag)
	#--	   2. Zeichenkette Elternteil (call by reference)
	local ($anfzk, $anfstart, $tagnam, $temp, $temp2, $schachtel, $tag,$gef,
		$temp3, $temp4, $p, $endeparent, $endestarttag, $len, $endetag);

	&fehler (0,'');
	$len = length ($parent);
	$p = $start;

	#-- wenn kein Tag am Anfang, dann Fehler
	$anfstart = substr ($parent, $start, 80);
	$anfstart =~ s/[\n\t]/ /g;
	
	#print "\n===ENDEEL-START: $start\n";
	#print "----;----1----;----2----;----3----;----4----;----5----;----6----;----7----;----\n";
	#print "$anfstart\n";

	if (!($anfstart =~ m/^ *<([^ >\t\r\n]+)[ >\t\r\n]/i)) {
		if (($anfstart-$len)<10) {
		    if ($len<40) {
			$temp = $parent;
		    } else {
			$temp = substr ($parent, $len-40);
		    }
			&fehler (250, "ENDEEL-Kein Tag an Position '$start' bei Parent-Laenge '$len': ->'$anfstart'\n\tbei Ende Parent:'$temp'");
		} else {
			$temp='';
			&fehler (251, "ENDEEL-Kein Tag an Position '$start' bei Parent-Laenge '$len': ->'$anfstart'");
		}
		0;

	} else { #---of wenn kein Tag am Anfang
		$tagnam = $1;

		if (&isleer ($tagnam) ) { #---leeres Element?------------
			$endetag = index ($parent, '>', $start);
			if ($endetag) {
				++$endetag;
			} else {
				&fehler (249, "ENDEEL-Ende '>' nicht gefunden von Tag '$anfstart'.");
				0;
			}

		} else { #---of isleer-------------

		    $p = index ($parent, '>', $p) + 1;
		    #---Positionszeiger setzen auf hinter Start-Tag

		    do { #---wiederhole bis nicht Schachtel ( -1 )------------------

			$endetag = index ($parent, "</$tagnam>", $p);
			#---Ende suchen ab Pos.

			if ($endetag < 0) { #---kein Endetag gefunden---------
				if (length($parent)<160) {
					if (length($parent)<80) {
						$endeparent='';
					}else{
						$endeparent="\n\.\.\.\n".substr($parent,80);
					}
				}else{
					$endeparent = "\n\.\.\.\n".substr ($parent, length ($parent) - 80);
				}
				$endeparent .= "\nbei p='$p', start='$start' und Laenge parent von '";
				$endeparent .= length($parent) . "'\nentspricht:";
				$endeparent .= substr($parent,$p,80) . ".\n";
				&fehler (248, "ENDEEL-Endetag nicht gefunden von Tag '$tagnam' in '$anfstart$endeparent'.");
				$endetag = 0;
				$schachtel = -1;
				0;

			} else { #---of kein Endetag gefunden---------

				#print "endeel - start/parent: $start / $parent\n";

				#-- Teilzeichenkette von Pos. bis Ende ermitteln
				$len = $endetag - $p;
				$tag = substr ($parent, $p, $len);

				#-- Testausgabe
				#print "---TAG (VON $p, LAENGE $len, BIS ";
				#print $p+$len,"):---\n'";
				#print substr($tag,0,80);
				if (length ($tag) > 160) {
					#print "' -- '",substr ($tag, length($tag)-80);
				}elsif (length ($tag) > 80) {
					#print substr ($tag, 80);
				}
				#print "' -- '", substr ($parent, $endetag, length ("<\/$tagnam>")),"'";
				#print " Ende bei:'",$endetag + length ("<\/$tagnam>");
				#print "'\n";

				#-- Zur Sicherheit Abfangen Gross- Kleinschr.
				#	 also match
				$gef = '';
				#$& = '';
				#$1 = '';

				if ($tag =~ m/<$tagnam[ >\t\n]/i) {
					$gef = $&;
				} else {
					$gef = '';
				}

				#&report ("ENDEEL: tag='$tag'");
				#&report ("ENDEEL: gef='$gef'");
				#$x = index($tag,$gef);
				#&report ("ENDEEL: index='$x'");

				if ($gef) { #--Verschachteles Tag gefunden?-----
				    $schachtel = index ($tag, $gef);
				    $schachtel += $p; #--weil tag nur substr

				    #print "\n-+-+- SCHACHTEL: $schachtel von '$gef' BEI P=$p\n";
				    #print substr($parent,$schachtel,80),"\n";

				    $p = &endeel($schachtel,$parent);
				    if (!$p) {
					$schachtel = -1;
					$endetag = 0;
				    }
				    #print "\nENDE SCHACHTEL: $schachtel";
				    #print " P: $p\n";
				    ##print substr($parent,$schachtel,$p-$schachtel);
				    ##print "\n";

				} else {
				    #-- koennte auch gleich index machen,
				    #	aber s.o.: Gross- Kleinschr.
				    $schachtel = -1;
				    $endetag = $endetag + length ("</$tagnam>");
				}

			} #---end of wenn kein Endetag gefunden------------

		    } until ($schachtel < 0); #-----------------------

		    #print "Ende--ENDEEL: endetag:$endetag/p:$p/tagnam:$tagnam/endestarttag:$endestarttag/\n";
		    $endetag; #---wird bei Fehler vorher auf 0 gesetzt

		} #---end of wenn leer----------------------

	} #---end of wenn kein Tag am Anfang------------

}

#---------------------------------------
sub bodyofel {
	local ($el) = @_;
	#-- Element mit Tags uebergeben
	local ($anf, $len, $temp);

	#---Hier steht: [ \t\n]* fuer Fehlertoleranz
	if ($el !~ m/^[ \t\n]*<([^ >\t\n]+)[ >\t\n]/) {
		$temp = substr ($el, 0, 80);
		&fehler (240, "BODYOFEL-Kein Tag am Anfang von '$temp'.");
		0;
	} else {
		$anf = index ($el, '>') + 1;
		$len = rindex ($el, '<') - $anf;
		$ohnetag += $anf;
		if ($lasttag) {$lasttag .= " \U$1";} else {$lasttag = "\U$1";}
		substr ($el, $anf, $len);
	}
}

#---------------------------------------
sub elvonid {
	local ($id, $text) = @_;
	#-- Uebergeben ist ID und Text
	local ($start, $len, $temp, $suche);

	&fehler (0,'');
	$globanf = 0;
	$globend = 0;
	$tagstart = 0;
	$teilstart = 0;
	$elternteilstart = 0;
	$ohnetag = 0;
	$temp = substr ($text, 0, 80);
	$lasttag = '';
	#print "---ELVONID Anfangstext:'$temp' -- id:'$id'\n";

	if ($text =~ m/ id=\"?$id[ \">]/i) {
		$suche = $&;
		$start = index ($text, $suche);
		if ($start < 0) {
			&fehler (224, "ELVONID - Element mit ID '$id' nicht gefunden in '$temp'.");
			$evi++;
			0;
		} else {
        		$start = rindex ($text, '<', $start);
        		$len = &endeel ($start, $text) - $start;
        		$globanf = $start;
        		$globend = $start + $len;
        		substr ($text, $start, $len);
		}
	} else {
		$suche = '';
		&fehler (247, "ELVONID-Element mit ID '$id' nicht gefunden in '$temp'.");
		$evi++;
		0;
	}
}

#---------------------------------------
sub holmixed {

	&fehler (0,'');

#---Einlesen Elemente mit mixed Content

#-- Datei mit Elementen zu mixed Content
$mixdat = "mixed.dat";

open (DAT, $mixdat) || &abbruch (14, "Datei $mixdat fehlt");
@mixed = <DAT>;
close (DAT);

#-- am Anfang und Ende Leerzeichen
unshift (@mixed, ' ');
push (@mixed, ' ');

#-- Feld nach Zeichenkette
$mixed = join (' ', @mixed);

#-- Speicher Feld freigeben
@mixed = ();

#-- Returns und doppelte Leerzeichen raus
$mixed =~ s/[\r\n]+/ /g;
$mixed =~ s/  +/ /g;

$mixedgeholt = 1;

#-- Grossschreibung
$mixed = "\U$mixed";

}

#---------------------------------------
sub holleer {

	&fehler (0,'');

#---Einlesen leere Elemente

#-- Datei mit leeren Elementen
$leerdat = "leer.dat";

open (DAT, $leerdat) || &abbruch (13, "Datei $leerdat fehlt");
@leer = <DAT>;
close (DAT);

#-- am Anfang und Ende Leerzeichen
unshift (@leer, ' ');
push (@leer, ' ');

#-- Feld nach Zeichenkette
$leer = join (' ', @leer);

#-- Speicher Feld freigeben
@leer = ();

#-- Returns und doppelte Leerzeichen raus
$leer =~ s/[\r\n]+/ /g;
$leer =~ s/  +/ /g;

$leergeholt = 1;

#-- Grossschreibung
$leer = "\U$leer";

}

#---------------------------------------
sub liessgm {

	local ($pfad, *dat) = @_;
	local ($i, $temp, $datpfad);

	&fehler (0,'');

	$datpfad = $pfad;

	if (!(-f $datpfad)) {
		#---Nicht gut, wird evtl.mehrfach hochgezaehlt wegen des
		#	versuchten Oeffnens in verschiedenen Verzeichnissen
		#	--> mach ich doch, muss vorher pruefen (-f $file)
		#	    und/oder selber hochzaehlen
		$fehltsgm++;
		$temp = "LIESSGM-Datei '$datpfad' nicht gefunden bei der".$fehltsgm."\. Datei.";
		#&fehler (253, "LIESSGM-Datei '$datpfad' nicht gefunden.");
		&fehler (253, $temp);
		0;

	} else {

		print "\nLese Datei $datpfad ... ";
		$i = 0;
		@dat = ();
		$dat = '';

		open (DAT, $datpfad);

		if ($feld) {
		#---Variante mit Feld und Lebenszeichen
			print "\n";
			while (<DAT>) {
				$dat[$i++] = $_;
				if ("$i" =~ m/.*[05]00$/) {
					print "Zeile: $i \r";
				}
			}
			$i--;
			print "Zeile: $i \n";

			#-----------------------
		} else {
		#---Variante mit String und ohne Lebensz.

			@dat = ();
			$temp = $/; undef $/;
			$dat[0] = <DAT>;
			$/ = $temp;
			#print "\n----------\n$dat[0]\n----------\n";

		#----------------------------------------
		}

		close (DAT);
		&report ("Datei '$pfad' gelesen");

		print "Fertig!\n";
		1;
	}
}

#----------------------------------------
sub fehler {

	local($fnr,$ftext) = @_;
	#local(FEHLDAT);

	if ($fnr == 0) {
		$fehlmeld = 'Kein Fehler';
		$fehlnr = 0;
	} else {
		$fehlanz++;
		$fehlmeld = $ftext;
		$fehlnr   = $fnr;
		open (FEHLDAT, ">>$fehldat");
		print FEHLDAT "!!--Fehler Nr: $fehlnr\n\t$fehlmeld\n";
		close (FEHLDAT);
	}
}

#----------------------------------------
sub abbruch {
	local($fnr,$ftext) = @_;

	#$fnr = $_[0];
	#$ftext = $_[1];
	print "\nFehler: $ftext Abbruch!\n";

		open (FEHLDAT, ">>$fehldat");
		print FEHLDAT "--Abbruch-Fehler Nr: $fnr\n\t$ftext\n";
		close (FEHLDAT);

	#---Ausgabe Anzahl Abweichungen & Dateien & Fehler
	$temp=$#webf;
	print    "> Anzahl Abweichungen: $temp\n";
	&report ("> Anzahl Abweichungen: $temp");
	$temp = keys(%dats);
	print    "> Anzahl Dateien     : $temp\n";
	&report ("> Anzahl Dateien     : $temp");

	print "\nUmgesetzte Abweichungen: $umgesabw\n";
	&report ("Umgesetzte Abweichungen: $umgesabw");
	print    "Anzahl Fehler          : $fehlanz\n";
	&report ("Anzahl Fehler          : $fehlanz");
	$temp = $#webf-$umgesabw;
	print    "Anz. nicht umges. Abw. : $temp\n";
	&report ("Anz. nicht umges. Abw. : $temp\n");

	print    "nicht gefundene IDs     : $evi\n";
	&report ("nicht gefundene IDs     : $evi");
	print    "nicht gefundene SGM-Dat.: $fehltsgm\n";
	&report ("nicht gefundene SGM-Dat.: $fehltsgm");

	$temp2 = $temp-$evi-$fehltsgm;
	print    "n.umges.-IDfehl-SGMfehl: $temp2\n";
	&report ("n.umges.-IDfehl-SGMfehl: $temp2");

	$temp2 = int( ($umgesabw+$evi+$fehltsgm) / $#webf * 10000)/100;
	print    "Verhaeltnis umges+IDfehler+SGMfehler/n\.umg\.: $temp2\%\n";
	&report ("Verhaeltnis umges+IDfehler+SGMfehler/n\.umg\.: $temp2\%");

	exit ($fnr);
}

#---------------------------------------
sub idgross {
	local ($feld) = $_[0];
	local ($i, $temp);

	#--- ist nicht gut so, muss ganzes Dokument uebergeben (BGB=1,6 MB)
	$feld =~ s/ ID=(\"?)([^ >\"]+)([ >\"])/ ID=$1\U$2\E$3/ig;
	$feld;
}

#---------------------------------------
sub nextnel {
	local ($parent, $nr) = @_;
	local ($i, $ende, $p, $po) = (0, 0, 0, 0);
	local ($temp, $temp2, $anftemp, $endtemp);

	&fehler (0,'');

	$temp = &bodyofel ($parent);
	$ohnetag = 0;
	$temp2 = substr ($temp, 0, 80);
	#print "\n:$temp\n";
	if ($temp eq '0') {
		#-- Fehler in bodyofel: kein Tag am Anfang
		0;
	} elsif ( ($p = index ($temp, '<', $p)) < 0) {
		$ende = 1;
		&fehler (245, "NEXTNEL-Keine Tags vorhanden in '$temp2'.");
		0;
	} else {
		$anftemp = index ($parent, $temp);
		$endtemp = $anftemp + length ($temp);
		while (($i < $nr) && !($ende)) {
			$po = $p;		   #--alten Stand von p merken
			$p = &endeel ($p, $temp); #--das erste mal ist p hier 0
			if ($p == 0) {
				&fehler (243, "NEXTNEL-Kein Ende fuer '$nr' bei '$i' in '$temp2'.");
				$ende = 1;
			} else {
				$i++;
				#print "i:$i\tp:$p\tpo:$po\t";
				#print substr ($temp, $po, $p - $po);
				#print "\n";
			}
		}
		if (!($ende)) {
			#print "->->-> !ende, po'$po', temp[po]'", substr($temp,$po,1),"'";

			while (substr ($temp, $po, 1) =~ m/[ \n\r]/) {
				$po++;
			}
			#print "->->-> po='$po'\n";

			$tagstart = $tagstart + $anftemp + $po;
			#$teilstart = 0;
			#$elternteilstart = 0;
#print "-NEglobanf:$globanf/".
#"globend:$globend/".
#"tagstart:$tagstart/".
#"teilstart:$teilstart/".
#"elternteilstart:$elternteilstart/\n";
			substr ($temp, $po, $p - $po);
		} else {
			0;
		}
	}
}

#---------------------------------------
sub nextwel {
	local ($temp, $nr) = @_;
	local ($i, $ende, $p, $po) = (0, 0, 0, 0);
	local ($temp2, $anftemp, $endtemp);

	&fehler (0,'');

	$temp2 = substr ($temp, 0, 80);
	#print "\n:$temp\n";
	if ( ($p = index ($temp, '<', $p)) != 0) {
		$ende = 1;
		&fehler (244, "NEXTWEL-Kein Tag am Anfang in '$temp2'.");
		0;
	} else {
		while (($i < $nr) && !($ende)) {
			$po = $p;
			$p = &endeel ($p, $temp);
			if ($p == 0) {
				&fehler (231, "NEXTWEL-Kein Ende in '$temp2'.");
				$ende = 1;
			} else {
				$i++;
				#print "i:$i\tp:$p\tpo:$po\t";
				#print substr ($temp, $po, $p - $po);
				#print "\n";
			}
		}
		if (!($ende)) {
			$tagstart = $tagstart + $po;
			$teilstart = 0;
			$elternteilstart = 0;
			substr ($temp, $po, $p - $po);
		} else {
			0;
		}
	}
}

#---------------------------------------
sub nextnteil {
	local ($parent, $nr, $elterninc) = @_;
	local ($i, $ende, $p, $po, $fehl, $tag) =
	      (0,  0,	  0,  0,   0);
	local ($temp, $rest, $nt, $temp2, $starttaglen, $ohnetagalt);

#---Besonderheit Mitzaehlen---
# hier kann ich schlecht mitzaehlen (Positionszeiger),
# wann soll ich bei mehreren Aufrufen die Laenge des Starttag mitzaehlen
#   und wann nicht?
# vielleicht besser Untervariablen,
# das gilt wahrscheinlich auch fuer nextnel/nextwel
# global eindeutig ist nur elvonid
#   danach: nextnel/nextwel	   -> tagstart (jedesmal neu setzen)
#	     nextnteil		 -> teilstart (jedesmal neu setzen)
#----------------------------
# Aerger mit startteil, wenn parent selbst nur Teil
# Mitfuehren elternteilstart
#----------------------------
# wieder Aerger bei wiederholten Aufrufen auf dasselbe Element
# -> Uebergeben ob Eltern hochgezaehlt werden soll in elterninc
#----------------------------

	#---kein Tag am Anfang -> Fehler und Ende
	&fehler (0,'');
	if (!($parent =~ m/^</)) {
		$temp2 = substr ($parent, 0, 80);
		&fehler (246, "NEXTNTEIL-Kein Parent Anfangstag in '$temp2'.");
		$fehl = 1;
		$ende = 1;
	}

	$nt = &elname ($parent);
	$ohnetagalt = $ohnetag;
	$temp = &bodyofel ($parent);
	#$elternteilstart = $ohnetag;
	$ohnetag = $ohnetagalt;
	$starttaglen = index ($parent, $temp);

	#---ACHTUNG! ganz grosse Gemeinheit:
	#-- Umbrueche am Anfang eines Tags mit Mixed Content
	#-- werden wahrscheinlich verschluckt
	#-- besser nochmal Test mit erst ENTER und gleich danach Zeichen
	#$temp =~ s/^\n+//;
	#-- geht leider nicht, muss wegen Positionsmitzaehlung
	#--	   Umbrueche am Anfang drin lassen oder anders abfangen
	while (substr ($temp, $p, 1) eq "\n") {
		$p++;
	}

	$temp .= "</$nt>";
	#print "\n:$temp\n";

	while (($i < $nr) && !($ende)) {
		$po = $p;
		#$teilstart = $p;
		$rest = substr ($temp, $p);
		#print "==> nextnteil - NR: $nr BEI I: $i UND REST: $rest\n";

		#---wenn Ende-Tag erreicht Abbruch und Fehler setzen
		if ( $rest =~ m/^<\/$nt>/i) {
			$ende = 1;
			$fehl = 1;
			&fehler (242, "NEXTNTEIL-Ende-Tag erreicht von '$nt' bei Nr. '$nr' in '$parent'\.");
		} else {

		#---Einrueckung weggelassen-------------------------
		if (substr ($rest,0,1) eq '<') {
			#print "--ELEMENT--\n";
			#---Tag -> Element
			#--  dabei: wenn z.B. emf in P gleich am Anfang,
			#--  wird die Nullzeichenkette vorm emf
			#--  (nicht vorhanden) nicht als ein Teil gezaehlt
			#--   ^-- das stimmt nicht!

			$tag = 1;
			$p = &endeel (0, $rest) + $po;

			#--- Fehler in endeel, da endeel == 0
			#--  also: po + endeel == po
			if ($p == $po) {
				$fehl = 1;
				$ende = 1;
				#&fehler (225, "NEXTNTEIL-Fehler in ENDEEL von '$nt' in '$rest'\.");
			}
		} else {

			#print "--PCDATA--\n";
			#-- kein Tag -> kein Element
			$tag = 0;
			$p = index ($rest, '<') + $po;

			#-- kann nicht sein, dann fehlt Endetag Parent
			#if ($p < 0) {
			#
			#}
		}

		$i++;
		#----------------------------------------------------

		}
	} #---end of while----------------------------------
	if ($i < $nr) {
		$fehl = 1;
		&fehler (229, "NEXTNTEIL: I < NR: nr:$nr/i:$i/rest:$rest/");
		#print "nr $nr; i $i; rest $rest\n";
	}
	if (!($fehl)) {
		#-- siehe Erklaerung oben
		#if (&ismixed ($nt)) {
		if ($elterninc) {
			$elternteilstart += $teilstart;
			#-- ist nicht gut bei mehreren Aufrufen
			#print "ISMIXED ($nt)";
		} else {
			#print "NOT ISMIXED ($nt)";
		}

		$teilstart = ($po + $starttaglen);
		$temp2 = substr ($temp, $po, $p - $po);
		#---ist das richtig, dass ich hier das TAG rausnehme?
		if ($tag) {
			#-- falsch, Tag doch mitliefern
			#&bodyofel ($temp2);
			#-- beachte auch globale Varible ohnetag, s.o.
			$temp2;
		} else {
			$temp2;
		}
	} else {
		0;
	}
}

#---------------------------------------
sub wortgruppe {

	local ($parent, $erstwort, $anzwort) = @_;
	local ($anfi, $endi, $wgtemp, $pos, $iswort, $anfpos, $endpos,
		$wgef, $gef) =
	      (0,     0,     0,       0,    0,	     0,       0,
		0,     0);
	local ($worttrenn) = "\n\t :,\?<>\{\}\[\]\/";
	local (@feld) = ();
	local (@ftemp) = ();
	local ($aktdat) = 'xg005249';

#-----Probleme------------------
#Ein weiterer Stolperstein: Panorama ignoriert teilweise bei Mixed Content
#in Ps verschachtelte REFTXT-e, d. h. es werden lediglich die Worte
#innerhalb des REFTXT-es gez„hlt.
#-------------------------------

	if ( (!($parent)) || ($erstwort<1) || ($anzwort<1) ) {
	    &fehler (220,
	      "WORTGRUPPE: Uebergabe-Fehler parent:$parent/erstwort:$erstwort/anzwort:$anzwort/");
	    (0,0);
	} else {
if ($file =~ m/$aktdat\.sgm/i) {
  $iftemp=(!($parent));
  print "\nWORTGRUPPE: (!(parent:$parent)):$iftemp/\n",
	"(erstwort:$erstwort<1):",($erstwort<1),"/\n",
	"(anzwort:$anzwort<1):",($anzwort<1),"/\n";
  $iftemp=(!($parent) || ($erstwort<1) | ($anzwort<1));
  print "iftemp:$iftemp\n";
  <STDIN>;
}
#---ALLES sonst---------------------------------
	#---erstes Wort finden------------------------------------
	while ( ($anfi<$erstwort) && ($pos<length($parent)) ) {
		#---entweder: erst match auf substr(parent,pos)
		#	 und dann index $&
		#   oder: Zeichen fuer Zeichen (auch substr)
		$wgtemp = substr ($parent, $pos);
		#$&=0;

		if ($iswort) {		      # ist schon Wort -> Trenner suchen

			  if ($wgtemp =~ /([\n\t \?<>\{\}\[\]\\])/) {
			    $gef=$&} else {$gef=''}
		} else {		# ist kein Wort -> Wort suchen

			  if ($wgtemp =~ /([^\n\t \?<>\{\}\[\]\\])/) {
			    $gef=$&} else {$gef=''}
		}
if ($file =~ m/$aktdat\.sgm/i) {
  print "\n(anfi:$anfi<erstwort:$erstwort):",($anfi<$erstwort),
	" && (pos:$pos < (length(parent):",length($parent),":",
	($pos<length($parent)),
	") = ",(($anfi<1) || ($anfi<$erstwort) && ($pos<length($parent))),
	"/\n";;

  print    "Wortgruppe/ erstes Wort: anfi:$anfi/ in(".substr($wgtemp,0,40)."),iswort:$iswort/pos:$pos/gef:$gef/\n";
  &report ("Wortgruppe/ erstes Wort: anfi:$anfi/ in(".substr($wgtemp,0,40)."),iswort:$iswort/pos:$pos/gef:$gef/");

#if($iswort){print "iswort($iswort)-su.Tr."}else{print "iswort($iswort)-su.W. "};
#$ttemp=substr($',0,15);
#print "(`|&|')=($`|$&|$ttemp) -- \$1 ($1), \$+ ($+), wgef ($wgef), gef ($gef)\n";

#print "pos:$pos/gef:$gef/\n";
}

		if ($gef eq '') {
			#-- nix gefunden, -> Fehler
			$pos = length ($parent) + 1;

		} else {
			#-- was gefunden, -> Position ermitteln & pos hochzaehlen
			$pos = index ($parent, $gef, $pos);
			#-- anfpos wird spaeter gesichert

			#--erst Unterscheidung,ob es sich um Tag handelt(s.o.)
			if ($pos>0) {
				$ftemp[0] = substr ($parent, $pos-2, 2);
				$ftemp[1] = substr ($parent, $pos-1, 1);
			} else {
				$ftemp[0] = '';
				$ftemp[1] = '';
			}

			if (($ftemp[1] eq '<') || ($ftemp[0] eq '</')){
				$pos = index ($parent, '>', $pos);
				if ($pos < 0) {
					$pos = length ($parent) + 1;
					$gef = '';
				}

			} else {

				#-- wenn momentan 'kein Wort',
				#	 -> Wort gefunden & hochzaehlen
				if (!$iswort) {$anfi++};

				#-- Schalter (ist gerade Wort) wechseln
				$iswort = !$iswort;
			}

if ($file =~ m/$aktdat\.sgm/i) {
#--- Testausgabe wegen Probleme Mixed Content, s.o.
	print "ft[1]:$ftemp[1]\t";
	print "ft[0]:$ftemp[0]\t";
	print "pos:$pos\t";
	print "anfi:$anfi\tanfpos:$anfpos";
	print "\n";
}

			$anfpos = $pos;

		}

	} #---end of while (erstes Wort)-------------------------------

#print "anfi:$anfi/pos:$pos/anfpos:$anfpos/temp:$wgtemp\n";

	if ($anfi == $erstwort) { # bis hierher ok?
#---Einrueckung weggelassen-----------------------------------

	#---Anzahl Worte weiter-------------------------

	#-- vorher iswort loeschen, da ja das erste gesuchte (erstwort)
	#	 schon gefunden, so wird das aktuelle Wort
	#	 gleich als erstes gefunden

	$iswort = 0;
	while ( ($endi<$anzwort) && ($pos<length($parent)) ) {
		$wgtemp = substr ($parent, $pos);
		#$&=0;

		if ($iswort) {		      # ist schon Wort -> Trenner suchen
			#$&=0;
			if ($wgtemp =~ m/[\n\t \?<>\{\}\[\]\\]/) {
			    $gef=$&} else {$gef=''}

		} else {		# ist kein Wort -> Wort suchen

			if ($wgtemp =~ m/[^\n\t \?<>\{\}\[\]\\]/) {
			    $gef=$&} else {$gef=''}
		}

		if ($gef eq '') {
			#-- nix gefunden, -> Fehler
			$pos = length ($parent) + 1;

		} else {
			#-- was gefunden, -> Position ermitteln & pos hochzaehlen
			$pos = index ($parent, $gef, $pos);
			#-- anfpos wird spaeter gesichert

			#--jetzt Unterscheidung,ob es sich um Tag handelt(s.o.)
			if ($pos>0) {
				$ftemp[0] = substr ($parent, $pos-2, 2);
				$ftemp[1] = substr ($parent, $pos-1, 1);
			} else {
				$ftemp[0] = '';
				$ftemp[1] = '';
			}
#--- Testausgabe wegen Probleme Mixed Content, s.o.
#print "ft[1]:$ftemp[1]\t";
#print "ft[0]:$ftemp[0]\t";
#print "pos:$pos\t";
#print "anfi:$anfi\tanfpos:$anfpos";
#print "\tendi:$endi\tendpos:$endpos";
#print "\n";

			if (($ftemp[1] eq '<') || ($ftemp[0] eq '</')){
				$pos = index ($parent, '>', $pos);
				if ($pos < 0) {
					$pos = length ($parent) + 1;
					$gef = '';
				}

			} else {

				#-- wenn momentan 'kein Wort',
				#	 -> Wort gefunden & hochzaehlen
				if (!$iswort) {$endi++};

				#-- Schalter (ist gerade Wort) wechseln
				$iswort = !$iswort;
			}

		}

	} #---end of while (Anzahl Worte weiter)---------

#print "endi:$endi/pos:$pos/&:$&/wgtemp:$wgtemp\n";

	#--- ok? -> dann Ende Wort ermitteln

	if ($endi == $anzwort) {
		$wgtemp = substr ($parent, $pos);
		#$&=0;
		if ($wgtemp =~ m/[\n\t \?<>\{\}\[\]\\]/ ) {
			$gef=$&} else {$gef=''}

		if ($gef eq '') {
			#-- nix gefunden, -> Fehler
			$endpos = length ($parent) + 1;

		} else {
			#-- was gefunden, -> Position ermitteln & pos hochzaehlen
			$endpos = index ($parent, $gef, $pos);
		}
	}
	#--nur fuer Test
	#else { &fehler (228, "Wortgruppe: endi($endi) <> anzwort($anzwort)."); }

	}
#---end of bis hierher ok (Einrueckung)------------------------------

	if (($anfi != $erstwort) || ($endi != $anzwort)) {
		#---Fehler!
		&fehler (239,"WORTGRUPPE - Falsche Werte, Gesucht: (erstes W.$erstwort), (Anzahl W.$anzwort),\n\tGefunden: (erstes W.$anfi), (Anzahl W.$endi), in Parent:'$parent'.");
		(0,0);
	} else {
		#&fehler (227,"WORTGRUPPE-Werte: erstes Wort '$anfi', Anzahl Worte '$endi'; ".
		#	 "gesucht von '$erstwort' anz '$anzwort'; ".
		#	 "Beginn '$anfpos', Ende '$endpos'\.");
		#@feld = ($anfpos, $endpos);
		#return (@feld);
		($anfpos, $endpos);
	};
#---ENDE ALLES sonst--------------------------------------
	}
}

#---------------------------------------
sub wortgruppe2 {

	local ($parent, $erstwort, $anzwort) = @_;
	local ($anfi, $endi, $wgtemp, $pos, $iswort, $anfpos, $endpos,$wgef) =
		(0, 0, 0, 0, 0, 0, 0, 0);
	local ($worttrenn) = "\n\t \.:,\?<>\(\)\{\}\[\]\\\/";
	local (@feld) = ();

#$1='';$&='';$`='';$'='';
#print "erst:$erstwort/anz:$anzwort/parent:$parent/anfi:$anfi/endi:$endi/wgef:$wgef\n";

	#---erstes Wort finden
	while ( ($anfi<1) || ($anfi<$erstwort) && ($pos<length($parent)) ) {

		$wgtemp = substr ($parent, $pos, 1);

#print "ERSTES-MATCH in($wgtemp),iswort($iswort),anfi($anfi):\n";

		if (index ($worttrenn, $wgtemp) >= 0) {
		#---Zeichen ist Trenner
			if ($iswort) {
			#-- war bis jetzt Wort
				#-- Zeichen gehoert nicht zu Wort
				#	 nur umschalten, neuer Zwischenraum
				$iswort = 0;
			}else{
			#-- war bis jetzt Zwischenraum
				$pos++;
			}
		}else{
		#---Zeichen ist kein Trenner -> Zeichen ist Wort
			if ($iswort) {
			#-- war bis jetzt Wort
				#-- Zeichen gehoert zu Wort
				$pos++;
			}else{
			#-- war bis jetzt Zwischenraum
				#-- Zeichen gehoert nicht zu Zwischenraum
				#	 nur umschalten, neues Wort
				#	hochzaehlen anfi, anfpos merken
				$iswort = 1;
				$anfi++;
				$anfpos = $pos
			}
		}
	} #---end of while (erstes Wort)

	#---Anzahl Worte weiter

	#-- vorher iswort loeschen, da ja das erste gesuchte (erstwort)
	#	 schon gefunden, so wird das aktuelle Wort
	#	 gleich als erstes gefunden
	$iswort = 0;

	while ( ($endi<1) || ($endi<$anzwort) && ($pos<length($parent)) ) {

		$wgtemp = substr ($parent, $pos, 1);

#print "ZWEITES-MATCH in($wgtemp),iswort($iswort):";

		if (index ($worttrenn, $wgtemp) >= 0) {
		#---Zeichen ist Trenner
			if ($iswort) {
			#-- war bis jetzt Wort
				#-- Zeichen gehoert nicht zu Wort
				#	 nur umschalten, neuer Zwischenraum
				$iswort = 0;
			}else{
			#-- war bis jetzt Zwischenraum
				$pos++;
			}
		}else{
		#---Zeichen ist kein Trenner -> Zeichen ist Wort
			if ($iswort) {
			#-- war bis jetzt Wort
				#-- Zeichen gehoert zu Wort
				$pos++;
			}else{
			#-- war bis jetzt Zwischenraum
				#-- Zeichen gehoert nicht zu Zwischenraum
				#	 nur umschalten, neues Wort
				#	hochzaehlen endi
				$iswort = 1;
				$endi++;
			}
		}
#print "endi=$endi=\n";
	} #---end of while (Anzahl Worte weiter)

#print "$endi/\t$pos/\t$&/\t$wgtemp\n";

	#-- ok? -> dann Ende Wort ermitteln

#print "ENDI=$endi=\n";
	if ($endi == $anzwort) {

		while ( ($iswort) && ($pos < length ($parent)) ) {

			$wgtemp = substr ($parent, $pos, 1);

			if (index ($worttrenn, $wgtemp) >= 0) {
			#---Zeichen ist Trenner -> Suche beendet
				#-- war bis jetzt Wort
					#-- Zeichen gehoert nicht zu Wort
					#	 nur umschalten, neuer Zwischenraum
					$iswort = 0;
			}else{
			#---Zeichen ist kein Trenner -> Zeichen ist Wort
				#-- war bis jetzt Wort
					#-- Zeichen gehoert zu Wort
					$pos++;
			}
		} #---end of while (Ende Wort ermitteln)
		#---merken Endeposition
		$endpos = $pos;
	}
	#--nur fuer Test
	else { &fehler (237, "WORTGRUPPE2-endi '$endi' <> anzwort '$anzwort'?"); }

	#---Auswertung und Rueckgabe-----------------------------

#print "ENDI-2=$endi=\n";
	if (($anfi != $erstwort) || ($endi != $anzwort)) {
		#---Fehler!
		&fehler (230,"WORTGRUPPE2-Falsche Werte: erstes Wort '$anfi', Anzahl Worte '$endi'; ".
			"gesucht von '$erstwort', anzahl '$anzwort' in '$parent'\.");
		(0,0);
	} else {
		#&fehler (226,"WORTGRUPPE2-Werte: erstes Wort ($anfi), Anzahl Worte ($endi); ".
		#	 "gesucht von ($erstwort), anzahl ($anzwort); ".
		#	 "Beginn ($anfpos), Ende ($endpos).");
		@feld = ($anfpos, $endpos);
		return (@feld);
		#($anfpos, $endpos);
	};
}

#----------------------------------------
sub report {
	local($ftext) = @_;
	#local(FEHLDAT);

	open (FEHLDAT, ">>$fehldat");
	if ($ftext =~ s|n\.n\.$||i) {
		if ($reportumbruch) {print FEHLDAT "--Report: ";}
		print FEHLDAT "$ftext";
		$reportumbruch = 0;
	} else {
		if ($reportumbruch) {print FEHLDAT "--Report: ";}
		print FEHLDAT "$ftext";
		if ($ftext !~ m/\n$/i) { print FEHLDAT "\n"; }
		$reportumbruch = 1;
	}
	close (FEHLDAT);

	if ($oldreport eq $ftext) {exit}
	$oldreport=$ftext;
}

#---------------------------------------
sub treeloc {
	local ($tree, $elt) = @_;
	local (@treeloc, $erstnr, $temp, $tl, $tn, $el2, $elter, $z);

	&fehler (0, "");
	$ohnetag = 0;
	$elter = $elt;
	$z = 1;
	$temp = substr ($elter, 0, 80);

	@treeloc = split (/ /, $tree);

	$erstnr = shift (@treeloc);

	if ($erstnr != 1) {
		&fehler (238, "TREELOC: ErstNr.'$erstnr' in '$tree' != 1 bei El.:'$temp'");
		0;

	} else {

		while ((@treeloc) && !($fehlnr)) {
			#---fuer alle Elemente der treeloc
			#print "* * * while fuer alle Elemente der TREELOC * * *\n";

			#-- erstes Element der Treeloc-Liste entfernen
			$tl = shift (@treeloc);
			#print "--TREE-$tl-- \t---:\n";

			$tn = &elname ($elter);
			#print "\tTagname Elter: $tn\n";

			if (&ismixed ($tn)) {
				#print "\tISMIXED ($tn)\n";
				$el2 = &nextnteil ($elter, $tl, 1);
			} else {
				#print "\tIS-not-MIXED ($tn)\n";
				#1#
				$el2 = &nextnel ($elter, $tl);
			}
			$elter = $el2;
			#print "\tEL2:'",substr($el2,0,80),"'\n";

			$z++;
		}

		if (!$fehlnr) {
			$el2;

		} else {
			&fehler (236, "Folgefehler TREELOC in '$tree' bei Nr.'$z'='$tl' von '$temp'.");
			0;
		}

	}

}

#---------------------------------------
sub jetztzeit {

	local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
					    localtime(time);
	$mon++;
	$hour ='0'.$hour if ($hour<10);
	$min  ='0'.$min  if ($min<10);
	$sec  ='0'.$sec  if ($sec<10);

	"$hour:$min:$sec";
}

#---------------------------------------
sub jetztdatum {

	local ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
					    localtime(time);
	$mon++;
	$mday ='0'.$mday  if ($mday<10);
	$mon  ='0'.$mon   if ($mon<10);
	$year ='0'.$year  if ($year<10);
	if ($year>70) {$year ='19'.$year} else {$year ='20'.$year};

	"$mday.$mon.$year";
}

#---------------------------------------
sub liesweb {

	local ($pfad, *dat) = @_;
	local ($i, $temp, $datpfad, $altfeld, $ent, $entl, $syst, $systl,
		$temp2, $temp3, @feld, $anker, $ankend,
		$ds, $id, $tl, $dl, $he, $no);

	&fehler (0,'');

	$datpfad = $pfad;

	if (!(-f $datpfad)) {
		&fehler (235, "LIESWEB-Datei '$datpfad' nicht gefunden.");
		0;

	} else {

		#---Einlesen Web-File in Variable

		$altfeld = $feld;
		@feld = ();
		&liessgm ($datpfad, *feld);
		$feld = $altfeld;

		#---alle Dateinamen speichern

		@dat = ();
		$ent = '<!ENTITY ';
		$entl = length ($ent);
		$syst = 'SYSTEM "';
		$systl = length ($syst);
		$i = 0;

		#$i = index ($feld[0], $ent, $i);
		#while ( $i > -1 ) {
		while (($i = index ($feld[0], $ent, $i)) > -1) {
			$i += $entl;
			$temp = index ($feld[0], ' ', $i);
			$temp2 = substr ($feld[0], $i, $temp-$i);
#print "i:'$i'\t";
#print "temp:'$temp'\t";
#print "temp2:'$temp2'\n";

			$i = index ($feld[0], $syst, $i) + $systl;
			$temp = index ($feld[0], '"', $i);
			$temp3 = substr ($feld[0], $i, $temp-$i);

			push (@dat, join('+-', $temp2, $temp3));
			#$i = index ($feld[0], $ent, $i);
		};

		$i = $temp;

		#---Einlesen alle anchor
		#	 ( <doc>'s ignorieren bzw. verknuepfung durch docorsub)

		$anker = '<anchor';
		$ankend = '</anchor>';

		while (($i = index ($feld[0], $anker, $i)) > -1) {

			#-- Anker herausloesen
			$temp = index ($feld[0], $ankend, $i);
			$temp2 = substr ($feld[0], $i, $temp-$i);

			#-- holen docorsub und ID
			if (!($temp2 =~ m/<nmlist docorsub=([^>]+)>([^<]+)<\/nmlist>/)) {
				next;
			}
			$ds = $1;
			$id = $2;

			#-- Treeloc falls vorhanden
			if ($temp2 =~ m/<marklist>([^<]+)<\/marklist>/) {
				$tl = $1;
			} else {
				$tl = '';
			}

			#-- Dataloc falls vorhanden
			if ($temp2 =~ m/<dimlist>([^<]+)<\/dimlist>/) {
				$dl = $1;
			} else {
				$dl = '';
			}
#print "i:'$i'\t";
#print "temp:'$temp'\t";
#print "id:'$id'\t";
#print "tl:'$tl'\t";
#print "dl:'$dl'\n";

			#-- Head
			if ($temp2 =~ m/<head>([^<]+)\n?<\/head>/) {
				$he = $1;
			} else {
				$he = '';
			}

			#-- Note
			if ($temp2 =~ m/<note>([^<]+)\n?<\/note>/) {
				$no = $1;
			} else {
				$no = '';
			}

			#-- wenn Head und Note dann speichern
			if ($he && $no) {
				push (@dat, join('+~',$ds,$id,$tl,$dl,$he,$no));
				$dat[$#dat] =~ s/\n//g;
			}
		} continue {

			#-- i erhoehen fuer naechsten Fund (ankend)
			$i = $temp;
		};

		#---Return ok
		1;

	}

#---Im Hauptprogramm bzw. aufrufender Routine noch auseinandernehmen
#	 aehnlich wie:
#	 #-- auseinandernehmen Feld, konkret: Dateien raus
#	 %dats = ();
#	 while ($webf[0] =~ m/\+\-/) {
#		 @test = split (/\+\-/, shift (@webf));
#		 $dats {$test[0]} = $test[1];
#	 };
#
#	 &printHash (%dats);
#	 &printListe (@webf);

}

#---------------------------------------
sub ans2ent {
	local ($zk) = @_;

	if ($zk eq '') {
		&fehler (233, "ANS2ENT: Zeichenkette leer.");
	}

	$zk =~ s/\xE4/&auml;/g;		#-- \xE4 \228 ä
	$zk =~ s/\xF6/&ouml;/g;		#-- \xF6 \246 ö
	$zk =~ s/\xFC/&uuml;/g;		#-- \xFC \252 ü
	$zk =~ s/\xC4/&Auml;/g;		#-- \xC4 \196 Ä
	$zk =~ s/\xD6/&Ouml;/g;		#-- \xD6 \214 Ö
	$zk =~ s/\xDC/&Uuml;/g;		#-- \xDC \220 Ü
	$zk =~ s/\xDF/&szlig;/g;	#-- \xDF \223 ß
	$zk =~ s/\xD7/&times;/g;	#-- \xD7 \215 ×
	$zk =~ s/\xB0/&deg;/g;		#-- \xB0 \176 °
	$zk =~ s/\x94/&rdquo;/g;	#-- \x94 \148 ”
	$zk =~ s/\x93/&ldquo;/g;	#-- \x93 \147 “
	$zk =~ s/\xBD/&frac12;/g;	#-- \xBD \189 ½
	$zk =~ s/\x5B/&lsqb;/g;		#-- \x5B \091 [
	$zk =~ s/\x5D/&rsqb;/g;		#-- \x5D \093 ]

	$zk;
}

#---------------------------------------
sub attlist {
	local ($el) = $_[0];
	local (%att,@att,$att,$k,$v)= ();

	&fehler (0,'');
	#-- wenn kein Tag am Anfang, dann Fehler
	if (!($el =~ m/^<([^ >\t\r\n]+)([ \t\r\n]+[^>]+)?>/i)) {
		&fehler (254, "ATTLIST-Kein Tag am Anfang: ->$el");
		#-- Rueckgabe 0
		return (());
	} else {
		$att = $2;
		$att =~ s|[\t\r\n]| |ig;
		$att =~ s|  +| |ig;
		@att = split (/ /, $att);
		foreach (@att) {
			if ( m/=/i) {
				($k, $v) = split(/=/, $_, 2);
				$v =~ s|^"||i;
				$v =~ s|"$||i;
				#-- in Kleinschreibung (wir haben SGML)
				$k = "\L$k";
				$att{$k} = $v;
			}
		}
		#-- Rueckgabe Hash
		return(%att);
	}
}



#	 -= ENDE =-
	$reportumbruch = 1;
	1;

#=======================================
