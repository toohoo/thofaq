# thofaq
## FAQ Changes 03. JUL 2018
**small changes and bugfixes**  

---  
  as on 03. JUL 2018 by thomas@th-o.de  

### Bugfixes

* set correct (actual) categorie on creating a new question  
  from search (yes, this is possible)
* removing some Uninizialized values (no error)

### New Features

* adding possibility to evaluate expressions like Perl  
  internal variables, Math expressions and for small cases  
  matches with regular expressions  

`eval([expression])eval`

### Enhancement mostly for debugging and testing

* adding posibilities for running on (Windows) command line,  
  may also work on Unix/Linux:  
  - process environment variable of `FAQ_PRESET`  
    can serve all parameters for the scripts  
  - avoid bad set command line call with value separator `&`,  
    use `*` instead  
  - correct non existent present dirctory detection on command  
    line call  

