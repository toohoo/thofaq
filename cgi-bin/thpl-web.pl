#!D:/xampp/perl/bin/perl
#!/usr/bin/perl
#***************************************************
#       Script-Sammlung Perl - 
#       Thomas Hofmann 
#       Nov 97, Mai 2001
#       Original von Hubert Bender
#***************************************************
#
#---28.06.2000 ACHTUNG! 
#--     Neues Verzeichnis NEUURT unter ARBRECHT wird gebraucht
#
#---Alibi Befehl, sonst liefert ein require auf dieses Script
#---        ein:"thpl.pl did'nt return a true value at line X of X.X"
#$temp = 'C:\\TEMP';
#$page = 0;
#***************************************************
# 21.11.2001 Thomas Hofmann
#       Aenderung. Moeglichkeit der Uebergabe 
#       eines Konfigurations-files.
# 
#       derzeit wird verarbeitet:
#       - Verzeichnisse Gesetze,  Zentral,  Autoren,  Tabellen, Grafiken,  Formeln
#                       getdir_g, getdir_z, getdir_a, getdir_t, getdir_gr, getdir_f
#       - aktuelles Verzeichnis vtemp
#       - Fehlerdateiname errdatn
#       - Fehlerdateiname mit Pfad errdat
#       - Datei-Endungen Tabellen
#         tabend, grafend, formend
#***************************************************
# 08.04.2002 Thomas Hofmann
#       Ergaenzung einer Routine zum Senden einer Mail sendmail
#***************************************************
# 11.04.2002, TH
#       habe das Script sendmalfxx.pl vom Buergernetz auf ubmedia.de gezogen.
#       die Scripte cgi-lib2.pl und my.pl auch
#       Test erfolgreich.
#***************************************************
# 06.05.2002, Thomas Hofmann
#       Umstieg auf sendmail fuer Windows
#       muss erst noch von TSteiger genehmigt werden
#       Liegt in F:\Pm-daten\Thofmann\SENDMAIL
#       als Mailserver ist in der INI Datei UBM_HERMES eingetragen
#***************************************************
# 05.09.2002, Thomas Hofmann
#       entdeckt, dass Marko Wesemann die 2 Lehrpfad-Dateien
#       in ein extra Unterverzeichnis geschoben hat.
#       Er sagt, das muss sein. Nehme Verzeichnis in
#       Liste der Autorenverzeichnisse auf. Wurden 
#       anscheinend bis jetzt nicht geparst.
#***************************************************


$|=1;
$page = 1;

#=====main: get dir / copy / make list / delete======
#   fehlen: ref, gruppe, end-tags,

#===Verzeichnisse holen==================================================

#---Gesetze--------------------------------------

#       &getdir_g();            # gesetze >> @dir
#       &printListe(@dir);
#       foreach $dir (@dir) {system ("copy " . $dir . "\\*.SGM " . $temp)};
#       print @dir;

#---Autoren--------------------------------------

#       &getdir_a();            # autoren (produkt, verzeichnis) >> @p, @v

#       $page = 1;
#       &printListe(@p);
#       $c=<STDIN>;
#       &printListe(@v);
#       $c=<STDIN>;

#       foreach $v (@v) {system ("copy " . $v . "\\*.SGM " . $temp)};
#       print "@p ";
#       print "\n";
#       print "@v ";
#       print "\n";

#---Zentral--------------------------------------#z#

#       &getdir_z();            # zentral >> @zdir
#       #---Ausdruck der Liste
#       &printListe(@zdir);

#===Liste generieren======================================================
#       &head();                                        # head.out
#       &gt();                                          # gt.out (subheadings)
#       &SW();                                          # sw.out
#       &ids_refs();                                    # refs.out, ids.out
#       &SF();                                          # sf.out (refs in documents)
#       &SF_names();                                    # sfn.out (file names)
#       &Aend();                                        # aend.out
#       &UnTag();                                       # (name).out klappt nicht recht !

#===Loeschen temporaere Dateien===============================================

#       system ("del " . $temp . "\\*.SGM");

#*** Ende Hauptteil **********************************************************

#=== Unterprogramme ========================================================

#---Gesetze---

