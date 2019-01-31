#!/usr/bin/perl
##########################################
# faq2html.pl - (c) Thomas Hofmann 2019-Jan
# extract the pages (each category) from thofaq project
##########################################

use lib "d:\\work\\perl";
use sniver;

my $testxml = <<__TEST_XML__;
<doc id="my_test_doc">
    <section id="s.1">
        <par id="s.1.1">
            This is par 1.
        </par>
        <par id="s.1.2">
            And this is par 2 of it all.
        </par>
    </section>
</doc>
__TEST_XML__

my $part = getElByID( $testxml, 'id', 's.1.2' );
# test
#print "$part\n\n";

##########################################
# hint:
#   keep in mind to act with overwrite behaviour
# behaviour:
#   get 1st page ( start URL )
#   get contents from categories menu
#   push 1st page to new array ( contents plus title of 1st category )
#   for each found category ( greater than 1; YES, and expect first category _IS_ 1 )
#     get category page n
#     push page n to array
#   end for
#   for each page in array
#     do the replacements
#     save HTML file, name is title ID-fied
#   end for
##########################################

my $startpage   = 'http://localhost/faq/cgi-bin/faq.pl';
my $parkat      = 'kat=';
my $actpage     = '';
my %cattitle    = ();
my %catid       = ();
my %htmlcontent = ();
my $getcommand  = 'wget -O - ';
my $stdout      = 'stdout.txt';
my $stderr      = 'stderr.txt';

##########################################
#   get 1st page ( start URL )
$actpage = qx/$getcommand $startpage 2>$stderr/;
print "Laenge von getpage: ", length( $actpage ), "\n";

##########################################
#   get contents from categories menu
my $menu = getElByID( $actpage, 'class', 'katwahl' );
#print "Menu: \n==========================================\n$menu\n";
my $menuitemsall = getElCont( $menu, 'ol' );
#print "MenuItemsAll: \n==========================================\n$menuitemsall\n";

##########################################
#   push 1st page to new array ( contents plus title of 1st category )
my @menuitem = split( /<\/li>/, $menuitemsall );
print "------------------------------------------\nMenuItem(0): \n$menuitem[0]\n";
#<STDIN>;

my $catstartpos = getElStart( $menuitem[0], 'li' ); # gives what a pity only position - and position should be 0
my $catstart = substr( $menuitem[0], $catstartpos, index( $menuitem[0], '>', $catstartpos ) - $catstartpos + 1 );
print "\tCatStart(0): [$catstart]\n";

# get index
$catstart =~ s/[<>]//g;
my @atts = split( /[ \t]+/, $catstart );
my $elname;
( $elname, @atts ) = @atts;
my ( $k, $v );

# general for print
#foreach my $att ( @atts ) { ($k, $v) = split( /=/, $att ); print "$k = $v\n"; } 
($k, $v) = split( /=/, $atts[0] );
$v =~ s/^"//;
$v =~ s/"$//;
#print "$k = $v\n";

# get 1st title
my $title;
$menuitem[0] .= "</li>"; # is this necessary?
my $titletag = getElCont( $menuitem[0], 'b' );
my $title = $titletag;
$title =~ s/^\*//;
$title =~ s/\*$//;
#print "title(0): [$title]\n";

##########################################
# push really (1st page)
my %cattitle;
my %cattitleid;
my %catcont;

$cattitle{ "$v" } = $title;
$cattitleid{ "$v" } = makeid( $title );
$catcont{ "$v" } = $actpage;
print "cattitleid(0): [$cattitleid{$v}]\n";

	$temp = writefile( "./$cattitleid{$v}.html", $actpage, '0666' );

##########################################
#   for each found category ( greater than 1; YES, and expect first category _IS_ 1 )
my $actidx =  0;
my $actcat =  1;
my ( $temp, $filename );
menuitemsall:
foreach my $item ( @menuitem ) {
    print "*" x 80, "\n"; # ********************************************************************************
    print "*** \t item: $item \n";
    
    # get the category number from menu item
	if( $item =~ m/^[ \t\r\n]*$/ ) { 
		$actidx++; 
		next menuitemsall; 
 	}	# 1st page is already there

##########################################
#     get category page n

	$catstartpos = getElStart( $item, 'li' );
	$catstart = substr( $item, $catstartpos, index( $item, '>', $catstartpos ) - $catstartpos + 1 );
	print "\t*** CatStart($actidx): [$catstart]\n"; 
	#<STDIN>;
	$catstart =~ s/[<>]//g;
	@atts = split( /[ \t]+/, $catstart );
	( $elname, @atts ) = @atts;
	($k, $v) = split( /=/, $atts[0] );
	$v =~ s/^"//;
	$v =~ s/"$//;
	$actcat = $v;
	print "\t>>> actidx[actcat]($actidx [$actcat])\n"; 
	
	if( $actcat =~ m/^1$/ ) { 
		$actidx++; 
		next menuitemsall; 
 	}	# 1st page is already there

	$actpage = qx/$getcommand $startpage?kat=$actcat 2>$stderr/;

	
##########################################
#     push page n to array
	if( $item !~ m/<\/li>\r?\n?$/ ) { $item .= "</li>"; }
	$titletag = getElCont( $item, 'a' );
	$title = $titletag;
	$title =~ s/^\*//;
	$title =~ s/\*$//;
	#print "\t title($actidx): [$title]\n";
	
	$filename = $cattitleid{$v};
	#print "=" x 42, "\n$item\n";

	$cattitle{ "$v" } = $title;
	$cattitleid{ "$v" } = makeid( $title );
	$catcont{ "$v" } = $actpage;
	print "\t titleid($actidx): [$cattitleid{$v}]\n";
    #print "\t catcont($actidx): [". substr( $catcont{$v}, 3000, 500 ) . "]\n";
	#<STDIN>;

##########################################
#   end for
	$actidx++;
}

##########################################
#   for each page in array
my $actcont;
foreach my $pageidx ( sort( keys( %cattitleid ) ) ) {
    

##########################################
#     do the replacements
    #print "\t### cattitleid: " . join( '--', sort( keys( %cattitleid)) ) . "\n";
    $actcont = doreplace( $pageidx, $catcont{ $pageidx }, \%cattitleid );

##########################################
#     save HTML file, name is title ID-fied
	$filename = $cattitleid{ $pageidx };
	$temp = writefile( "./$filename.html", $actcont, '0666' );

##########################################
#   end for
}

##########################################
sub doreplace{
    my( $idx, $cont, $titleids, @rest ) = @_;
    print "\t>>>*** titleids-direct: " . $$titleids{$idx} . "\n";
    
    # the categoty links
    # <a href="faq.pl?kat=2"
    my %titles = %$titleids;
    #print "\t*** titles: " . join( ',,', keys( %titles ) ) . "\n";
    $cont =~ s/(<a href=")faq.pl\?kat=(\d{1,3})"/$1$$titleids{$2}.html"/g;
    
    return( $cont );
}