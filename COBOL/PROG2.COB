//PROGRAM2   JOB  67029,'3794NAVEEA',CLASS=H,MSGLEVEL=(2,0)                     
//DEBUG       EXEC COB85DBG                                                     
      *                                                                         
       IDENTIFICATION DIVISION.                                                 
                                                                                
       PROGRAM-ID.         PROG2.                                               
       AUTHOR.             ERICK NAVE.                                          
       INSTALLATION.       PROGRAMMING APPLICATIONS WITH COBOL.                 
       DATE-WRITTEN.       3/7/96.                                              
       DATE-COMPILED.                                                           
      *                                                                         
      ****************************************************************          
      *REMARKS.                                                                 
      *                                                                         
      *  PROGRAM 1 PRINTS AN INVENTORY REDUCTION LIST SHOWING ALL OF            
      *    THE WAREHOUSE PARTS AND THEIR ACTIVITY FOR THE FIRST 6               
      *    MONTHS OF THE YEAR.                                                  
      *                                                                         
      *  FILES:                                                                 
      *    INVENTORY-DATA-FILE                                                  
      *    INVENTORY-REPORT-FILE                                                
      ****************************************************************          
      *                                                                         
      ****************************************************************          
      *CHANGES - 3/7/96                                                         
      *                                                                         
      *  PROGRAM 2 VALIDATES THE INVENTORY REDUCTION FILE.  IT WILL             
      *    LIST THE VALID RECORDS IN THE INVENTORY-REPORT-FILE.  IT             
      *    WILL LIST THE INVALID RECORDS IN AN ERROR REPORT FILE.               
      *                                                                         
      *  NEW FILE:                                                              
      *        ERR-REPORT-FILE.                                                 
      ****************************************************************          
                                                                                
      /                                                                         
      ****************************************************************          
       ENVIRONMENT DIVISION.                                                    
      ****************************************************************          
                                                                                
       CONFIGURATION SECTION.                                                   
      *SOURCE-COMPUTER.    IBM-370.                                             
      *OBJECT-COMPUTER.    IBM-370.                                             
                                                                                
       SPECIAL-NAMES.                                                           
                C01 IS TOP-OF-PAGE.                                             
                                                                                
       INPUT-OUTPUT SECTION.                                                    
                                                                                
       FILE-CONTROL.                                                            
           SELECT INVENTORY-DATA-FILE      ASSIGN TO UT-S-READER.               
           SELECT INVENTORY-REPORT-FILE    ASSIGN TO UT-S-PRINTER.              
           SELECT ERR-REPORT-FILE          ASSIGN TO UT-S-PRINTER2.             
                                                                                
      /                                                                         
      ****************************************************************          
       DATA DIVISION.                                                           
      ****************************************************************          
                                                                                
      *---------------------------------------------------------------          
       FILE SECTION.                                                            
      *---------------------------------------------------------------          
                                                                                
      * INVENTORY-DATA-FILE       ------->     INPUT                            
       FD  INVENTORY-DATA-FILE                                                  
           RECORDING MODE IS F                                                  
           LABEL RECORDS ARE STANDARD                                           
           RECORD CONTAINS 80 CHARACTERS                                        
           BLOCK CONTAINS 0 RECORDS                                             
           DATA RECORD IS INVENTORY-DATA-REC.                                   
                                                                                
       01  INVENTORY-DATA-REC              PIC X(80).                           
                                                                                
      * INVENTORY-REPORT-FILE     ------->     OUTPUT                           
       FD  INVENTORY-REPORT-FILE                                                
           RECORDING MODE IS F                                                  
           LABEL RECORDS ARE OMITTED                                            
           RECORD CONTAINS 133 CHARACTERS                                       
           BLOCK CONTAINS 0 RECORDS                                             
           DATA RECORD IS INVENTORY-REPORT-REC.                                 
                                                                                
       01  INVENTORY-REPORT-REC            PIC X(133).                          
                                                                                
      * ERR-REPORT-FILE          -------->     OUTPUT                           
       FD  ERR-REPORT-FILE                                                      
           RECORDING MODE IS F                                                  
           LABEL RECORDS ARE OMITTED                                            
           RECORD CONTAINS 133 CHARACTERS                                       
           BLOCK CONTAINS 0 RECORDS                                             
           DATA RECORD IS ERR-REPORT-REC.                                       
                                                                                
       01  ERR-REPORT-REC                  PIC X(133).                          
                                                                                
      *---------------------------------------------------------------          
       WORKING-STORAGE SECTION.                                                 
      *---------------------------------------------------------------          
                                                                                
       77  LINE-CTR        VALUE ZEROS     PIC S99.                             
       77  ERR-LINE-CTR    VALUE ZEROS     PIC S99.                             
                                                                                
       77  EOF-IND                         PIC X.                               
                                                                                
       77  ERROR-IND                       PIC X.                               
                                                                                
      * TOP OF PAGE INDICATORS FOR REPORTS                                      
       77  INV-TOP                         PIC X.                               
       77  ERR-TOP                         PIC X.                               
                                                                                
      * INV-IN-REC IS THE FIELD BREAKDOWN FOR INVENTORY-DATA-REC                
      *    IT IS THE RESTRUCTURING OF THE INPUT RECORD.                         
       01  INV-IN-REC.                                                          
           03 FILLER       VALUE SPACE     PIC X.                               
           03 WAREHOUSE-NO-IN.                                                  
              05 WCHAR1                    PIC X.                               
              05 WCHAR2                    PIC X.                               
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 PART-NO-IN                   PIC X(5).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 PART-DESC-IN                 PIC X(20).                           
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 UNIT-PRICE-IN                PIC S999V999.                        
           03 FILLER       VALUE SPACE     PIC X.                               
           03 QUANTITY-SOLD-IN.                                                 
              05 QS-JAN-IN                 PIC 9(4).                            
              05 QS-FEB-IN                 PIC 9(4).                            
              05 QS-MAR-IN                 PIC 9(4).                            
              05 QS-APR-IN                 PIC 9(4).                            
              05 QS-MAY-IN                 PIC 9(4).                            
              05 QS-JUN-IN                 PIC 9(4).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 LAST-SALE-DATE-IN.                                                
              05 LSD-YR-IN                 PIC 99.                              
              05 LSD-MO-IN                 PIC 99.                              
              05 LSD-DAY-IN                PIC 99.                              
           03 DATE-RECEIPT-IN.                                                  
              05 DR-MO-IN                  PIC 99.                              
              05 DR-DAY-IN                 PIC 99.                              
              05 DR-YR-IN                  PIC 99.                              
           03 FILLER       VALUE SPACE     PIC X.                               
                                                                                
      * INV-OUT-REC IS THE FIELD BREAKDOWN FOR INVENTORY-REPORT-REC             
      *    IT IS THE RESTRUCTURING OF THE OUTPUT RECORD.                        
       01  INV-OUT-REC.                                                         
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 WAREHOUSE-NO-OUT             PIC XX.                              
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 PART-NO-OUT                  PIC X(5).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 PART-DESC-OUT                PIC X(20).                           
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 UNIT-PRICE-OUT               PIC $$$9.999.                        
           03 FILLER       VALUE SPACES    PIC X(4).                            
      * QUANTITY-SOLD (QS) VALUES FOR JANUARY - JUNE                            
           03 QS-JAN-OUT                   PIC ZZZ9.                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-FEB-OUT                   PIC ZZZ9.                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-MAR-OUT                   PIC ZZZ9.                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-APR-OUT                   PIC ZZZ9.                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-MAY-OUT                   PIC ZZZ9.                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-JUN-OUT                   PIC ZZZ9.                            
           03 FILLER       VALUE SPACES    PIC XXX.                             
      * LAST SALE DATE (LSD)                                                    
           03 LSD-MO-OUT                   PIC 99.                              
           03 FILLER       VALUE '/'       PIC X.                               
           03 LSD-DAY-OUT                  PIC 99.                              
           03 FILLER       VALUE '/'       PIC X.                               
           03 LSD-YR-OUT                   PIC 99.                              
           03 FILLER       VALUE SPACES    PIC X(4).                            
      * DATE OF LAST RECEIPT (DR)                                               
           03 DR-MO-OUT                    PIC 99.                              
           03 FILLER       VALUE '/'       PIC X.                               
           03 DR-DAY-OUT                   PIC 99.                              
           03 FILLER       VALUE '/'       PIC X.                               
           03 DR-YR-OUT                    PIC 99.                              
           03 FILLER       VALUE SPACES    PIC X(26).                           
                                                                                
      * HEADING FOR THE INV REPORT WITH DATE IN UPPER RIGHT CORNER              
       01  REPORT-HEADING.                                                      
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC X(37).                           
           03 FILLER                       PIC X(34)                            
              VALUE 'INVENTORY REDUCTION HISTORY - LIST'.                       
           03 FILLER       VALUE SPACES    PIC X(26).                           
           03 FILLER                       PIC X(13)                            
              VALUE 'REPORT DATE: '.                                            
           03 REPORT-DATE.                                                      
              05 REPORT-MONTH              PIC XX.                              
              05 FILLER    VALUE '-'       PIC X.                               
              05 REPORT-DAY                PIC XX.                              
              05 FILLER    VALUE '-'       PIC X.                               
              05 REPORT-YEAR               PIC XX.                              
           03 FILLER       VALUE SPACES    PIC X(14).                           
                                                                                
      * SYS-DATE IS THE SYSTEM DATE OBTAINED THROUGH ACCEPT                     
      *   IT WILL BE USED FOR THE REPORT DATE                                   
       01  SYS-DATE.                                                            
           03 SYS-YEAR                     PIC XX.                              
           03 SYS-MONTH                    PIC XX.                              
           03 SYS-DAY                      PIC XX.                              
                                                                                
      * TOP OF 2 LINE COLUMN HEADING FOR INVENTORY REPORT                       
       01  COLHDG-TOP.                                                          
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC X(53).                           
           03 FILLER                       PIC X(28)                            
              VALUE 'QUANTITY SOLD FOR MONTH OF:'.                              
           03 FILLER       VALUE SPACES    PIC X(6).                            
           03 FILLER                       PIC X(7)                             
              VALUE 'DATE OF'.                                                  
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER                       PIC X(12)                            
              VALUE 'DATE OF LAST'.                                             
           03 FILLER       VALUE SPACES    PIC X(23).                           
                                                                                
      * SECOND LINE OF 2 LINE COLUMN HEADING FOR INVENTORY REPORT               
       01  COLHDG-BOTTOM.                                                       
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 FILLER       VALUE 'WHSE'    PIC X(4).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 FILLER       VALUE 'PART'    PIC X(4).                            
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER                       PIC X(16)                            
              VALUE 'PART DESCRIPTION'.                                         
           03 FILLER       VALUE SPACES    PIC X(6).                            
           03 FILLER                       PIC X(10)                            
              VALUE 'UNIT PRICE'.                                               
           03 FILLER       VALUE SPACES    PIC XXXX.                            
           03 FILLER       VALUE 'JAN'     PIC XXX.                             
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER       VALUE 'FEB'     PIC XXX.                             
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER       VALUE 'MAR'     PIC XXX.                             
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER       VALUE 'APR'     PIC XXX.                             
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER       VALUE 'MAY'     PIC XXX.                             
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER       VALUE 'JUN'     PIC XXX.                             
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 FILLER                       PIC X(9)                             
              VALUE 'LAST SALE'.                                                
           03 FILLER       VALUE SPACES    PIC X(4).                            
           03 FILLER       VALUE 'RECEIPT' PIC X(7).                            
           03 FILLER       VALUE SPACES    PIC X(24).                           
                                                                                
      * ERR-OUT-REC IS THE FIELD BREAKDOWN FOR ERR-REPORT-REC                   
       01  ERR-OUT-REC.                                                         
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 ERRREC                       PIC X(80).                           
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 ERRMSG                       PIC X(45).                           
           03 FILLER       VALUE SPACES    PIC XX.                              
                                                                                
      * HEADING FOR THE ERR REPORT WITH DATE IN UPPER RIGHT CORNER              
       01  ERR-REPORT-HEADING.                                                  
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC X(37).                           
           03 FILLER                       PIC X(36)                            
              VALUE 'INVENTORY REDUCTION HISTORY - ERRORS'.                     
           03 FILLER       VALUE SPACES    PIC X(24).                           
           03 FILLER                       PIC X(13)                            
              VALUE 'REPORT DATE: '.                                            
           03 ERR-REPORT-DATE.                                                  
              05 ERR-REPORT-MONTH          PIC XX.                              
              05 FILLER    VALUE '-'       PIC X.                               
              05 ERR-REPORT-DAY            PIC XX.                              
              05 FILLER    VALUE '-'       PIC X.                               
              05 ERR-REPORT-YEAR           PIC XX.                              
           03 FILLER       VALUE SPACES    PIC X(14).                           
                                                                                
      * COLUMN HEADINGS FOR ERROR REPORT                                        
       01  ERR-COLHDG.                                                          
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 FILLER                       PIC X(15)                            
              VALUE 'RECORD IN ERROR'.                                          
           03 FILLER       VALUE SPACES    PIC X(68).                           
           03 FILLER                       PIC X(16)                            
              VALUE 'ERROR MESSAGE(S)'.                                         
           03 FILLER       VALUE SPACES    PIC X(31).                           
                                                                                
      * BLANK LINE                                                              
       01 BLANKS           VALUE SPACES    PIC X(133).                          
                                                                                
      *  CHANGE DATE OF RECEIPT TO YYMMDD                                       
       01  RCT-DT.                                                              
           03 RCT-YR                       PIC 99.                              
           03 RCT-MO                       PIC 99.                              
           03 RCT-DAY                      PIC 99.                              
      /                                                                         
      ***************************************************************           
       PROCEDURE DIVISION.                                                      
      ***************************************************************           
                                                                                
      *--------------------------------------------------------------           
       A000-MAIN                           SECTION.                             
      *                                                                         
      *   THIS SECTION IS THE MAIN DRIVER FOR THE PROGRAM.                      
      *--------------------------------------------------------------           
                                                                                
           PERFORM         B000-INIT.                                           
                                                                                
           PERFORM         C000-CREATE-REPORT                                   
                           UNTIL EOF-IND = 'Y'.                                 
                                                                                
           PERFORM         Z000-FINISH.                                         
                                                                                
           GOBACK.                                                              
      /                                                                         
      *--------------------------------------------------------------           
       B000-INIT                           SECTION.                             
      *                                                                         
      *  B000-INIT CONTAINS THE INITIALIZATION STATEMENTS TO BE                 
      *    PERFORMED AT THE BEGINNING OF THE PROGRAM.                           
      *--------------------------------------------------------------           
                                                                                
           MOVE            'N'             TO EOF-IND                           
                                              ERROR-IND.                        
                                                                                
      *  LINE COUNTERS IS INITIALIZED TO 99 TO FORCE A HEADER                   
      *      TO BE PRINTED AT THE BEGINNING OF THE REPORT.                      
           MOVE            99              TO LINE-CTR                          
                                              ERR-LINE-CTR.                     
                                                                                
      *  FLUSH ERROR LINE WITH BLANKS.                                          
           MOVE            SPACES          TO ERR-OUT-REC.                      
                                                                                
      *  ACCEPT THE SYSTEM DATE AND MOVE IT TO THE HEADING'S DATE               
           ACCEPT          SYS-DATE        FROM DATE.                           
           MOVE            SYS-DAY         TO REPORT-DAY                        
                                              ERR-REPORT-DAY.                   
           MOVE            SYS-MONTH       TO REPORT-MONTH                      
                                              ERR-REPORT-MONTH.                 
           MOVE            SYS-YEAR        TO REPORT-YEAR                       
                                              ERR-REPORT-YEAR.                  
                                                                                
      *  OPEN THE INPUT AND OUTPUT FILES                                        
           OPEN            INPUT           INVENTORY-DATA-FILE                  
                           OUTPUT          INVENTORY-REPORT-FILE                
                                           ERR-REPORT-FILE.                     
                                                                                
      *  PERFORM THE INITIAL READ OF THE FILE.                                  
           PERFORM         R000-READ-INV-DATA-FILE.                             
           IF              EOF-IND = 'Y'                                        
                           DISPLAY ' '                                          
                           DISPLAY 'NO DATA RECORDS.'                           
                           CLOSE           INVENTORY-DATA-FILE                  
                                           INVENTORY-REPORT-FILE                
                                           ERR-REPORT-FILE                      
                           GOBACK.                                              
                                                                                
       DEPART.                                                                  
           EXIT.                                                                
      /                                                                         
      *--------------------------------------------------------------           
       C000-CREATE-REPORT                  SECTION.                             
      *                                                                         
      *   THIS SECTION IS THE MAIN PROCESSING LOOP.  IT PROCESSES THE           
      *     RECORD FROM THE PRIOR READ (SO THAT THE INITIAL READ IS             
      *     HANDLED) AND THEN READS THE NEXT RECORD.                            
      *                                                                         
      *   ADDED FOR PROGRAM 2 IS A CALL TO VALIDATE WHICH VALIDATES             
      *     THE RECORD AND THE PROPER HANDLING OF THE RECORD IF THERE           
      *     IS OR IS NOT AN ERROR                                               
      *--------------------------------------------------------------           
                                                                                
      * CHECK TO SEE IF NEED TO ADVANCE TO TOP OF PAGE                          
           IF      LINE-CTR > 56                                                
                   PERFORM W000-WRITE-HEADING.                                  
           IF      ERR-LINE-CTR > 56                                            
                   PERFORM WRITE-ERR-HEADING.                                   
                                                                                
      *  VALIDATE THE RECORD                                                    
           PERFORM VALIDATE-RECORD.                                             
                                                                                
           IF      ERROR-IND = 'N'                                              
      *  PROCESS THE RECORD IF NO ERRORS FOUND                                  
              MOVE    WAREHOUSE-NO-IN         TO WAREHOUSE-NO-OUT               
              MOVE    PART-NO-IN              TO PART-NO-OUT                    
              MOVE    PART-DESC-IN            TO PART-DESC-OUT                  
              MOVE    UNIT-PRICE-IN           TO UNIT-PRICE-OUT                 
              MOVE    QS-JAN-IN               TO QS-JAN-OUT                     
              MOVE    QS-FEB-IN               TO QS-FEB-OUT                     
              MOVE    QS-MAR-IN               TO QS-MAR-OUT                     
              MOVE    QS-APR-IN               TO QS-APR-OUT                     
              MOVE    QS-MAY-IN               TO QS-MAY-OUT                     
              MOVE    QS-JUN-IN               TO QS-JUN-OUT                     
              MOVE    LSD-YR-IN               TO LSD-YR-OUT                     
              MOVE    LSD-MO-IN               TO LSD-MO-OUT                     
              MOVE    LSD-DAY-IN              TO LSD-DAY-OUT                    
              MOVE    DR-MO-IN                TO DR-MO-OUT                      
              MOVE    DR-DAY-IN               TO DR-DAY-OUT                     
              MOVE    DR-YR-IN                TO DR-YR-OUT                      
      * WRITE THE OUTPUT RECORD                                                 
              WRITE   INVENTORY-REPORT-REC    FROM INV-OUT-REC                  
                      BEFORE ADVANCING 3 LINES                                  
              ADD     3                       TO LINE-CTR                       
           ELSE                                                                 
              WRITE   ERR-REPORT-REC          FROM BLANKS                       
                      AFTER ADVANCING 2 LINES                                   
              ADD     2                       TO ERR-LINE-CTR                   
           END-IF.                                                              
                                                                                
           MOVE    'N'                     TO ERROR-IND.                        
                                                                                
      * READ NEXT RECORD                                                        
           PERFORM R000-READ-INV-DATA-FILE.                                     
                                                                                
       DEPART.                                                                  
           EXIT.                                                                
      /                                                                         
      *---------------------------------------------------------------          
       R000-READ-INV-DATA-FILE             SECTION.                             
      *                                                                         
      *  R000-READ-INV-DATA-FILE IS WHERE THE RECORDS ARE READ FROM             
      *    INVENTORY-DATA-FILE AND ARE PLACED INTO INV-IN-REC AND               
      *    ERRREC.                                                              
      *---------------------------------------------------------------          
                                                                                
           READ    INVENTORY-DATA-FILE     INTO INV-IN-REC                      
                   AT END  MOVE 'Y'        TO EOF-IND                           
           END-READ.                                                            
                                                                                
           MOVE    INVENTORY-DATA-REC      TO ERRREC.                           
                                                                                
       DEPART.                                                                  
           EXIT.                                                                
      /                                                                         
      *----------------------------------------------------------------         
       VALIDATE-RECORD                     SECTION.                             
      *                                                                         
      *  VALIDATE CHECKS THE DATA RECORD FOR ERRORS.  IF ERRORS ARE             
      *    FOUND, THE SECTION TO PERFORM THE WRITE ERROR RECORD IS              
      *    CALLED.                                                              
      *----------------------------------------------------------------         
                                                                                
      * VALIDATE WAREHOUSE NUMBER                                               
           IF      WCHAR1  NOT =   'E' AND 'C' AND 'P'                          
              MOVE      'Y'     TO ERROR-IND                                    
              MOVE      'WAREHOUSE NUMBER MUST BEGIN WITH E, C, OR P'           
                        TO ERRMSG                                               
              PERFORM      WRITE-ERR-LINE                                       
           END-IF.                                                              
           IF   WCHAR2  IS NOT  NUMERIC                                         
              MOVE      'Y'     TO ERROR-IND                                    
              MOVE      'WAREHOUSE NUMBER MUST END WITH A #' TO ERRMSG          
              PERFORM   WRITE-ERR-LINE                                          
           END-IF.                                                              
                                                                                
      *  VALIDATE PART NUMBER                                                   
           IF      PART-NO-IN = SPACES OR PART-NO-IN >= '99000'                 
              MOVE        'Y'     TO ERROR-IND                                  
              MOVE        'PART # MUST EXIST AND BE < 99000' TO ERRMSG          
              PERFORM     WRITE-ERR-LINE                                        
           END-IF.                                                              
                                                                                
      *  VALIDATE PART DESCRIPTION                                              
           IF      PART-DESC-IN = SPACES                                        
              MOVE         'Y'     TO ERROR-IND                                 
              MOVE         'PART DESCRIPTION DOES NOT EXIST' TO ERRMSG          
              PERFORM      WRITE-ERR-LINE                                       
           END-IF.                                                              
                                                                                
      *  VALIDATE UNIT PRICE                                                    
           IF      UNIT-PRICE-IN IS NOT NUMERIC                                 
              MOVE         'Y'     TO ERROR-IND                                 
              MOVE         'UNIT PRICE MUST BE NUMERIC' TO ERRMSG               
              PERFORM      WRITE-ERR-LINE                                       
           ELSE                                                                 
              IF   UNIT-PRICE-IN <= 0                                           
                 MOVE      'Y'     TO ERROR-IND                                 
                 MOVE      'UNIT PRICE MUST BE > ZERO' TO ERRMSG                
                 PERFORM   WRITE-ERR-LINE                                       
              END-IF                                                            
           END-IF.                                                              
                                                                                
      *  VALIDATE QUANTITY SOLD FIELDS                                          
           IF      QUANTITY-SOLD-IN IS NOT NUMERIC                              
              MOVE         'Y'     TO ERROR-IND                                 
              MOVE         'INVALID QUANTITY SOLD VALUE(S)' TO ERRMSG           
              PERFORM      WRITE-ERR-LINE                                       
           END-IF.                                                              
                                                                                
      *  VALIDATE LAST SALE DATE                                                
           IF      LAST-SALE-DATE-IN IS NOT NUMERIC OR                          
                   LAST-SALE-DATE-IN IS > '860630'                              
              MOVE         'Y'     TO ERROR-IND                                 
              MOVE         'INVALID LAST SALE DATE' TO ERRMSG                   
              PERFORM      WRITE-ERR-LINE                                       
           ELSE                                                                 
              IF   LSD-MO-IN < 1 OR > 12                                        
                 MOVE      'Y'     TO ERROR-IND                                 
                 MOVE      'INVALID MONTH IN LAST SALE DATE' TO ERRMSG          
                 PERFORM   WRITE-ERR-LINE                                       
              END-IF                                                            
              IF   LSD-DAY-IN < 1 OR > 31                                       
                 MOVE      'Y'     TO ERROR-IND                                 
                 MOVE      'INVALID DAY IN LAST SALE DATE' TO ERRMSG            
                 PERFORM   WRITE-ERR-LINE                                       
              END-IF                                                            
           END-IF.                                                              
                                                                                
      *  VALIDATE DATE OF RECEIPT                                               
           MOVE    DR-MO-IN        TO RCT-MO                                    
           MOVE    DR-DAY-IN       TO RCT-DAY                                   
           MOVE    DR-YR-IN        TO RCT-YR                                    
           IF      RCT-DT  IS NOT NUMERIC OR RCT-DT > '860630'                  
              MOVE         'Y'     TO ERROR-IND                                 
              MOVE         'INVALID RECEIPT DATE' TO ERRMSG                     
              PERFORM      WRITE-ERR-LINE                                       
           ELSE                                                                 
              IF   DR-MO-IN < 1 OR > 12                                         
                 MOVE      'Y'     TO ERROR-IND                                 
                 MOVE      'INVALID MONTH IN RECEIPT DATE' TO ERRMSG            
                 PERFORM   WRITE-ERR-LINE                                       
              END-IF                                                            
              IF   DR-DAY-IN < 1 OR > 31                                        
                 MOVE      'Y'     TO ERROR-IND                                 
                 MOVE      'INVALID DAY IN RECEIPT DATE' TO ERRMSG              
                 PERFORM   WRITE-ERR-LINE                                       
              END-IF                                                            
           END-IF.                                                              
                                                                                
       DEPART.                                                                  
           EXIT.                                                                
      /                                                                         
      *---------------------------------------------------------------          
       WRITE-ERR-LINE                      SECTION.                             
      *                                                                         
      *  WRITE-ERR-LINE WRITES THE PARTICULAR ERROR LINE TO THE ERROR           
      *    REPORT.  IT THEN WIPES OUT THE ERROR LINE WITH SPACES.               
      *---------------------------------------------------------------          
                                                                                
           WRITE   ERR-REPORT-REC          FROM ERR-OUT-REC                     
                   AFTER ADVANCING 1 LINE.                                      
                                                                                
           ADD     1                       TO ERR-LINE-CTR.                     
                                                                                
           MOVE    SPACES                  TO ERR-OUT-REC.                      
                                                                                
       DEPART.                                                                  
           EXIT.                                                                
      /                                                                         
      *----------------------------------------------------------------         
       W000-WRITE-HEADING                  SECTION.                             
      *                                                                         
      *  W000-WRITE-HEADING PRINTS THE REPORT AND COLUMN HEADINGS               
      *    OCCUPYING THE FIRST 4 LINES OF THE REPORT.  THE LINE COUNTER         
      *    WILL THEN BE INITIALIZED TO THAT VALUE OF 4.  THE TOP                
      *    INDICATOR FOR THE REPORT IS THEN SET TO 'Y'.                         
      *                                                                         
      *----------------------------------------------------------------         
                                                                                
      *  REPORT HEADING                                                         
           WRITE   INVENTORY-REPORT-REC    FROM REPORT-HEADING                  
                   AFTER ADVANCING TOP-OF-PAGE.                                 
                                                                                
      *  COLUMN HEADINGS                                                        
           WRITE   INVENTORY-REPORT-REC    FROM COLHDG-TOP                      
                   AFTER ADVANCING 2 LINES.                                     
           WRITE   INVENTORY-REPORT-REC    FROM COLHDG-BOTTOM                   
                   AFTER ADVANCING 1 LINE.                                      
                                                                                
           WRITE   INVENTORY-REPORT-REC    FROM BLANKS                          
                   AFTER ADVANCING 2 LINES.                                     
                                                                                
      *  INIT LINE-CTR                                                          
           MOVE    5                       TO LINE-CTR.                         
      *    MOVE    'Y'                     TO INV-TOP.                          
                                                                                
       DEPART.                                                                  
           EXIT.                                                                
      /                                                                         
      *----------------------------------------------------------------         
       WRITE-ERR-HEADING                   SECTION.                             
      *                                                                         
      *  WRITE-ERR-HEADING PRINTS THE REPORT AND COLUMN HEADINGS                
      *    OCCUPYING THE FIRST 3 LINES OF THE REPORT.  THE LINE COUNTER         
      *    WILL THEN BE INITIALIZED TO THAT VALUE OF 3.  THE TOP                
      *    INDICATOR FOR THE REPORT IS THEN SET TO 'Y'.                         
      *                                                                         
      *----------------------------------------------------------------         
                                                                                
      *  REPORT HEADING                                                         
           WRITE   ERR-REPORT-REC          FROM ERR-REPORT-HEADING              
                   AFTER ADVANCING TOP-OF-PAGE.                                 
                                                                                
      *  COLUMN HEADINGS                                                        
           WRITE   ERR-REPORT-REC          FROM ERR-COLHDG                      
                   AFTER ADVANCING 2 LINES.                                     
                                                                                
           WRITE   ERR-REPORT-REC          FROM BLANKS                          
                   AFTER ADVANCING 1 LINE.                                      
                                                                                
      *  INIT LINE-CTR                                                          
           MOVE    4                       TO ERR-LINE-CTR.                     
      *    MOVE    'Y'                     TO ERR-TOP.                          
                                                                                
       DEPART.                                                                  
           EXIT.                                                                
      /                                                                         
      *--------------------------------------------------------------           
       Z000-FINISH                         SECTION.                             
      *                                                                         
      *  Z000-FINISH CLOSES THE FILES                                           
      *                                                                         
      *--------------------------------------------------------------           
                                                                                
           CLOSE   INVENTORY-DATA-FILE                                          
                   INVENTORY-REPORT-FILE                                        
                   ERR-REPORT-FILE.                                             
                                                                                
       DEPART.                                                                  
           EXIT.                                                                
      *                                                                         
      *                                                                         
//GO.READER   DD   DSN=USER.COBPGM02,DISP=SHR                                   
//GO.PRINTER  DD   SYSOUT=A                                                     
//GO.PRINTER2 DD   SYSOUT=A                                                     
