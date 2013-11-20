PROGRAM SplitTimes (input, output);

{Erick Nave
 2-4-93 ICS 9:00
 program 16, page 84
 SplitTimes (runtime.pas) asks a track coach for times at miles 1 and 2 and
     for the finish time.  It then computes the split times for each point
     and displays them on the screen.}

 VAR
    RunNum, MinMile1, MinMile2, MinFinish, MinSplit2, MinSplit3, SecMile1,
         SecMile2, SecFinish, SecSplit2, SecSplit3, HunMile1, HunMile2,
         HunFinish, HunSplit2, HunSplit3: LONGINT;
    bigtime1, bigtime2, bigtime3, remainder2, remainder3, temp2,
         temp3: LONGINT;

 BEGIN
 {Input Section}
      WRITELN;
      WRITELN ('Please leave a space between the minutes, seconds, and');
      WRITELN ('    hundredths rather than a colon and decimal.  Thank you.');
      WRITELN;
      WRITE ('Runner number      ');
      READLN (RunNum);
      WRITE ('Mile times:     1  ');
      READLN (MinMile1, SecMile1, HunMile1);
      WRITE ('2':17,'  ');
      READLN (MinMile2, SecMile2, HunMile2);
      WRITE ('Finish time:       ');
      READLN (MinFinish, SecFinish, HunFinish);

 {computation section}
    {figure bigtimes}
      bigtime1:= (MinMile1 * 6000) + (SecMile1 * 100) + HunMile1;
      bigtime2:= (MinMile2 * 6000) + (SecMile2 * 100) + HunMile2;
      bigtime3:= (MinFinish * 6000) + (SecFinish * 100) + HunFinish;
    {figure split 2}
      temp2:= bigtime2 - bigtime1;
      MinSplit2:= temp2 div 6000;
      remainder2:= temp2 mod 6000;
      SecSplit2:= remainder2 div 100;
      HunSplit2:= remainder2 mod 100;
    {figure split 3}
      temp3:= bigtime3 - bigtime2;
      MinSplit3:= temp3 div 6000;
      remainder3:= temp3 mod 6000;
      SecSplit3:= remainder3 div 100;
      HunSplit3:= remainder3 mod 100;

 {output section}
      WRITELN;
      WRITELN ('Runner number',' ':10,RunNum:1);
      WRITELN ('Split one',' ':14,MinMile1:1,':',SecMile1 div 10:1,
              SecMile1 mod 10:1,'.',HunMile1 div 10:1, HunMile1 mod 10:1);
      WRITELN ('Split two',' ':14,MinSplit2:1,':',SecSplit2 div 10:1,
              SecSplit2 mod 10:1,'.',HunSplit2 div 10,HunSplit2 mod 10:1);
      WRITELN ('Split three',' ':12,MinSplit3:1,':',SecSplit3 div 10:1,
              SecSplit3 mod 10:1,'.',HunSplit3 div 10:1, HunSplit3 mod 10:1);
      WRITELN ('Finish time',' ':12,MinFinish:1,':',SecFinish div 10:1,
              SecFinish mod 10:1,'.',HunFinish div 10:1,HunFinish mod 10:1);
      WRITELN
 END.



