#include <cmsbloks.h>
#include "scall.h"
#pragma inline memcpy
#pragma inline memcmp
#define OK 0
#define NOT_OK (-1)
 
extern memcpy();
extern memcmp();
 
char buffer_a[4096+1], buffer_b[3*4096+1], buffer_c[3*4096+1];
 
int prog_1();
int prog_2();
int prog_3();
int prog_4();
int prog_5();
int dir();
int type();
 
char end_message[80] = "I'M DONE";
char line[10][80] = {"LINE 1","LINE 2","LINE 3","LINE 4","LINE 5",
                     "LINE 6","LINE 7","LINE 8","LINE 9","LINE 10"};
 
 
root()
   {
      int psw1[] = {(int)0x03090000,prog_1};
      int psw2[] = {(int)0x03090000,prog_2};
      int psw3[] = {(int)0x03090000,prog_3};
      int psw4[] = {(int)0x03090000,prog_4};
      int psw5[] = {(int)0x03090000,prog_5};
      int psw6[] = {(int)0x03090000,dir};
      int psw7[] = {(int)0x03090000,type};
 
      int ct, rc, j, pin[7];
      char buffer[80];
      static char mess1[80]="Read Error in Root program";
      static char mess2[80]="Write Error in Root program";
 
      /*  Error check:  If your program is working,
                        these messages should appear
                        on the console.               */
      if (read("PRNT",buffer,0)==NOT_OK)
         write("CONS","Read passed error check 1");
      if (read("DSIK",buffer,0)!=OK)
         write("CONS","Read passed error check 2");
      if (write("DISK",buffer)==NOT_OK)
         write("CONS","Write passed error check 3");
      if (write("PNTR",buffer)!=OK)
         write("CONS","Write passed error check 4");
 
      /* Create 7 child processes */
 
      pin[0] = create("WRITE50 ",psw1,0,0,0);
      pin[2] = create("WRITER  ",psw3,0,0,0);
      pin[1] = create("READER  ",psw2,0,1,&pin[2]);
      pin[3] = create("ADDER   ",psw4,0,0,0);
      pin[4] = create("CONECHO ",psw5,0,0,0);
      pin[5] = create("DIR     ",psw6,0,0,0);
      pin[6] = create("TYPE    ",psw7,0,0,0);
 
      /*  Now, read and echo 10 cards */
      for (ct = 0; ct < 10 && (rc=read("CARD",buffer,0))==OK; ct++)
         if (write("CONS",buffer)==NOT_OK)
            write("CONS",mess2);
      if (rc!=OK)
         write("CONS",mess1);
 
      write("CONS",end_message);
   }
 
prog_1()
   {
      int i, j;
 
      /* write 5 copies of 10 lines to the console */
      for (i = 0; i < 5; i++)
         for (j = 0; j < 10; j++)
            write("CONS",line[j]);
      write("CONS",end_message);
   }
 
prog_2(int writer)
   {
      int i, j;
      char buffer[80];
 
      /* read 10 cards from the card reader - chop each card into 5
         pieces - send each piece as a message */
      for (i=0;i<10;i++)
         {
            read("CARD",buffer,0);
            for (j = 0; j < 80; j += 16)
               send(writer,buffer+j,16);
         }
      /* send a done message */
      send(writer,"****",4);
      write("CONS",end_message);
   }
 
prog_3()
   {
      int i, j, done, printer_pin;
      char out_buffer[80], msg_buffer[16];
      int pin=0;
 
      /* receive a message - when 5 messages
         have been received, concatenate the messages into a line
         and write the line to the console */
      done = 0;
      while (!done)
         {
            for (j = 0; j < 5 && !done; j++)
               {
                  pin=receive(msg_buffer,16);
                  done = !memcmp(msg_buffer,"****",4);
                  memcpy(out_buffer+16*j,msg_buffer,16);
               }
            if (!done)
               write("CONS",out_buffer);
         }
      write("CONS",end_message);
   }
 
