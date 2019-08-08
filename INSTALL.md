thofaq - install
====================
little FAQ in Perl - installation instructions
--------------------  

---  
  added to project on GitHub at 08.08.2019 by thomas@th-o.de  

---
**Attention** 

The _INSTALL_ is described under Windows. _Linux_- Users should be able to extrapolate.  

---
1. get a portable **Webserver XAMPP** from 
  [portableapps.com](https://portableapps.com) and install it in dir `D:\XAMPP`
2. get the **sources** from the Github-project 
  [toohoo/thofaq](https://github.com/toohoo/thofaq) , copy them to `D:\xampp\htdocs\faq`
3. Data of the **Backup** (_if present_) in `FAQBAK.zip` , get them and copy all \*.dat to `(full-path-of-faq)\cgi-bin`. Get the images from the archiv `FAQBAK-IMG.zip` contained in the backup and restore them to `(full-path-of-faq)\img`.
4. create an own **user** for editing

---  
How to **create an own** **_user_**
-----------------------
  
  The users are located in file `(full-path-to-faq)/cgi-bin/date.dat` . This file is a `text/plain` file and can be edited with a text-editor.  
  The format is as follows:
```
(username), ':', (coded password)  
```
  For a new user simply add a new line. The `coded password` can be 
  created a new with the script `ct.pl`. Set up the Webserver before
  and then call the script:

[http://localhost/thofaq/cgi-bin/ct.pl](http://localhost/thofaq/cgi-bin/ct.pl)

  For review input the user 
  name at `Kürzel` and at `Zeichenkette` input the desired password. 
  Now hit the button which should be labeled **`LOS!`**
  Following the phrase '->' there in square brackets you can find 
  the `coded password`. Copy this `coded password` and input it leaded 
  by a colon ':' in the line with the username.  

  In same behaviour you can change the `coded password` for an 
  existing user in the file.  
  