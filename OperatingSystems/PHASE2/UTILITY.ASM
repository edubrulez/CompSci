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
* CONSTANTS FOR I/O OLD PSW LOCATION AND EXTERNAL OLD PSW LOCATION              
********************************************************************            
*                                                                               
IOOPSW   EQU   X'38'                    OLD PSW LOCATION FOR I/O                
EXTOPSW  EQU   X'18'                    OLD PSW LOCATION FOR EXTERNAL           
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
         L     12,28(2)                 R12-->ADDRESS OF KERNAL STACK           
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
         END                                                                    
