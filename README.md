# thofaq
**little FAQ in Perl**  

---  
  was uploaded on GitHub at 08.03.2016 by thomas@th-o.de  
  first version from about sep 2005

---
**Attention** 

Some files are present with _shebang_ is on `#!C:/xampp/perl/bin/perl` - for the planed running location on drive `D:` it has to be corrected to `#!D:/xampp/perl/bin/perl`  

---
  This should really be a very small FAQ app for someone  
who wants to save some ideas. It's like a personally Knowledge  
Management Tool. It doesn't need a DB. The app is runable on any  
Webserver including a local installation on XAMPP on Windows  
or similar. The development is not going continiously as  
might be expected. The application includes an over all  
search as well as tag-list and tag-cloud. In the difference  
the tag-list is a simple mention whereas the tag-cloud  
has a weight in size, how often the tag is used. The data  
are - at the moment - viewable by everyone but editable  
only from registered users.  
Would be nice if someone does find errors and tell me.  
Have fun.  

**I18n / multi-language**  

The app is multi language able. It was originally written in  
German. A language-file for english is included. For other    
languages the app is extensible. Language files also can be  
stored in **UTF-8**. In this case include a key for that
in language file:

`__encoding__=UTF-8`

The encoding then is set in the application pages. For  
button text use at least the english translation, otherwise  
the application will not work proper. Or the application  
will have be to extended.

```
Neu=New
Ändern=Change
Löschen=Delete
anfügen=append
Anlegen=Create
```

**Attention**  

For use immediately on Windows there is set  
a shebang for correctly work with XAMPP on Windows. The  
assumed prerequest is XAMPP on drive D and perl in  

`/xampp/perl/bin/perl`  

To run it on Linux/Unix just remove the first line at  
the perl scripts.  
The app is tested under Linux/Windows/Raspbian (RaspberryPi).  

**Backup/Extraction to HTML**

For backup/extraction a tool in form of a perl script `faq2html.pl` wass added. Each FAQ category is saved automatically to one HTML page. The links between the categories in the Menu are changed to point to the HTML files.

**Credits**

Thanks to Gabriel (Gabi) Grigorescu for working on the
Romanian language file.

---  
after doing commit  
f96c1eaeed5c495662c83001b954b3ec542f3a91