sub getdir_g {
	print "Arbeite: Hole Gesetzesverzeichnis ... ";
	@dir = ('F:\\LEKTORAT\\SGML\\GESETZE',
		#'F:\\LEKTORAT\\SGML\\GESETZE\\TEIL2' #--raus am 11.05.2001
		);

	#-- 21.11.2001
	#local ($test) = $conf{"getdir_g"};
	#&printHash(%conf);
	if (defined($conf{"getdir_g"})) {
		#-- muesste sich eruebrigen
		#@dir = ();
		@dir = split (/\t/, $conf{"getdir_g"} );
		#print "\n[$#dir]\n";
		#<STDIN>;
		#&printListe(@conf);
		#<STDIN>;
		#&printListe(@dir);
		#<STDIN>;
	}

	#---Zeile "Hole Verzeichnis ..." beenden.
	print "\nFertig.\n";

	@dir;
};

#---Zentral------------------------------------------#gz#

sub getdir_z {

	local( @z1dir, $eint);  #lokale Variablen festlegen

	print "Arbeite: Hole Zentralverzeichnis ... ";
	@zdir=();               # initialisieren mit leerem Array
	$zdir = "F:\\LEKTORAT\\SGML\\ZENTRAL";
	$zz=0;                  # Zaehler fuer DIR-Feld
	push (@zdir,$zdir);     # auch "zentral" selbst muss duchsucht werden nach SGM

	if (! opendir (ODIR, $zdir)) {
		print "Fehler beim Lesen von Verzeichnis $zdir\n";
		exit (1);
	};
	@z1dir = readdir(ODIR);
	closedir(ODIR);
	foreach $eint (@z1dir) {        # fuer alle Verz.eintraege von "zentral"
					# wenn =DIR -> merken
		if ((-d "$zdir\\$eint") &&
		    ($eint !~ m/archiv/i) &&
		    ($eint !~ m/^\./)) {
					# "." und ".." ausschliessen
					# .. und archiv
					# Zaehler vor Zuweisung erhoehen
			#---das geht einfacher
			#$zdir[++$zz] = "$zdir\\$eint";
			push(@zdir, "$zdir\\$eint");
		}
	};

	#-- 21.11.2001
	if (defined($conf{"getdir_z"})) {
		@zdir = split (/\t/, $conf{"getdir_z"} );
	}

	#---Zeile "Hole Verzeichnis ..." beenden.
	print "\nFertig.\n";

	#---return @zdir
	@zdir;
};

#---Autoren---