prog_4()
   {
      int s1, s2, a1, a2;
      char buffer[80];
 
      a1 = a2 = 0;
 
      /* This loop should proceed until end of file on the card reader */
      while (read("CARD",buffer,0)==OK)
         {
            s1 = dectobin(buffer);
            s2 = dectobin(buffer+13);
            a1 += s1;
            a2 += s2;
            bintodec(s1+s2,buffer+28);
            write("CONS",buffer);
         }
      bintodec(a1,buffer+12);
      bintodec(a2,buffer+20);
      bintodec(a1+a2,buffer+28);
      memcpy(buffer+35,"** TOTALS **",12);
      write("CONS",buffer);
      write("CONS",end_message);
   }
 
prog_5()
   {
      int i, j, rc;
      char buffer[80];
      char message[80]="Read Error in program 5";
 
      /* reads and echoes 10 lines to the console */
      for (i = 0; i < 10; i++)
         {
            for (j = 0; j < 80; j++)
               buffer[j]=' ';
            if (read("CONS",buffer,0)==OK)
               write("CONS",buffer);
            else
               write("CONS",message);
         }
      write("CONS",end_message);
   }
 
bintodec(int n, char *str)
   {
      if (n <= 0)
         *str = '0';
      else
         for (; n > 0; str--)
            {
               *str = (n%10) + '0';
               n = n/10;
            }
   }
 
int dectobin(char *str)
   {
      int n=0;
 
      for (; *str == ' '; str++);   /*  skip leading blanks  */
      for (; *str != ' '; str++)
         n = 10*n + *str - '0';
      return(n);
   }
 
dir()
   {
      /* write the first 20 disk file identifiers to the console */
      int j, dirblkno;
 
      write("CONS","Disk reader started okay");
      if (read("DISK",buffer_a,3)!=OK)
         {
            write("CONS","Disk reader not implemented");
            return;
         }
      write("CONS","This program displays the names of the first 20");
      write("CONS","files on the D-disk");
      dirblkno = ((int*)buffer_a) [4];
      if (read("DISK",buffer_a,dirblkno)!=OK)
         {
            write("CONS","Disk reader gets bad rc from read");
            return;
         }
      for (j = 2; j < 22; j++)
         write("CONS",buffer_a+64*j);
 
      write("CONS","Disk reader is finished");
   }
 
