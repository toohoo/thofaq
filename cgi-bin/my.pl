#!c:/xampp/perl/bin/perl
#!/usr/bin/perl
$page = 1;

#---Ausdruck einer Liste-----------------#pl#

sub printListe {

        local($z,$za,$c,$c2,$code,$zbs);
        $zbs=25;
        $z=1;$za=1;

foreach (@_) {
#       tr/\//\\/;
# war im Hauptprogramm gedacht zum Ersetzen von "/" durch "\" in DIRs
        if ($page && ($z >= ($zbs - 3))) {
                print "\nENTER = naechste Seite   ".
                        "oder   'e' = Abbruch: ";
                $c=<STDIN>;
                #$code=unpack("c",$c); #geht auch ord()?
                chop($c2=$c);
                if ($c ne "\n" && "e" eq $c2) {exit(0)};
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
        local($z,$za,$c,$c2,$code,$zbs);
        $zbs=25;
        $z=1;$za=1;

foreach (keys %h) {
        if ($page && ($z >= ($zbs - 3))) {
                print "\nENTER = naechste Seite   ".
                        "oder   'e' = Abbruch: ";
                $c=<STDIN>;
                #$code=unpack("c",$c); #geht auch ord()?
                chop($c2=$c);
                if ($c ne "\n" && "e" eq $c2) {exit(0)};
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

        local (@par)=@_;
        local (@alles,$vpfad);

        $vpfad = $par[0] ? $par[0] : '';
        #print ">$vpfad<\n";
        $vpfad =~ m/^(.+)[\\\/](.*)$/;
        if (defined($1)) {
                $nurdat = $2;
                $nurpfad = $1;
        } else {
                $nurdat = $vpfad;
                $nurpfad = '';
        }
        #print "LEER\n" if ($nurpfad eq '') || print ">$nurpfad<\n";
        #print ">$nurdat<\n";
        return ($nurpfad);
}

#---Ausgabe eines Dateiinhaltes-----------------#vd#

sub viewdat {
	local (@par) = @_;
	local ($p1) = $_[0];

	if (-e $p1) {
		print "Content-type: text/plain\n\n",
		      "\"$p1\"\n",
		      "======================================================";
		open (FILE , $p1);
		while (<FILE>) {print};
	} else {
		print "Content-type: text/plain\n\n",
		      "\"$p1\"\n",
		      "======================================================",
		      "Datei nicht vorhanden";
	};
}

#---Verarbeitung QUERY_STRING------------------------------#in#

## Was ist anders als in ReadParse cgi-lib.pl ?
## Es fehlt die Abfrage bei Method=Post

sub in {

  local (*in) = @_ if @_;
  local ($i, $key, $val);

  $in = $ENV{'QUERY_STRING'};

  @in = split(/[&;]/,$in);

#print "<pre>\n";
#&printListe(@in);
#print "</pre>\n";

  foreach $i (0 .. $#in) {
    # Convert plus's to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value.
    ($key, $val) = split(/=/, $in[$i], 2); # splits on the first =.

#print "<pre>\n";
#print "($key,$val)\n";
#print "</pre>\n";

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

#print "<pre>\n";
#print "($key,$val)\n";
#print "</pre>\n";

    # Associate key and value
    $in{$key} .= "\0" if (defined($in{$key})); # \0 is the multiple separator
    $in{$key} .= $val;

  }

#print "<pre>\n";
#&printHash(%in);
#print "</pre>\n";

  return scalar(@in);
};

#---ENDE---------------------------------

1;