sub getdir_a {

	print "Arbeite: Hole Autorenverzeichnis  ";

	local($verzeichnis, $zentral, $i, $t, $prod, $datei, @produkte,
		@aut, @autu, $_aut, $_autu, $temp, $up, $temp2);

	$verzeichnis = 'F:\LEKTORAT\SGML\AUTOREN';

	#---@produkte initialisieren ... und andere
	@produkte=();
	@v=();
	@p=();

	#---Autoren Verz. auslesen
	if ( !(opendir (AUT, $verzeichnis)) ) {
		&printERR ("Fehler beim Lesen von $verzeichnis\n");
		@produkte = ();
		@v = ();
		goto endegetdir_a;
	}
	@aut = readdir(AUT);
	closedir (AUT);

#-- Autoren komplett umgestaltet am 10.05.2001, TH
#--     nur noch ein Verzeichnis bzw. .\bearb und .\frei
#-- deshalb untiges ausREMen
if (0) { #---ausgeREMt----------------------------------------

	#---... und relevante Verz. ermitteln
	allegetdir_a:
	foreach $_aut (@aut) {
		print ':';
		#print "$_aut\n"; <STDIN>;
		if ( !(opendir (AUTU, "$verzeichnis\\$_aut")) ) {
			&printERR ("Fehler beim Lesen von $verzeichnis\\$_aut\n");
			next allegetdir_a;
		}
		@autu = readdir (AUTU);
		closedir (AUTU);
		$temp = join (' ', @autu);
		$temp .= " ";

		#---"up??" vorhanden
		#---ACHTUNG!! was ist mit GW?
		#--     siehe unten

		#---28.06.2000 ACHTUNG! 
		#--     Neues Verzeichnis NEUURT unter ARBRECHT wird gebraucht
		#--     am besten gleich aufnehmen
		if ($temp =~ m/neuurt /i) {
			push (@v, "$verzeichnis\\$_aut\\neuurt");
		}

		if ($temp =~ m/up(\d\d?) /i) {

			push (@produkte, $_aut);        #---Produkt merken

			#-- wird doch garnicht benoetigt!
			$i = 0;         #--i wird als index fuer index() benutzt

			$up = 1;        #---update auf 1 setzen
					#---...und verarbeiten
			do {
				if (($1 >= $up) &&
				    ($1 ne $up) &&
				    (-d "$verzeichnis\\$_aut\\up$1")) {
					$up = $1;
					print '.';
				}
				$temp =~ s/up//i;
			} while ( $temp =~ m/up(\d\d?) /i );
			#push (@v, "$verzeichnis\\$_aut\\up$up");
			if ( !(opendir (UPDIR, "$verzeichnis\\$_aut\\up$up")) ) {
				&printERR ("Fehler beim oeffnen von $verzeichnis\\$_aut\\up$up");
				next allegetdir_a;
			}
			@updir = readdir (UPDIR);
			closedir (UPDIR);
			foreach $_updir (@updir) {
				#if (-d "$verzeichnis\\$_aut\\up$up$_updir") {
				#--geht nicht, wahrscheinlich Novell
				if ("$_updir" !~ m/\./) {
				#--ist aber gefaehrlich, was ist mit
				#--     Dateien ohne Punkt?
				    push (@v,"$verzeichnis\\$_aut\\up$up\\$_updir")
				}
			}
		} elsif ($temp =~ m/gw /i) {  #---of if 'up'
			push (@produkte, $_aut);        #---Produkt merken

				if (-d "$verzeichnis\\$_aut\\gw") {
					$up = "gw";
					print '.';
				}

			if ( !(opendir (UPDIR, "$verzeichnis\\$_aut\\$up")) ) {
				&printERR ("Fehler beim oeffnen von $verzeichnis\\$_aut\\$up");
				next allegetdir_a;
			}
			@updir = readdir (UPDIR);
			closedir (UPDIR);
			foreach $_updir (@updir) {
				#if (-d "$verzeichnis\\$_aut\\$up$_updir") {
				#--geht nicht, wahrscheinlich Novell
				if ("$_updir" !~ m/\./) {
				#--ist aber gefaehrlich, was ist mit
				#--     Dateien ohne Punkt?
				    push (@v,"$verzeichnis\\$_aut\\$up\\$_updir")
				}
			}

		}  #---of elsif 'gw'
	}                               #---of foreach $_aut
	endegetdir_a:
	@p = @produkte;

} #---ausgeREMt----------------------------------------
#-- Was mach ich jetzt mit Produkte? :-(
	#-- Fehler: (14.05.2001) beim Nachtlauf: doppelte Dateien und IDs
	#--     nur noch frei pruefen
	#--     !!! wieder geaendert, erst bearb dann frei pruefen
	#--     ein Script passt die Fehlerausgabe an.
	push (@v, "$verzeichnis\\bearb");
	push (@v, "$verzeichnis\\frei");
	#-- 05.09.2002
	push (@v, "$verzeichnis\\lehrpfad");

	#-- 21.11.2001
	if (defined($conf{"getdir_a"})) {
		@v = split (/\t/, $conf{"getdir_a"} );
	}

	print "\nFertig.\n";            #---Zeile "Hole Verz. ..." beenden.

#&printListe (@v);
#<STDIN>;
#exit;

	@v;                             #---return @v
};

#---externe Dokumente---

sub getdir_x {
	print "Arbeite: Hole Verzeichnis externe Dokumente ... ";
	@xdir = (
		"F:\\LEKTORAT\\SGML\\EXTERN",
		);

	if (defined($conf{"getdir_x"})) {
		@xdir = split (/\t/, $conf{"getdir_x"} );
	}

	#---Zeile "Hole Verzeichnis ..." beenden.
	print "\nFertig.\n";

	@xdir;
};

