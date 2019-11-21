###############################################
##  checkdate.pl
##  Thomas Hofmann, Okt. 2005
##
##  benoetigt irgendwo holpfad0, lass ich mal noch hier drin
##  soll nur den Pfad vom Dateinamen trennen, Zuweisung globaler Variablen ignorieren
##
##  man koennte staendiges Einloggen vermeiden
##  	extra Datei mitfuehren: Name,IP,Zeitstempel
##  	nach Ablauf einer bestimmten Zeit Eintrag entfernen, welche Zeit? 15 min?
##  	wenn IP in Datei dann Benutzer angemeldet
##
## hier koennte man pruefen ob schon eingeloggt
## s.a. &ausgabefaqedit, &ausgabekatedit (in webtools.pl)
## 	wo wird das einloggen ausgewertet? - editfaqkat.pl, faqeditsic.pl
## 	hier koennte man auch eingeloggte Benutzer hinterlegen
##
## dann braucht man eine extra Funktion die prueft, ob der Rechner/IP schon eingeloggt ist.
##
###############################################

#!d:/xampp/perl/bin/perl
#!/usr/bin/perl
sub isrightdate {
	## Rueckgabe: undef = Fehler o falscher user/passwort; 1 = eingeloggt; (sonst) = user
	## 	das dritte brauch ich nicht, der check wird direkt ueber &isdating gemacht.
	local ($check,$for,$rest) = @_;
	local (@within) = ();
	local (%is) = ();
	local ($were) = &holpfad0cd($ENV{"SCRIPT_FILENAME"});
	local ($look) = "date.dat";
	local ($who,$from) = ();
	local ($slash) = "\\";
	
	if ($ENV{'SERVER_SOFTWARE'} =~ m/(unix|linux|rasp|debian)/i) { $slash = "/"; }
	#if ($ENV{'SERVER_SOFTWARE'} =~ m/(unix|microsoft)/i) { $slash = "/"; }
	
	## wenn er schon eingeloggt ist, dann sollte hier der Zeitstempel aktualisiert werden
	## 	sonst muss er sich trotz ständiger Bearbeitung nach der Zeitspanne wieder neu einloggen. 

	## ich muesste zuerst auswerten, ob er(IP) schon eingeloggt ist
#	if ($from = &whoamip_cd) {
#		if ($who = &isdating($from)) {
#			return($who);
#		}
#	}
	## geht das auch kuerzer?
	if ($who = &isdating(&whoamip_cd)) {
		## wenn er schon eingeloggt ist, dann sollte hier der Zeitstempel aktualisiert werden
		## 	sonst muss er sich trotz ständiger Bearbeitung nach der Zeitspanne wieder neu einloggen. 
		&freshdating(&whoamip_cd, time);
		return($who);
	}
	
	
	#print "<p> were slash look: '$were$slash$look'</p>\n";
	if ( !(-e "$were$slash$look") ) {
		#print "<p>!(-e '$were$slash$look')</p>\n";
		return (undef);
	}
	if ( !(open(WHERE, "$were$slash$look")) ) {
		#print "<p>!(open(WHERE, '$were$slash$look')</p>\n";
		return (undef);
	}
	@within = <WHERE>;
	close (WHERE);
	foreach (@within) {
		chop() if (m/\n$/);
		if (m/^.+\:.+$/) {
			($who,$from) = split(/\:/);
			$is{$who}=$from;
		}
	}
	if ( $is{$check} eq crypt($for,join('', reverse(split(//, $look)) )) ) {
		## jetzt hat er sich eingeloggt, jetzt muesste ich den kokolores nur noch schreiben
		&pushdating(&whoamip_cd, $check, time);
		return(1);
	} else {
		#print "<p>is{$check}=[$is{$check}]</p>\n";
		#print "<p>join('', reverse(split(//, $look)) )=".join('', reverse(split(//, $look)) );
		#print "<p>for=$for</p>\n";
		#print "<p>!($is{$check} eq " . crypt($for,join('', reverse(split(//, $look)) )) . ")</p>\n";
		#&webhinweis("B/P passt nicht [$check/$for]");
		return (undef);
	}
}

#---pruefen ob der Rechner/IP schon eingeloggt ist-------------------------------------------

sub isdating {
	## muss ich was uebergeben? IP kann doch intern ermittelt werden
	## 	Schmarrn! ich weiss doch sonst nicht, auf welche IP ich pruefen muss
	## Rueckgabe user
	local ($whom) = $_[0];
	local (%wer, %wann) = ((),());
	local ($were) = &holpfad0cd($ENV{"SCRIPT_FILENAME"});
	local ($secondhand) = "dating.dat";
	local ($where, $who, $when, $someone, $something);
	local ($slash) = "\\";
	
	if ($ENV{'SERVER_SOFTWARE'} =~ m/(unix|linux|rasp)/i) { $slash = "/"; }
	
	## welche Zeitspanne bis Rauswurf? 15 min?
	local ($einestunde)= 3600; 	# 3600 = 1 h
	local ($eineminute)= 60; 	# 60   = 1 min
	local ($einesekunde)= 1; 	# 1    = 1 s
	local ($eintag)    = 86400; 	# 86400= 1 d
	local ($timetolive) = 15 * $eineminute;
	local ($now)       = time; 

	## Aufbau Datei (tab-separated):
	## 	ip, user, zeitstempel
	## einlesen
	if (open(DATING, "$were$slash$secondhand")) {
		everydatinguser:
		while ($something = <DATING>) {
			if ($something =~ m/\n$/i) { chop($something); }
			if ($something eq "") { next everydatinguser; }
			if ($something !~ m/^.+\t.+\t.+$/i) { next everydatinguser; }
			($where, $who, $when) = split(/\t/, $something, 3);
			$wer{$where} = $who; $wann{$where} = $when; 
			## darf ich nicht, sonst tut ich nicht alle ueberalterten rauswerfen, 
			## 	ist das wichtig?
			## 	nein, den aktuell abgefragten hab ich ja
			## 	ich machs doch
			#if ($where eq $whom) { last (everydatinguser); }
		}
		close(DATING);
		## ueberalterte rauswerfen
		foreach $someone(keys(%wann)) {
			if ($wann{$someone} < ($now - $timetolive)) {
				delete $wann{$someone};
				delete $wer{$someone};
			}
		}
		## Ergebnisliste schreiben
		if (open(DATING, ">$were$slash$secondhand")) {
			foreach $someone(keys(%wann)) {
				print DATING "$someone\t$wer{$someone}\t$wann{$someone}\n";
			}
			close (DATING);
		} else {
			&webfehler("Kann Datei nicht schreiben bei [$were$slash$secondhand]. $globals{'adminmes'}");
			## aber nicht return, er soll ja weiter machen
		}
		## auf IP checken, existiert noch ein aktueller Name zu der uebergebenen IP?
		if (defined($wer{$whom})) {
			return($wer{$whom});
		} else {
			return(undef);
		}
	} else {
		return(undef);
	}
}

#---Rechner/IP eingeloggen (merken)-------------------------------------------

sub pushdating {
	## Uebergabe: IP, name, zeit
	## Rueckgabe: Erfolg = 1; Misserfolg = undef;
	## einfach nur dran haengen, sonst nichts tun
	local ($where, $who, $when) = @_;
	local ($were) = &holpfad0cd($ENV{"SCRIPT_FILENAME"});
	local ($secondhand) = "dating.dat";
	local ($slash) = "\\";
	
	if ($ENV{'SERVER_SOFTWARE'} =~ m/(unix|linux|rasp)/i) { $slash = "/"; }
	
	## Aufbau Datei (tab-separated):
	## 	ip, user, zeitstempel

	## an Ergebnisliste anhaengen
	if (open(DATING, ">>$were$slash$secondhand")) {
		print DATING "$where\t$who\t$when\n";
		close (DATING);
		#&webhinweis("Datei geschrieben [$secondhand]"); 
		return(1);
	} else {
		&webfehler("Kann Datei nicht schreiben (anhängen) [$were$slash$secondhand]. $globals{'adminmes'}");
		return(undef);
	}
}

#---IP ausloggen-------------------------------------------

sub killdating {
	## uebergeben? IP
	## Rueckgabe user
	local ($whom) = $_[0];
	local (%wer, %wann) = ((),());
	local ($were) = &holpfad0cd($ENV{"SCRIPT_FILENAME"});
	local ($secondhand) = "dating.dat";
	local ($where, $who, $when, $someone, $something);
	local ($slash) = "\\";
	
	if ($ENV{'SERVER_SOFTWARE'} =~ m/(unix|linux|rasp)/i) { $slash = "/"; }
	
	## ip, user, zeitstempel
	## einlesen
	if (open(DATING, "$were$slash$secondhand")) {
		everykilldatinguser:
		while ($something = <DATING>) {
			if ($something =~ m/\n$/i) { chop($something); }
			if ($something eq "") { next everykilldatinguser; }
			if ($something !~ m/^.+\t.+\t.+$/i) { next everykilldatinguser; }
			($where, $who, $when) = split(/\t/, $something, 3);
			$wer{$where} = $who; $wann{$where} = $when; 
		}
		close(DATING);
		## ueberalterte rauswerfen
		## 	muss ich das hier? noe!
#		foreach $someone(keys(%wann)) {
#			if ($wann{$someone} < ($now - $timetolive)) {
#				delete $wann{$someone};
#				delete $wer{$someone};
#			}
#		}
		## aber DEN einen raus!
		$who = $wer{$whom};
		delete $wer{$whom};
		delete $wann{$whom};
		
		## Ergebnisliste schreiben
		if (open(DATING, ">$were$slash$secondhand")) {
			foreach $someone(keys(%wann)) {
				print DATING "$someone\t$wer{$someone}\t$wann{$someone}\n";
			}
			close (DATING);
			return($who);
		} else {
			&webfehler("Kann Datei nicht schreiben [$were$slash$secondhand]. $globals{'adminmes'}");
			return(undef);
		}
	} else {
		&webfehler("Kann Datei nicht schreiben: [$were$slash$secondhand]. $globals{'adminmes'}");
		return(undef);
	}
}

#---IP Zeitstempel aktualisieren-------------------------------------------

sub freshdating {
	## uebergeben? IP, zeit
	## Rueckgabe user
	local ($wheree, $whenn) = @_;
	local (%wer, %wann) = ((),());
	local ($were) = &holpfad0cd($ENV{"SCRIPT_FILENAME"});
	local ($secondhand) = "dating.dat";
	local ($where, $who, $when, $someone, $something);
	local ($slash) = "\\";
	
	if ($ENV{'SERVER_SOFTWARE'} =~ m/(unix|linux|rasp)/i) { $slash = "/"; }
	
	## ip, user, zeitstempel
	## einlesen
	if (open(DATING, "$were$slash$secondhand")) {
		everyfreshdatinguser:
		while ($something = <DATING>) {
			if ($something =~ m/\n$/i) { chop($something); }
			if ($something eq "") { next everyfreshdatinguser; }
			if ($something !~ m/^.+\t.+\t.+$/i) { next everyfreshdatinguser; }
			($where, $who, $when) = split(/\t/, $something, 3);
			$wer{$where} = $who; $wann{$where} = $when; 
		}
		close(DATING);
		## DEN einen aktualisieren; wenn er nicht existiert, faellt er beim Schreiben raus
		$wann{$wheree} = $whenn;
		## who muss extra definiert werden, sonst letzter Eintrag aus Datei
		## 	wenn er (IP) nicht existiert, dann ist who hiernach undef
		#$who = $wer{$wheree};
		## 	besser unten gleich den Eintrag aus dem Array
		
		## Ergebnisliste schreiben
		if (open(DATING, ">$were$slash$secondhand")) {
			foreach $someone(keys(%wer)) {
				## als Iteration %wer nehmen
				## 	wenn der zu Aktualisierende nicht existiert, faellt er beim Schreiben raus
				print DATING "$someone\t$wer{$someone}\t$wann{$someone}\n";
			}
			close (DATING);
			return($wer{$wheree});
		} else {
			&webfehler("Kann Datei nicht aktualisieren [$were$slash$secondhand]. $globals{'adminmes'}");
			return(undef);
		}
	} else {
		&webfehler("Kann Datei nicht aktualisieren: [$were$slash$secondhand]. $globals{'adminmes'}");
		return(undef);
	}
}

#---trennen des Pfades aus vollstaendiger Pfadangabe mit Dateiname-------------------------------------------

sub holpfad0cd {
## Uebergabe: vollstaendiges Verzeichnis/Dateiname
## Rueckgabe: Verzeichnis ohne Dateiname bzw. letztes Unterverzeichnis
## globale Variablen: nurpfad, nurdat, slash

        local (@par)=@_;
        local (@alles,$vpfad);

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

#---IP des Besuchers feststellen-------------------------------------------

sub whoamip_cd {
## feststellen der IP des Abrufenden im Intranet
## IP-Adresse ueber Environment(REMOTE_ADDR)
	if ($remote_addr = $ENV{ 'REMOTE_ADDR' }) {
		return($remote_addr);
	} else {
		## hier angepasste Variante, kein Abbruch, undef zurueck geben
		#&webabbruch( "Fehler: IP nicht gefunden.");
		return(undef);
	}
}

1;
#---ENDE-------------------------------------------