type()
{
 /* read the filename and filetype from the console and write
    the contents of the file to the console */
 fstd *dptr;
 char input[150], fname[16], save;
 char flist[2][17] = {"SAMPLE3 MACASM  ","PH1STARTASSEMBLE"};
 int *index_ptr;
 int i, j, k, dirblkno, datablk, ptr;
 int lrecl, number_of_records, buffer_3_empty;
 
 for (i = 0; i < 150; input[i++] = 0);
 
 write("CONS","This program will type a file to the console");
 for (i = 0; i < 2; i++)
    {
       memcpy(fname,flist[i],16);
 
       /*  Read volume label  */
       if (read("DISK",buffer_b,3)!=OK)
          {
             write("CONS","Type cannot read volume label--aborting");
             return 13;
          }
       dirblkno = ((int*)buffer_b) [4];
 
       /*  Read disk directory block */
       if (read("DISK",buffer_b,dirblkno)!=OK)
          {
             write("CONS","Type cannot read directory--aborting");
             return 14;
          }
 
       /*  Search for desired file name */
       number_of_records = (dptr = (fstd*)buffer_b)->fstaic;
       lrecl = dptr->fstlrecl;
       if (!dptr->fstnlvl)
          {
             for (j = 0; j < 4096; dptr++, j += lrecl)
                if (!memcmp(dptr->fstfname,fname,16))
                   break;
          }
       else
          {
             if (read("DISK",buffer_b,dptr->fstfop)!=OK)
                {
                   write("CONS","Type cannot read index block");
                   return 17;
                }
             index_ptr = (int*)buffer_b;
             buffer_3_empty = 1;
             for (k = 0, ptr = 8192; k < number_of_records; k++, ptr += lrecl)
             {
               if (ptr > 8191) {
                 if (!buffer_3_empty)
                    memcpy(buffer_b+4096,buffer_b+8192,4096);
                 else
                 /* Read next data block from job info file  */
                    if (read("DISK",buffer_b+4096,*index_ptr++)!=OK){
                      write("CONS","Bad rc when trying to read data block"    );
                      return 19;
                     }
                 buffer_3_empty = 1;
                 ptr -= 4096;
                }
               if (ptr > 8192-lrecl)
                  {
                     /* Read next data block from job info file  */
                     if (read("DISK",buffer_b+8192,*index_ptr++)!=OK){
                       write("CONS","Bad rc when trying to read data block    ");
                       return 20;
                       }
                     buffer_3_empty = 0;
                  }
               if (!memcmp(buffer_b+ptr,fname,16)) {
                 dptr = (fstd*)(buffer_b+ptr);
                 break;
                 }
            }
          }
       if (k >= number_of_records) {
         write("CONS","File not found in directory");
         continue;
         }
       if (dptr->fstrecfm == 'V'){
             write("CONS","This file has variable length records");
             continue;
          }
 
       /*
         If we get to this point, we have found the desired
         directory entry, and the variable "dptr" points to it
       */
 
       number_of_records = dptr->fstaic;
       lrecl = dptr->fstlrecl;
       if (!dptr->fstnlvl) {
         /*
           If the number of index levels is 0, there is only one
           data block in the file.  This section reads it and
           then displays its contents.
         */
         if (read("DISK",buffer_b,dptr->fstfop)!=OK){
           write("CONS","Type cannot read first block");
           return 21;
           }
         for (k = 0; k < number_of_records; k++) {
          /* temporarily put a null character at the end of the record */
           save = *(buffer_b+(k+1)*lrecl);
           *(buffer_b+(k+1)*lrecl) = '\0';
           write("CONS",buffer_b+k*lrecl);
           *(buffer_b+(k+1)*lrecl) = save;
           }
         }
       else {
         /*
           If we get to this point, there is 1 index level,
           so we read in the index block.
         */
         if (read("DISK",buffer_b,dptr->fstfop)!=OK){
           write("CONS","Type cannot read index block");
           return 22;
           }
         index_ptr = (int*)buffer_b;
         buffer_3_empty = 1;
         /*
           Next is the main read and print loop for the file.
           It is a for-loop; one iteration per logical record.
           p is used as the buffer pointer; when p goes beyond
           the end of buffer 2, we read another data block.
         */
         for (k=0, ptr=8192; k<number_of_records; k++, ptr += lrecl){
           if (ptr > 8191) {
             if (!buffer_3_empty)
                memcpy(buffer_b+4096,buffer_b+8192,4096);
             else
                /*  Read next data block from job info file  */
                if (read("DISK",buffer_b+4096,*index_ptr++)!=OK){
                  write("CONS","Bad rc when trying to read data block");
                  return 24;
                 }
                 buffer_3_empty = 1;
                 ptr -= 4096;
           }
           if (ptr > 8192-lrecl) {
             /*  Read next data block from job info file  */
             if (read("DISK",buffer_b+8192,*index_ptr++)!=OK){
               write("CONS","Bad rc when trying to read data block");
               return 24;
               }
             buffer_3_empty = 0;
             }
          /* temporarily put a null character at the end of the record */
           save = *(buffer_b+ptr+lrecl);
           *(buffer_b+ptr+lrecl) = '\0';
           write("CONS",buffer_b+ptr);
           *(buffer_b+ptr+lrecl) = save;
           }
         }
 
       write("CONS","End of file reached");
    }
 write("CONS","Terminating");
 return 0;
}
 