#---Tabellen---

sub getdir_t {
	print "Arbeite: Hole Tabellenverzeichnis ... ";
	@tdir = ("F:\\LEKTORAT\\SGML\\GESETZE\\TABELLEN",
		 "F:\\LEKTORAT\\SGML\\AUTOREN\\TABELLEN",
		# 'F:\LEKTORAT\SGML\AUTOREN\SEMINARE' #--Seminare raus am 10.05.2001, TH
		 'F:\LEKTORAT\SGML\AUTOREN\SEMINARE' #--doch wieder rein am 11.05.2001, TH
		);

	#-- 21.11.2001
	if (defined($conf{"getdir_t"})) {
		@tdir = split (/\t/, $conf{"getdir_t"} );
	}

	#-- und Tabellenendungen festlegen,
	@tabend = ('.ANS');

	#-- 21.11.2001
	if (defined($conf{"tabend"})) {
		@tabend = split (/\t/, $conf{"tabend"} );
	}

	#---Zeile "Hole Verzeichnis ..." beenden.
	print "\nFertig.\n";

	@tdir;
};

#---Grafiken---

sub getdir_gr {
	print "Arbeite: Hole Grafikverzeichnis ... ";
	@grdir = ('F:\LEKTORAT\SGML\GESETZE\GRAFIKEN', 
		#'F:\LEKTORAT\SGML\GESETZE\GRAFIKEN\TIF', 
		#'F:\LEKTORAT\SGML\GESETZE\FORMELN',
		'F:\LEKTORAT\SGML\AUTOREN\GRAFIKEN',
		#'F:\LEKTORAT\SGML\AUTOREN\GRAFIKEN\TIF',
		'F:\LEKTORAT\SGML\AUTOREN\GRAFIKEN\WMF',
		#'F:\LEKTORAT\SGML\AUTOREN\FORMELN'
		);

	#-- 21.11.2001
	if (defined($conf{"getdir_gr"})) {
		@grdir = split (/\t/, $conf{"getdir_gr"} );
	}

	#-- und Grafikendungen festlegen,
	#--     theoretisch sollten wir TIF nicht mehr haben
	@grafend = ('.WMF', '.TIF', '.BMP');

	#-- 21.11.2001
	if (defined($conf{"grafend"})) {
		@grafend = split (/\t/, $conf{"grafend"} );
	}

	#---Zeile "Hole Verzeichnis ..." beenden.
	print "\nFertig.\n";

	@grdir;
};

#---Formeln---

sub getdir_f {
	print "Arbeite: Hole Formelverzeichnis ... ";
	@fdir = ('F:\LEKTORAT\SGML\GESETZE\FORMELN', 
		 'F:\LEKTORAT\SGML\AUTOREN\FORMELN');

	#-- 21.11.2001
	if (defined($conf{"getdir_f"})) {
		@fdir = split (/\t/, $conf{"getdir_f"} );
	}

	#-- und Formelendungen festlegen,
	#--     theoretisch sollten wir TIF nicht mehr haben
	@formend = ('.BMP', '.TIF');

	#-- 21.11.2001
	if (defined($conf{"formend"})) {
		@formend = split (/\t/, $conf{"formend"} );
	}
	#---Zeile "Hole Verzeichnis ..." beenden.
	print "\nFertig.\n";

	@fdir;
};



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

#---Trennen des Pfades aus vollstaendiger Pfadangabe-----------------#hp#

sub holpfad {

	local ($vpfad)=@_;
	local (@alles);

		#print ">$vpfad<\n";
	$vpfad =~ m/^(.+)[\\\/](.*)$/;
	if ($1) {
		$nurdat = $2;
		$nurpfad = $1;
	} else {
		$nurdat = $vpfad;
		$nurpfad = '';
	}
		#print "LEER\n" if ($nurpfad eq '') || print ">$nurpfad<\n";
		#print ">$nurdat<\n";

	#---return $nurpfad
	$nurpfad;
}

#---Trennen des Pfades aus Pfadangabe, Rueckgabe Array (pfad,dat)-----------------#pd#

