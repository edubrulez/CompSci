PROGRAM SplitTimes (input, output);

{Erick Nave
 2-4-93 ICS 9:00
 program 16, page 84
 SplitTimes (runtime.pas) asks a track coach for times at miles 1 and 2 and
     for the finish time.  It then computes the split times for each point
     and displays them on the screen.}

 VAR
    RunNum, MinMile1, MinMile2, MinFinish, MinSplit2, MinSplit3: INTEGER;
    SecMile1, SecMile2, SecFinish, SecSplit2, SecSplit3: REAL;

 BEGIN
 {Input Section}
      WRITELN;
      WRITELN ('Please leave a space between the minutes and seconds rather');
      WRITELN ('    than a colon.  Thank you.');
      WRITELN;
      WRITE ('Runner number      ');
      READLN (RunNum);
      WRITE ('Mile times:     1  ');
      READLN (MinMile1, SecMile1);
      WRITE ('2':17,'  ');
      READLN (MinMile2, SecMile2);
      WRITE ('Finish time:       ');
      READLN (MinFinish, SecFinish);

 {computation section}
      IF SecMile1 > SecMile2 THEN BEGIN
           SecSplit2:= (SecMile2 + 60.0) - SecMile1;
           MinSplit2:= (MinMile2 - 1) - MinMile1;
           END
         ELSE BEGIN
           SecSplit2:= SecMile2 - SecMile1;
           MinSplit2:= MinMile2 - MinMile1;
           END;
      IF SecMile2 > SecFinish THEN BEGIN
           SecSplit3:= (SecFinish + 60.0) - SecMile2;
           MinSplit3:= (MinFinish - 1) - MinMile2;
           END
         ELSE BEGIN
           SecSplit3:= SecFinish - SecMile2;
           MinSplit3:= MinFinish - MinMile2;
           END;

 {output section}
      WRITELN;
      WRITELN ('Runner number',' ':10,RunNum:1);
      WRITELN ('Split one',' ':14,MinMile1:1,':',SecMile1:1:2);
      WRITELN ('Split two',' ':14,MinSplit2:1,':',SecSplit2:1:2);
      WRITELN ('Split three',' ':12,MinSplit3:1,':',SecSplit3:1:2);
      WRITELN ('Finish time',' ':12,MinFinish:1,':',SecFinish:1:2);
      WRITELN
 END.



