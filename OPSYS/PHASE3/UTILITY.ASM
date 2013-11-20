********************************************************************            
* ERICK NAVE                                                                    
* OPERATING SYSTEMS                                                             
* PHASE 2 - PROCESS CONTROL -- UTILITY ASSEMBLE                                 
*                                                                               
* UTILITY ASSEMBLE CONTAINS CODE FOR CONTEXT SWITCHING AND INTERRUPT            
*   HANDLERS.                                                                   
********************************************************************            
*                                                                               
********************************************************************            
* CONSTANTS FOR OLD PSW LOCATIONS                                               
********************************************************************            
*                                                                               
IOOPSW   EQU   X'38'                    OLD PSW LOCATION FOR I/O                
EXTOPSW  EQU   X'18'                    OLD PSW LOCATION FOR EXTERNAL           
SVCOPSW  EQU   X'20'                    OLD PSW LOCATION FOR SVC                
*                                                                               
********************************************************************            
* THE EXTERNAL INTERRUPT HANDLER RESPONDS TO INTERRUPTS FROM THE                
*   CPU TIMER.  THE OS MUST SAVE THE CURRENT STATE OF THE RUNNING               
*   PROCESS AND THEN CALL DISPATCH TO DISPATCH ANOTHER PROCESS.                 
********************************************************************            
*                                                                               
EXTHNDLR DS    0H                                                               
         ENTRY EXTHNDLR                                                         
         STM   0,15,X'200'(0)           SAVE REGISTERS                          
         BALR  14,0                                                             
         USING *,14                                                             
         L     1,=V(RUNNING)            ADDRESS OF RUNNING                      
         L     2,0(1)                   RUNNING PCB                             
         LA    15,36(2)                 R15-->ADDRESS OF SAVE AREA              
         MVC   0(64,15),X'200'(0)       MOVE SAVE REGISTERS TO PCB              
         MVC   64(8,15),EXTOPSW(0)      MOVE OLD EXT PSW TO SAVE AREA           
         L     12,28(2)                 R12->ADDRESS OF KERNAL STACK            
         L     11,=V(DISPATCH)          R11-->ADDRESS OF DISPATCH               
         BALR  13,11                    CALL DISPATCH                           
         MVC   X'300'(8,0),64(15)       MOVE SAVED PSW TO LOW CORE              
         LM    0,15,0(15)               RESTORE REGISTERS                       
         LPSW  X'300'(0)                RETURN TO PROGRAM                       
         LTORG                                                                  
         DROP  14                                                               
*                                                                               
********************************************************************            
* THE I/O INTERRUPT HANDLER FOR NOW JUST RETURNS CONTROL TO THE                 
*   INTERRUPTED PROGRAM.                                                        
********************************************************************            
*                                                                               
IOHNDLR  LPSW  IOOPSW                                                           
         ENTRY IOHNDLR                                                          
*                                                                               
********************************************************************            
* THE SUPERVISOR CALL INTERRUPT HANDLER SAVES THE REGISTERS AND PSW             
*   OF THE RUNNING PROCESS AND THEN CALLS THE SVC SERVICE ROUTINE               
********************************************************************            
*                                                                               
SVCHNDLR DS    0H                                                               
         ENTRY SVCHNDLR                                                         
         STM   0,15,X'200'(0)           SAVE REGISTERS                          
         BALR  14,0                                                             
         USING *,14                                                             
         L     1,=V(RUNNING)            ADDRESS OF RUNNING                      
         L     2,0(1)                   RUNNING PCB                             
         LA    15,36(2)                 R15-->ADDRESS OF SAVE AREA              
         MVC   0(64,15),X'200'(0)       MOVE SAVE REGISTERS TO PCB              
         MVC   64(8,15),SVCOPSW(0)      MOVE OLD SVC PSW TO SAVE AREA           
*  GET KERNAL STACK READY                                                       
         L     4,28(2)                  R4->ADDRESS OF KERNAL STACK             
         MVC   0(20,4),4(12)            PLACE PARMS ON KERNAL STACK             
         LR    12,4                     R12->KERNAL STACK                       
*  COMPUTE BRANCH ADDRESS                                                       
         LA    5,BRADDR                 R5->ADDRESS OF BRANCH TABLE             
         LH    7,X'8A'(0)               GET INTERRUPT CODE                      
         M     6,=F'4'                  CREATE DISPLACEMENT                     
         AR    5,7                      POSITION IN BRANCH TABLE                
         L     11,0(5)                  R11-->ADDR OF SERVICE ROUTINE           
*                                                                               
         BALR  13,11                    CALL SERVICE ROUTINE                    
         MVC   X'300'(8,0),64(15)       MOVE SAVED PSW TO LOW CORE              
         LM    0,10,0(15)               RESTORE REGISTERS                       
         LM    12,15,48(15)                                                     
         LPSW  X'300'(0)                RETURN TO PROGRAM                       
         LTORG                                                                  
         DROP  14                                                               
