//PROGRAM1   JOB  67029,'3794NAVEEA',CLASS=H,MSGLEVEL=(2,0)                     
//DEBUG       EXEC COB85DBG                                                     
      *                                                                         
       IDENTIFICATION DIVISION.                                                 
                                                                                
       PROGRAM-ID.         ECPROG1.                                             
       AUTHOR.             ERICK NAVE.                                          
       INSTALLATION.       PROGRAMMING APPLICATIONS WITH COBOL.                 
       DATE-WRITTEN.       3/5/96.                                              
       DATE-COMPILED.                                                           
      *                                                                         
      ****************************************************************          
      *                                                                         
      *REMARKS.                                                                 
      *                                                                         
      *  PROGRAM 1 PRINTS AN INVENTORY REDUCTION LIST SHOWING ALL OF            
      *    THE WAREHOUSE PARTS AND THEIR ACTIVITY FOR THE FIRST 6               
      *    MONTHS OF THE YEAR.                                                  
      *                                                                         
      *  FILES:                                                                 
      *    INVENTORY-DATA-FILE                                                  
      *    INVENTORY-REPORT-FILE                                                
      *                                                                         
      ****************************************************************          
      *                                                                         
      ****************************************************************          
      *  CHANGES MADE TO PROGRAM 1 MAINTAIN THE SAME FUNCTIONALITY,             
      *    BUT CHANGES THE STRUCTURE TO INCLUDE ONLY ONE SENTENCE IN            
      *    THE PROCEDURE DIVISION.                                              
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
                                                                                
      *---------------------------------------------------------------          
       WORKING-STORAGE SECTION.                                                 
      *---------------------------------------------------------------          
                                                                                
       77  LINE-CTR        VALUE ZEROS     PIC S99.                             
                                                                                
       77  EOF-IND                         PIC X.                               
                                                                                
      * INV-IN-REC IS THE FIELD BREAKDOWN FOR INVENTORY-DATA-REC                
      *    IT IS THE RESTRUCTURING OF THE INPUT RECORD.                         
       01  INV-IN-REC.                                                          
           03 FILLER       VALUE SPACE     PIC X.                               
           03 WAREHOUSE-NO-IN              PIC XX.                              
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 PART-NO-IN                   PIC X(5).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 PART-DESC-IN                 PIC X(20).                           
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 UNIT-PRICE-IN                PIC 9(6).                            
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
           03 UNIT-PRICE-OUT               PIC 9(6).                            
           03 FILLER       VALUE SPACES    PIC X(4).                            
      * QUANTITY-SOLD (QS) VALUES FOR JANUARY - JUNE                            
           03 QS-JAN-OUT                   PIC 9(4).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-FEB-OUT                   PIC 9(4).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-MAR-OUT                   PIC 9(4).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-APR-OUT                   PIC 9(4).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-MAY-OUT                   PIC 9(4).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 QS-JUN-OUT                   PIC 9(4).                            
           03 FILLER       VALUE SPACES    PIC XXX.                             
      * LAST SALE DATE (LSD)                                                    
           03 LSD-MO-OUT                   PIC 99.                              
           03 FILLER       VALUE '-'       PIC X.                               
           03 LSD-DAY-OUT                  PIC 99.                              
           03 FILLER       VALUE '-'       PIC X.                               
           03 LSD-YR-OUT                   PIC 99.                              
           03 FILLER       VALUE SPACES    PIC X(4).                            
      * DATE OF LAST RECEIPT (DR)                                               
           03 DR-MO-OUT                    PIC 99.                              
           03 FILLER       VALUE '-'       PIC X.                               
           03 DR-DAY-OUT                   PIC 99.                              
           03 FILLER       VALUE '-'       PIC X.                               
           03 DR-YR-OUT                    PIC 99.                              
           03 FILLER       VALUE SPACES    PIC X(27).                           
                                                                                
      * HEADING FOR THE REPORT WITH DATE IN UPPER RIGHT CORNER                  
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
                                                                                
      * TOP OF 2 LINE COLUMN HEADING                                            
       01  COLHDG-TOP.                                                          
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC X(51).                           
           03 FILLER                       PIC X(28)                            
              VALUE 'QUANTITY SOLD FOR MONTH OF:'.                              
           03 FILLER       VALUE SPACES    PIC X(6).                            
           03 FILLER                       PIC X(7)                             
              VALUE 'DATE OF'.                                                  
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER                       PIC X(12)                            
              VALUE 'DATE OF LAST'.                                             
           03 FILLER       VALUE SPACES    PIC X(25).                           
                                                                                
      * SECOND LINE OF 2 LINE COLUMN HEADING                                    
       01  COLHDG-BOTTOM.                                                       
           03 CC                           PIC X.                               
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 FILLER       VALUE 'WHSE'    PIC X(4).                            
           03 FILLER       VALUE SPACES    PIC XX.                              
           03 FILLER       VALUE 'PART'    PIC X(4).                            
           03 FILLER       VALUE SPACES    PIC XXX.                             
           03 FILLER                       PIC X(16)                            
              VALUE 'PART DESCRIPTION'.                                         
           03 FILLER       VALUE SPACES    PIC X(5).                            
           03 FILLER                       PIC X(10)                            
              VALUE 'UNIT PRICE'.                                               
           03 FILLER       VALUE SPACES    PIC XXX.                             
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
           03 FILLER       VALUE SPACES    PIC X(26).                           
      /                                                                         
      ***************************************************************           
       PROCEDURE DIVISION.                                                      
      ***************************************************************           
                                                                                
           PERFORM                                                              
                   MOVE    'N'             TO EOF-IND                           
                                                                                
      * LINE COUNTER IS INITIALIZED TO 99 TO FORCE A HEADER                     
      *      TO BE PRINTED AT THE BEGINNING OF THE REPORT                       
                   MOVE    99              TO LINE-CTR                          
                                                                                
      * ACCEPT THE SYSTEM DATE AND MOVE IT TO THE HEADING'S DATE                
                   ACCEPT  SYS-DATE        FROM DATE                            
                   MOVE    SYS-DAY         TO REPORT-DAY                        
                   MOVE    SYS-MONTH       TO REPORT-MONTH                      
                   MOVE    SYS-YEAR        TO REPORT-YEAR                       
                                                                                
      * OPEN THE INPUT AND OUTPUT FILES                                         
                   OPEN    INPUT           INVENTORY-DATA-FILE                  
                           OUTPUT          INVENTORY-REPORT-FILE                
                                                                                
      * PERFORM THE INITIAL READ OF THE FILE                                    
                   READ   INVENTORY-DATA-FILE     INTO INV-IN-REC               
                          AT END  MOVE 'Y'        TO EOF-IND                    
                   END-READ                                                     
                                                                                
                   IF     EOF-IND = 'Y'                                         
                           DISPLAY ' '                                          
                           DISPLAY 'NO DATA RECORDS.'                           
                           CLOSE           INVENTORY-DATA-FILE                  
                                           INVENTORY-REPORT-FILE                
                           GOBACK                                               
                   END-IF                                                       
                                                                                
      *   THIS PORTION IS THE MAIN PROCESSING LOOP.  IT PROCESSES THE           
      *     RECORD FROM THE PRIOR READ (SO THAT THE INITIAL READ IS             
      *     HANDLED) AND THEN READS THE NEXT RECORD.                            
                                                                                
                   PERFORM UNTIL EOF-IND = 'Y'                                  
                       MOVE    WAREHOUSE-NO-IN   TO WAREHOUSE-NO-OUT            
                       MOVE    PART-NO-IN        TO PART-NO-OUT                 
                       MOVE    PART-DESC-IN      TO PART-DESC-OUT               
                       MOVE    UNIT-PRICE-IN     TO UNIT-PRICE-OUT              
                       MOVE    QS-JAN-IN         TO QS-JAN-OUT                  
                       MOVE    QS-FEB-IN         TO QS-FEB-OUT                  
                       MOVE    QS-MAR-IN         TO QS-MAR-OUT                  
                       MOVE    QS-APR-IN         TO QS-APR-OUT                  
                       MOVE    QS-MAY-IN         TO QS-MAY-OUT                  
                       MOVE    QS-JUN-IN         TO QS-JUN-OUT                  
                       MOVE    LSD-YR-IN         TO LSD-YR-OUT                  
                       MOVE    LSD-MO-IN         TO LSD-MO-OUT                  
                       MOVE    LSD-DAY-IN        TO LSD-DAY-OUT                 
                       MOVE    DR-MO-IN          TO DR-MO-OUT                   
                       MOVE    DR-DAY-IN         TO DR-DAY-OUT                  
                       MOVE    DR-YR-IN          TO DR-YR-OUT                   
                                                                                
      * CHECK TO SEE IF NEED TO ADVANCE TO TOP OF PAGE                          
                       IF      LINE-CTR > 56                                    
                         WRITE INVENTORY-REPORT-REC FROM REPORT-HEADING         
                               AFTER ADVANCING TOP-OF-PAGE                      
                         WRITE INVENTORY-REPORT-REC FROM COLHDG-TOP             
                               AFTER ADVANCING 2 LINES                          
                         WRITE INVENTORY-REPORT-REC FROM COLHDG-BOTTOM          
                               AFTER ADVANCING 1 LINE                           
                         MOVE    4           TO LINE-CTR                        
                       END-IF                                                   
                                                                                
      * WRITE THE OUTPUT RECORD                                                 
                       WRITE   INVENTORY-REPORT-REC    FROM INV-OUT-REC         
                               AFTER ADVANCING 2 LINES                          
                       ADD     2                       TO LINE-CTR              
                                                                                
      * READ NEXT RECORD                                                        
                       READ    INVENTORY-DATA-FILE     INTO INV-IN-REC          
                               AT END  MOVE 'Y'        TO EOF-IND               
                       END-READ                                                 
                   END-PERFORM                                                  
                                                                                
      * CLOSE THE FILES                                                         
                   CLOSE   INVENTORY-DATA-FILE                                  
                           INVENTORY-REPORT-FILE                                
                                                                                
                   GOBACK                                                       
           END-PERFORM.                                                         
      *                                                                         
      *                                                                         
//GO.READER   DD   DSN=USER.COBPGM01,DISP=SHR                                   
//GO.PRINTER  DD   SYSOUT=A                                                     
