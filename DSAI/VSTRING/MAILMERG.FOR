<1>
<2>
<3>
 
Dear <4>;
 
   Our company, Mail Merge International (MMI) wishes to introduce you to our newest mail merge technology.  It uses variable length strings to accomplish the impossible.  No more "string length exceeded" errors when running your mail merge program on a form with run-on paragraphs because some stupid ADT implementation forces strings to be less than 256 characters.  VStrings may be nearly any length (up to memory limits, of course)!  As you can see.  This paragraph is rather long, but presents no real difficulties to the mail merge program. Substitution fields may be placed at any point in the paragraph and the built-in string search functions will find them!  A quick replace and voila!  a new paragraph.  Substitution field number 5 follows this sentence: begin here-><5><<-end here!  Note that substitution fields are integers enclosed in angle brackets.  If you want to place an angle bracket somewhere in the text that is not a substion field marker, simply type two of them: << for example.  The closing bracket '>' need not be duplicated since it always follows a single openning bracket.  Well this paragraph is long enough.  We will end it with a substitution field number 5: <5>
 
   Some day we hope to hire a programmer to actually do word wrap. Our documents don't look very good since this has not been implemented yet.  Maybe you, <4>, could do this for us.  It should be a simple application with all of those nifty VString functions at your disposal.  Simply add a statement to the program to request the max number of characters per line.  Then you can search for the last word that will fit on a line and use the Vsubstr functions to split up the long line into two, one to print, the second to be processed further in case it is too long also.  Of course, you will have to watch out for lines that do not have any spaces in them.  These ought to be split so the first part fills up a line.  Here is a sample of that (assuming the max width is <<=80, this section will be too long): ------------------------------------------------------------------------------------------------------------------------ and will have to be split.
 
   This is the third paragraph and will involve some substitution fields just for fun: <1><2><5><6>.
 
              Sincerely<6>,
 
              <1>
 
<7>
<8>