*                                                                               
********************************************************************            
* THE CONTEXT SWITCH EXPECTS 2 ADDRESSES AS ARGUMENTS.  R12 IS                  
*   STORED IN THE LOCATION INDICATED BY THE FIRST ARGUMENT.  R12 IS             
*   THEN LOADED FROM THE LOCATION INDICATED BY THE SECOND ARGUMENT              
********************************************************************            
*                                                                               
CSWITCH  DS    0H                                                               
         ENTRY CSWITCH                                                          
         USING CSWITCH,11                                                       
         STM   13,10,8(12)                                                      
*                                                                               
         LM    3,4,0(12)           R3-->OLD RUNNING PCB'S STKPTR                
*                                  R4-->NEW RUNNING PCB'S STKPTR                
         ST    12,0(3)             SAVE OLD STKPTR                              
         L     12,0(4)             LOAD NEW STKPTR                              
*                                                                               
         LM    13,10,8(12)                                                      
         BR    13                                                               
         DROP  11                                                               
*                                                                               
********************************************************************            
* CSWITCH1 IS A VARIATION OF CSWITCH THAT IS USED ONLY WHEN A PROCESS           
*   IS BEING DISPATCHED FOR THE FIRST TIME.  THE FIRST ARGUMENT IS A            
*   POINTER TO THE OLD RUNNING PCB'S STACK POINTER.  THE SECOND ARG             
*   IS THE ADDRESS OF THE REGISTER SAVE AREA IN THE NEW RUNNING                 
*   PROCESS'S PCB.  IT STORES R12 IN THE OLD RUNNING PROCESS'S PCB.             
*   IT THEN LOADS ALL OF THE REGISTERS AND PSW DIRECTLY FROM THE                
*   NEW RUNNING PROCESS'S PCB, RATHER THAN THE STACK.                           
********************************************************************            
*                                                                               
CSWITCH1 DS    0H                                                               
         ENTRY CSWITCH1                                                         
         USING CSWITCH1,11                                                      
         STM   13,10,8(12)                                                      
*                                                                               
         LM    3,4,0(12)           R3-->OLD RUNNING PCB'S STKPTR                
*                                  R4-->NEW RUNNING PCB'S STKPTR                
         ST    12,0(3)             SAVE OLD STKPTR                              
         MVC   X'300'(8,0),64(4)   MOVE SAVED PSW TO LOW CORE                   
         LM    0,15,0(4)           LOAD REGISTERS FROM PCB                      
         LPSW  X'300'(0)           JUMP TO PROGRAM                              
         DROP  11                                                               
*                                                                               
********************************************************************            
* SVC$ IS AN ASSEMBLY LANGUAGE ROUTINE THAT MAKES IT POSSIBLE TO                
*   EXECUTE THE SVC INTRUCTION FROM A HIGH LEVEL LANGUAGE.                      
********************************************************************            
*                                                                               
SVC$     DS    0H                                                               
         ENTRY SVC$                                                             
         MVI   2(12),X'0A'         PUT SVC OPCODE ON THE STACK                  
         EX    0,2(12)             EXECUTE THE SVC                              
         BR    13                                                               
*                                                                               
********************************************************************            
* KILL PLACES A FULLWORD ZERO AT THE TOP OF THE RUNTIME STACK AND               
*   THEN EXECUTES THE DESTROY FUNCTION THROUGH SVC                              
********************************************************************            
*                                                                               
KILL     DS    0H                                                               
         ENTRY KILL                                                             
         USING KILL,11                                                          
         L     1,=F'0'                                                          
         ST    1,4(12)             NORMAL TERMINATION                           
         SVC   6                                                                
*                                                                               
********************************************************************            
* BRANCH TABLE OF ADDRESSES FOR THE SVC HANDLER                                 
********************************************************************            
*                                                                               
BRADDR   DC    F'0'                                                             
         DC    V(LINES$)                                                        
         DC    V(SNAP$)                                                         
         DC    V(GETMEM$)                                                       
         DC    V(FREEMEM$)                                                      
         DC    V(CREATE$)                                                       
         DC    V(DESTROY$)                                                      
         DC    V(P$)                                                            
         DC    V(V$)                                                            
         DC    V(GETSEM$)                                                       
         DC    V(FREESEM$)                                                      
         DC    F'0'                V(SEND$)                                     
         DC    F'0'                V(RECEIVE$)                                  
         DC    F'0'                V(READ$)                                     
         DC    F'0'                V(WRITE$)                                    
         DC    V(BREAKPT$)                                                      
         DC    V(CPCMD$)                                                        
         DC    V(PRINTF)                                                        
*                                                                               
         END                                                                    