sub pfaddat {

	local ($vpfad)=@_;
	local (@alles, $nurdat, $nurpfad) = "";

		#print ">$vpfad<\n";
	$vpfad =~ m/^(.+)[\\\/](.*)$/;
	if ($1) {
		$nurdat = $2;
		$nurpfad = $1;
	} else {
		$nurdat = $vpfad;
		$nurpfad = '';
	}
		#print "LEER\n" if ($nurpfad eq '') || print ">$nurpfad<\n";
		#print ">$nurdat<\n";

	#---return $nurpfad
	($nurpfad, $nurdat);
}

#---Trennen des Dateinamens von der Erweiterung-----------------#nd#

sub nurdat {

	local ($vpfad)=@_;
	local (@alles);

		#print ">$vpfad<\n";
	$vpfad =~ m/^(.+)[\.](.*)$/;
	if ($2) {
		$nurnam = $1;
		$nurext = $2;
	} else {
		$nurnam = $vpfad;
		$nurext = '';
	}
		#print "LEER\n" if ($nurnam eq '') || print ">$nurpfad<\n";
		#print ">$nurdat<\n";

	#---return $nurnam
	$nurnam;
}

#---Fehlerausgabe---------------------------------------------------
sub printERR {
	local (@mes) = @_;
	open (DAT, ">>$errdat");
	print DAT "$mes[0]";
	if ($mes[0] !~ m/\n$/) { print DAT "\n";}
	close (DAT);
}

#---Fehlerausgabe mit Wort Fehler---------------------------------------------------
sub printERRf {
	local (@mes) = @_;
	open (DAT, ">>$errdat");
	print DAT "Fehler: $mes[0]";
	if ($mes[0] !~ m/\n$/) { print DAT "\n";}
	close (DAT);
}

#---Fehlerausgabe auf Bildschirm------------------------------------
sub fehler {
	local (@mes) = @_;
	print "\n\t---Fehler:[$mes[0]]---\n";

}

#---Fehlerausgabe auf Bildschirm und Fehlerdatei------------------------------------
sub printFehl {
	local (@mes) = @_;
	&fehler($mes[0]);
	&printERR($mes[0]);
}

#---Fehlerausgabe auf Bildschirm und Fehlerdatei mit Wort Fehler (in Datei)------------------------------------
sub printFehlF {
	local (@mes) = @_;
	&fehler($mes[0]);
	&printERRf($mes[0]);
}

#---Reportausgabe---------------------------------------------------
sub printReport {
	local (@mes) = @_;
	open (DAT, ">>$errdat");
	print DAT "$mes[0]";
	if ($mes[0] !~ m/\n$/) { print DAT "\n";}
	close (DAT);
}

#---Reportausgabe auf Bildschirm------------------------------------
sub zeigeReport {
	local (@mes) = @_;
	print $mes[0];
	if ($mes[0] !~ m/\n$/) { print "\n";}
}

#---Reportausgabe auf Bildschirm und Fehlerdatei------------------------------------
sub report {
	local (@mes) = @_;
	&zeigeReport($mes[0]);
	&printReport($mes[0]);
}

#---Loeschen Teilzeichenketten------------------------------------
sub strdel {
#---Parameter:
#--     string, von, wieviel
#--     Achtung! von beginnt mit 0
	local (@par) = @_;

	if ($#par < 0) {
		&printFehl ("strdel: Kein oder zuwenig Parameter [$#par] uebergeben! Richtig: string, von, wieviel");
		die;
	}
	if ($#par > 2) {
		&printFehl ("strdel: Zuviele Parameter [$#par] uebergeben! Richtig: string, von, wieviel");
		die;
	}
	local ($string, $von, $wieviel) = @par;
	local ($bis) = $von + $wieviel; #-- bis ist hier exclusiv, 
					#--     also eigentlich eins nach bis,
					#--     da wo es weitergeht;
					#--     Achtung! beginnt auch bei 0
	local ($len) = length ($string);
	local ($s1, $s2) = ("", "");
	
	if ($von > 0) {
		$s1 = substr($string, 0, $von);
	}
	if ($bis < $len) {
		$s2 = substr($string, $bis);
	}
	
	"$s1$s2";
}

