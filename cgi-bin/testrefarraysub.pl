#!/xampp/perl/bin/perl
# testrefarraysub.pl
# Thomas Hofmann Okt 2005

$scriptname = $ENV{ 'SCRIPT_FILENAME' };
$scriptname = $0;
$aktdir = &holpfad0($scriptname);
push (@INC, $aktdir);
require "thpl.pl";

@a = (1, 2, 3);
@b = ("a", "b", "c");

print "aus Hauptprogramm:\n";
&printListe(@a);
&printListe(@b);
&linie;

<STDIN>;

&arrayref (*a,*b);
<STDIN>;

&arrayrefaend (*a,*b);
<STDIN>;

print "nach arrayref-aend in Hauptprogramm:\n";
&printListe(@a);
&printListe(@b);
&linie;

&arrayrefaend2 (\@a,\@b);
<STDIN>;

print "nach arrayref-aend-2 in Hauptprogramm:\n";
&printListe(@a);
&printListe(@b);
&linie;

##-- SUBs ---------------------------------------------
sub holpfad0 {
        local (@par)=@_;
        local (@alles,$vpfad);

        $vpfad=$par[0];
        $vpfad =~ m/^(.+)([\\\/])(.*)$/;
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

sub linie { print "-" x 40, "\n"; }

sub arrayref {
	local (*x, *y) = @_ if @_;

	print "aus sub arrayref:\n";
	&printListe(@x);
	&printListe(@y);
	&linie;
}


sub arrayrefaend {
	local (*x, *y) = @_ if @_;

	print "aus sub arrayref-aend:\n";
	$x[1]+=2;
	$y[2].="blah";
	&printListe(@x);
	&printListe(@y);
	&linie;
}

sub arrayrefaend2 {
## 	($aref, $bref) = func(\@a, \@b);
	local ($x, $y) = @_;

	print "aus sub arrayref-aend-2:\n";
	$$x[1]+=2;
	$$y[2].="blah";
	&printListe(@$x);
	&printListe(@$y);
	&linie;
}
