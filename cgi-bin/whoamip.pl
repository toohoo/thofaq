#!d:/xampp/perl/bin/perl -w
#!/usr/bin/perl
#######################################################
## whoamip.pl
## feststellen der IP des Abrufenden im Intranet
## Thomas Hofmann, Sep 2005
## IP-Adresse ueber Environment(REMOTE_ADDR)
#######################################################

my $remote_addr;
push(@INC, '.');
if($ENV{'PATH'} =~ m/\\/) {$aktdir = `cd`;} else {$aktdir = `pwd`;} chomp($aktdir);
push(@INC, $aktdir);
my $wai = dowai();
#print "$wai\n";
$wai;
sub dowai {
	if ($remote_addr = $ENV{ 'REMOTE_ADDR' }) {
		if( $remote_addr eq '::1' ) {
			if($^O =~ m/MSWin32/i) {
				my $orgin = $/;
				undef($/);
				my $ipc = `ipconfig`;
				if($ipc =~ m/IPv4-Adresse[ \.]+: ([^ \t\r\n]+)[ \t\r\n]/s) {
					$remote_addr = $1;
				}
				
			}
		}
	return($remote_addr);
	}		elsif($^O =~ m/MSWin32/i) {
				my $orgin = $/;
				undef($/);
				my $ipc = `ipconfig`;
				if($ipc =~ m/IPv4-Adresse[ \.]+: ([^ \t\r\n]+)[ \t\r\n]/s) {
					$remote_addr = $1;
				}
			return($remote_addr);
			
	} else {
		print "\n    <p>    \$^O : [$^O]\n";
		die "Fehler: IP nicht gefunden.";
	}
}
