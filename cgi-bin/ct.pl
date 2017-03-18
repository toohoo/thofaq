#!D:/xampp/perl/bin/perl
#!/usr/bin/perl
$|=1;

local $datei = "date.dat";
local $c = local $u = "";

print "Content-type: text/html","\n\n";

print <<KOPFENDE_ct;
<html>
	<head>
	<title>Test C</title>
	</head>
<body>
<h1>Test C</h1>

<form action="ct.pl">
KOPFENDE_ct

local $s = "UB MEDIA AG, 85570 Markt Schwaben, Im Wiegenfeld.4";
$s = "date.dat";
$s = join('', reverse(split(//, $datei)) );

if (&ReadParse(local *ct)) {
	if ( ($c = $ct{"c"}) &&
	     ($u = $ct{"u"})
	   ) {
		print "<p>Kuerzel: <input type='text' name='u' value='$u'></p>\n";
		print "<p>Zeichenkette: <input type='password' name='c' value='$c'></p>\n";
		local $r = crypt($c, $s);
		print "<p>-&gt;: [$r]</p>\n";
		
		print "<p>";
		#print "isrightdate (th,$c): [" . &isrightdate("th", $c) . "]"; ;
		print "isrightdate: [" . &isrightdate($u, $c) . "]"; ;
		print "</p>\n";
	} else {
		$c = $ct{"c"};
		$u = $ct{"u"};
		print "<p>Kuerzel und/oder Zeichenkette fehlt: K:[$u = $ct{'u'}]  Z:[$ct{'c'}]</p>\n";
		print "<p>Kuerzel: <input type='text' name='u' value='$u'></p>\n";
		print "<p>Zeichenkette: <input type='password' name='c' value='$c'></p>\n";
	}
} else {
	print "<p>Kuerzel: <input type='text' name='u' value='$u'></p>\n";
	print "<p>Zeichenkette: <input type='password' name='c' value='$c'></p>\n";
}

print "<p><input type='submit' value='Los!'></p>\n";
print "</form>\n";

#print "<p>";
#print join(':', split(/ */, 'hi there'));
#print "</p>\n";
#
#print "<p>";
#print join(':', split(//, 'hi there'));
#print "</p>\n";


print "</body>\n</html>\n";
exit(0);



# If a variable-glob parameter (e.g., *cgi_input) is passed to ReadParse,
# information is stored there, rather than in $in, @in, and %in.

sub ReadParse {
  local (*in) = @_ if @_;
  local ($i, $key, $val);

  # Read in text
  if (&MethGet) {
    $in = $ENV{'QUERY_STRING'};
  } elsif (&MethPost) {
    read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
  }

  @in = split(/[&;]/,$in); 

  foreach $i (0 .. $#in) {
    # Convert plus's to spaces
    $in[$i] =~ s/\+/ /g;

    # Split into key and value.  
    ($key, $val) = split(/=/,$in[$i],2); # splits on the first =.

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("c",hex($1))/ge;
    $val =~ s/%(..)/pack("c",hex($1))/ge;

    # Associate key and value
    $in{$key} .= "\0" if (defined($in{$key})); # \0 is the multiple separator
    $in{$key} .= $val;

  }

  return scalar(@in); 
}

# MethGet
# Return true if this cgi call was using the GET request, false otherwise

sub MethGet {
  return ($ENV{'REQUEST_METHOD'} eq "GET");
}

# MethPost
# Return true if this cgi call was using the POST request, false otherwise

sub MethPost {
  return ($ENV{'REQUEST_METHOD'} eq "POST");
}

sub isrightdate {
	local ($check,$for,$rest) = @_;
	local (@within) = ();
	local (%is) = ();
	local ($were) = &holpfad0($ENV{"SCRIPT_FILENAME"});
	local ($look) = "date.dat";
	local ($who,$from) = ();
	local ($slash) = "\\";
	
	if ($ENV{'SERVER_SOFTWARE'} =~ m/(unix|linux|rasp)/i) { $slash = "/"; }
	#if ($ENV{'SERVER_SOFTWARE'} =~ m/(unix|microsoft)/i) { $slash = "/"; }
	
	##-- boese Falle, das darf ich nicht, 
	##-- 	es koennte im Hauptprogramm schon der Pfad gewechselt sein
	##-- 	also beim Oeffnen Pfad davor
	#chdir($were);
	
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
		return(1);
	} else {
		#print "<p>is{$check}=[$is{$check}]</p>\n";
		#print "<p>join('', reverse(split(//, $look)) )=".join('', reverse(split(//, $look)) );
		#print "<p>for=$for</p>\n";
		#print "<p>!($is{$check} eq " . crypt($for,join('', reverse(split(//, $look)) )) . ")</p>\n";
		return (undef);
	}
}

sub holpfad0 {
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