#---Einfuegen Teilzeichenkette-------------------------------------------
sub strins {
#---Parameter:
#--     string, wo, was
#--     Achtung! wo beginnt mit 0 und ist position _vor_ der eingefuegt wird
	local (@par) = @_;

	if ($#par < 0) {
		&printFehl ("strins: Kein oder zuwenig Parameter [$#par] uebergeben! Richtig: string, wo, was");
		die;
	}
	if ($#par > 2) {
		&printFehl ("strins: Zuviele Parameter [$#par] uebergeben! Richtig: string, wo, was");
		die;
	}
	local ($string, $wo, $was) = @par;
	local ($len) = length ($string);
	local ($s1, $s2) = ("", "");
	
	if ($wo > 0) {
		$s1 = substr($string, 0, $wo);
	}
	if ($wo < $len) {
		$s2 = substr($string, $wo);
	}
	
	"$s1$was$s2";
}

#---Ersetzen Teilzeichenkette-------------------------------------------
sub strrepl {
#---Parameter:
#--     string, von, wieviel, womit
#--     Achtung! von beginnt mit 0
	local (@par) = @_;

	if ($#par < 0) {
		&printFehl ("strdel: Kein oder zuwenig Parameter [$#par] uebergeben! Richtig: string, von, wieviel, womit");
		die;
	}
	if ($#par > 3) {
		&printFehl ("strdel: Zuviele Parameter [$#par] uebergeben! Richtig: string, von, wieviel, womit");
		die;
	}
	local ($string, $von, $wieviel, $womit) = @par;
	local ($bis) = $von + $wieviel; #-- bis ist hier exclusiv, 
					#--     also eigentlich eins nach bis,
					#--     da wo es weitergeht;
					#--     Achtung! beginnt auch bei 0
	local ($len) = length ($string);
	local ($s1, $s2) = ("", "");
	
	if ($von > 0) {
		$s1 = substr($string, 0, $von);
	}
	if ($bis < $len) {
		$s2 = substr($string, $bis);
	}
	
	"$s1$womit$s2";
}


#---Konfiguration lesen-------------------------------------------
#-- 21.11.2001
undef(*conf);

