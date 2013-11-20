# MAKE FILE FOR POSTFIX - DSAI PROGRAM 6
 
RUN : postfix.text stack.text
!global txtlib vspascal amplang olist
!LOAD postfix stack
 
postfix.text : postfix.pascal postfix.maclib olist.maclib
!PASC POSTFIX (LIB(POSTFIX OLIST
 
stack.text : stack.pascal postfix.maclib
!PASC STACK (LIB(POSTFIX) NOPRINT
 
 
postfix.maclib : stack.copy sdatadef.copy
!maclib gen postfix stack sdatadef