sub holconf {
#---Parameter:
#--     Konfigurationsdatei
#--     errdat und vtemp schon selbst neu zuweisen.
#--     Verzeichnisse und Endungen innerhalb der Subroutinen dieses Scripts (s.o.)
	local (@par) = @_;
	local ($k,$v);

	if ($#par < 0) {
		print ("holconf: Kein oder zuwenig Parameter [$#par] uebergeben! Richtig: konfigurations-dateiname-und-pfad\n");
		die;
	}
	$conf = $par[0];
	if (!(-f $conf)) {
		print ("holconf: Konfigurationsdatei [$conf] nicht vorhanden!\n");
		die;
	}

	#-- Konfigurations-Datei $conf
	open (CONF, $conf) || die "Kann Konfigurationsdatei [$conf] nicht lesen!\n";
	while ($z = <CONF>) {
		chop ($z) if ($z =~ m/\n$/i);
	    #-- '#' am Anfang und leere zeile
	    if (($z !~ m/^[ \t]*#/i) && ($z !~ m/^[ \t]*$/i)) {
		if ($z =~ m/\t/i) {
			($k,$v) = split(/\t/, $z, 2);
		} else {
			$k = $z;
			$v = undef();
		}
		#-- Kleinschreibung bei Key
		$k = "\l$k";
		if (defined($conf{$k})) {
			#-- ist die Unterscheidung nach defined und $conf{$k} noetig?
			if ($conf{$k}) {
				if ($v) {
					$conf{$k} .= "\t$v";
				}
			} else {
				if ($v) {
					$conf{$k} = "$v";
				}
			}
		} else {
			$conf{$k} = "$v";
		}
	    }  #-- of '#' am Anfang
	}
	close (CONF);
	
	if ($conf{"vtemp"}) { $vtemp = $conf{"vtemp"}; }
	if ($conf{"errdat"}) { $errdat = $conf{"errdat"}; }
	if ($conf{"errdatn"}) { $errdatn = $conf{"errdatn"}; }

	1;
}

#1;

#***************************************************
# 08.04.2002 Thomas Hofmann
#       Ergaenzung einer Routine zum Senden einer Mail sendmail
#***************************************************

$_aktdir = `cd`;
chop($_aktdir);
$_urldatn = 'chekurl.dat';
$_urldat = "$_aktdir\\$_urldatn";

#1;

#---SUBs-------------------------------------------------
sub sendmail {
#-- Uebergabe: from, subject, text, empfaenger
	local (@par) = @_;
	if ($#par < 3) {  #-- also weniger als 4 Parameter
		local ($temp) = $#par + 1;
		print "Fehler bei SendMail: Weniger als 4 Parameter [$temp]. Abbruch.";
		<STDIN>;
		exit;
	}
	local ($from, $subject, $text, @empfaenger) = @par;
	
	local $text2 = &text2form($text);
	local $wget = "f:\\pm-daten\\thofmann\\tools\\wget2.exe -O - ";
	local $script = "http://www.ubmedia.de/cgi-bin/sendmalfxx.pl";
	local $par = "?from=".$from."\&to=$empfaenger[0]";
	undef ($cc);
	if ($#empfaenger > 0) {
		local $cc = $empfaenger[1];
		for (local $i=2; $i<=$#empfaenger; $i++) {
			$cc .= "+$empfaenger[$i]";
		}
		$par.="\&cc=$cc";
	}
	$par .= "\&subject=" . &text2form("$subject");
	$par .= "\&text=$text2";
	
	#print "---wget[$wget]-- --script[$script]-- --par[$par]--";
	#<STDIN>;
	#<STDIN>;
	
	if (! open(URL, ">$_urldat")) {
		die "Kann URL-Datei [$_urldat] nicht schreiben.\n";
	}
	print URL "$script$par";
	close (URL);
	
	#print "---vor wget---\n";
	$ENV{"0A"} = "\%0A";
	$ENV{"0D"} = "\%0D";
	local $aufruf = `$wget -i $_urldat`;
	#print "---nach wget---\n";
}

#---------------------------------------------

sub text2form {
	local $text = $_[0];
	local ($Ae, $Oe, $Ue, $ae, $oe, $ue, $sz, $sec, $ld, @sz, %sz2, $z, $t, $sz2);
	
	#--Umlaute umsetzen (Entities)
	#--IST DAS WICHTIG?
	#--Hier ja aber nicht beim Einarbeiten
	#--------------------------------
	#--     ist ANSI richtig?
	#--   196         214         220
	$Ae="\xC4"; $Oe="\xD6"; $Ue="\xDC";
	#--   228         246         252
	$ae="\xE4"; $oe="\xF6"; $ue="\xFC";
	#--   223          167
	$sz="\xDF"; $sec="\xA7";
	#---------------------------------
	#--     oder waere ASCII besser?
	#--   142         153         154
	#$Ae="\x8E"; $Oe="\x99"; $Ue="\x9A";
	#--   132         148         129
	#$ae="\x84"; $oe="\x94"; $ue="\x81";
	#--   225           245
	#$sz="\xE1"; $sec="\xF5";
	#--------------------------------
	#--ANSI wie ASCII (ok?)
	#--    34          34
	$ld="\x22"; $rd="\x22";

	@sz = (
		'%', 'ä', 'ü', 'ö', 'Ä', 'Ö', 'Ü', 'ß', 
		'"', '&', ' ', ':', "\n", ',', ';'
	);
	#-- '[', ']' muss ich extra machen

#&printListe(@sz);
#<STDIN>;       

	%sz2 = ();
	#$text =~ s|;|,|ig;
	#$text =~ s|\n|\x0A|ig;
	#$text =~ s|\n| |ig;
	foreach $z (@sz) {
		#print "[$z]";
		#$zz = $z . $z;
		#print "--[$zz]";
		#$t = unpack("Hh", $z . $z);
		#$t = unpack("Hh", $zz);
		#$t = unpack("Hh", 'ää');
		$t = unpack("H", $z) . unpack("h", $z);
		$t = "\U$t";
		#print "--[$t]";
		#<STDIN>;
		$sz2{$z} = $t;

		$text =~ s|$z|\%$t|ig;
	}
	#$text =~ s|\%|\%\%|ig;
	#$text =~ s|\%|\\\%|ig;
	#&printHash(%sz2);
	#<STDIN>;       
	#$text =~ s|\%0A|\%0D|ig;
	#$text =~ s|\%0D|\x0A|ig;
	#$text =~ s|\%0A|\x0A|ig;
	#$text =~ s|\%0D|#0D#|ig;
	#$text =~ s|\%0A|#0A#|ig;
	#$text =~ s|\%0D| \%0D|ig;
	#$text =~ s|\%0A| \%0A |ig;
	
	#--- wget fuer Windows hat hier Probleme mit Texten
	#--     die das Prozentzeichen enthalten. 
	#--     Deshalb Umwandlung aller hex-Codes
	#--     von %XX in Schreibweise _XX_
	#--     Achtung! Das Script auf der Gegenseite muß das
	#--     erst wieder umwandeln.
	$text =~ s|\%([0-9A-F]{2})|_$1_|ig;
	$text;
}

#***************************************************
# 08.04.2002 Thomas Hofmann
#       Ergaenzung einer Routine zum Senden einer Mail sendmail
#       neue Variante mit Sendmail fuer Windows
#***************************************************

sub sendmail2 {
#-- Uebergabe: from, subject, text, empfaenger
	local (@par) = @_;
	if ($#par < 3) {  #-- also weniger als 4 Parameter
		local ($temp) = $#par + 1;
		print "Fehler bei SendMail2: Weniger als 4 Parameter [$temp]. Abbruch.";
		<STDIN>;
		exit;
	}
	local ($from, $subject, $text, @empfaenger) = @par;
	local ($empf) = "$empfaenger[0]";
	#local ($ism2) = 0;
	$empf = join (", ", @empfaenger) if ($#empfaenger > 0);

	#&printERR ("===== sendmail2: subject[$subject] =====\n");
	#&printERR ("\t from[$from] \n");
	#&printERR ("\t text[" . substr($text,0,80) . "] \n");
	#&printERR ("\t Empfaenger ge-join-t[$empf] \n");
	#&printERR ("\t anz[$#empfaenger] \n");
	#for ($ism2 = 0; $ism2 <= $#empfaenger; $ism2++) {
	#	&printERR ("\t\t $ism2\: $empfaenger[$ism2] \n");
	#}

	local $mailprog = "f:\\pm-daten\\hofmannt\\sendmail\\sendmail.exe";

	local ($vorspann) = "From: $from\nTo: $empf\nSubject: $subject\n\n";
	
	if (! open(URL, ">$_urldat")) {
		die "Kann URL-Datei [$_urldat] nicht schreiben.\n";
	}
	print URL "$vorspann$text\n.\n";
	close (URL);
	
	local $aufruf = `$mailprog -t -messagefile=$_urldat -subject=\"$subject\"`;
}


#---------------------------------------------

#***************************************************
# 12.03.2003 Thomas Hofmann
#       Routine zur Eingabe einer vordefinierten Variable
#       Moeglichkeit der Bestaetigung der Variante mit ENTER
#***************************************************

sub eingabe {
#-- Uebergabe: text, variable
#-- Rueckgabe: variable
	local ($var) = $_[1];
	local ($text) = $_[0];
	local ($neu);
	
	print "Bitte eingeben (o. weiter mit ENTER)";
	print "\n";
	print "$text: [$var]";
	print "\n";
	print " " x length($text);
	print "   ";
	$neu = <STDIN>;
	if ($neu ne "\n") {
		$var = $neu;
	}
	#-- Wert zurueck geben
	$var
}
#---------------------------------------------

#---Fehler reportieren------------------------------------------#pe#

#print "defined(\$w=$w)", defined($w), "\n";
if ( !(defined($w)) ) {
	$w = 'f:\lektorat\report\pro';
} elsif ($w eq '') {
	$w = 'f:\lektorat\report\pro';
}
if ( !(defined($errdatn)) ) {
	$errdatn = 'errall.dat';
}
$errdat  = "$w\\$errdatn";

#---------------------------------------------


1;

### ENDE ################################################
