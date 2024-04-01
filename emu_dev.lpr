program emu_dev;

{$mode ObjFPC}{$H+}

uses
 crt;

type
 t_bpos=record
  x,y:Byte;
 end;

const
 frame_size:t_bpos=(x:14;y:5);

 frames_f:array[0..13] of pchar=(
  '        `O>   '#0+
  '  ___   ||    '#0+
  ' /|  \_/ |    '#0+
  '||| _____/    '#0+
  '    ||        '#0,

  '        `O>   '#0+
  '  ___   ||    '#0+
  ' /|  \_/ |    '#0+
  '||| _____/    '#0+
  '    | |       '#0,

  '        `->   '#0+
  '  ___   ||    '#0+
  ' /|  \_/ |    '#0+
  '||| _____/    '#0+
  '    ||        '#0,

  '          `O> '#0+
  '  ___   _//   '#0+
  ' /|  \_/ /    '#0+
  '||| _____/    '#0+
  '    ||        '#0,

  '              '#0+
  '  ___         '#0+
  ' /|  \___/=`O>'#0+
  '||| _____/    '#0+
  '    ||        '#0,

  '              '#0+
  '  ___         '#0+
  ' /|  \___ ,   '#0+
  '||| _____=O>  '#0+
  '    ||        '#0,

  '              '#0+
  '  ___         '#0+
  ' /|  \___     '#0+
  '||| _____\    '#0+
  '    ||   \|   '#0,

  //

  '   <O`        '#0+
  '    ||   ___  '#0+
  '    | \_/  |\ '#0+
  '    \_____ |||'#0+
  '        ||    '#0,

  '   <O`        '#0+
  '    ||   ___  '#0+
  '    | \_/  |\ '#0+
  '    \_____ |||'#0+
  '       | |    '#0,

  '   <-`        '#0+
  '    ||   ___  '#0+
  '    | \_/  |\ '#0+
  '    \_____ |||'#0+
  '        ||    '#0,

  ' <O`          '#0+
  '   \\_   ___  '#0+
  '    \ \_/  |\ '#0+
  '    \_____ |||'#0+
  '        ||    '#0,

  '              '#0+
  '         ___  '#0+
  '<O`=\___/  |\ '#0+
  '    \_____ |||'#0+
  '        ||    '#0,

  '              '#0+
  '         ___  '#0+
  '   , ___/  |\ '#0+
  '  <O=_____ |||'#0+
  '        ||    '#0,

  '              '#0+
  '         ___  '#0+
  '     ___/  |\ '#0+
  '    /_____ |||'#0+
  '   |/   ||    '#0

 );

 frame_eve:array[0..13] of t_bpos=(
  (x:  9;y:  0),
  (x:  9;y:  0),
  (x:255;y:255),
  (x: 11;y:  0),
  (x: 12;y:  2),
  (x: 10;y:  3),
  (x:255;y:255),
  //
  (x:  4;y:  0),
  (x:  4;y:  0),
  (x:255;y:255),
  (x:  2;y:  0),
  (x:  1;y:  2),
  (x:  3;y:  3),
  (x:255;y:255)
 );

procedure print_frame(f,x,y:DWORD);
var
 j:DWORD;
 p:pchar;
begin
 for j:=0 to frame_size.y-1 do
 begin
  p:=@frames_f[f][j*(frame_size.x+1)];
  //

  if (frame_eve[f].y=j) then
  begin
   TextColor(Green);
   GotoXY(x,y+j);
   Write(copy(p,1,frame_eve[f].x));
   p:=@p[frame_eve[f].x];
   TextColor(White);
   Write(p[0]);
   p:=@p[1];
   TextColor(Green);
   Write(p);
  end else
  begin
   TextColor(Green);
   GotoXY(x,y+j);
   Write(p);
  end;

 end;
end;

procedure print_ground(y:DWORD);
var
 x:dword;
 s:rawByteString;
begin
 x:=WindMaxX;
 setlength(s,x);
 FillChar(pchar(s)^,x,'~');
 GotoXY(1,y);
 Write(s);
end;

type
 t_emu_state=(esNormal,
              esForward,
              esBlink,
              esTilt1,
              esTilt2,
              esTilt3,
              esTilt4);

const
 min_pos_x:Byte=2;

var
 state:t_emu_state=esNormal;
 ext_s:t_emu_state=esNormal;
 side:Boolean=false;
 pos:t_bpos=(x:2;y:2);

 max_pos_x:Byte;

procedure step_f;
begin
 if ((pos.x+frame_size.x+1)<max_pos_x) then
 begin
  pos.x:=pos.x+1;
 end;
end;

procedure step_b;
begin
 if ((pos.x-1)>=min_pos_x) then
 begin
  pos.x:=pos.x-1;
 end;
end;

procedure DoAction;
begin
 case state of
  esNormal:
   begin
    case ext_s of
     esBlink:
      begin
       ext_s:=esNormal;
       state:=esBlink;
       exit;
      end;
     esForward:
      begin
       ext_s:=esNormal;
       state:=esForward;
       exit;
      end;
     esTilt4:
      begin
       ext_s:=esNormal;
      end;
     else;
    end;


    case Random(12) of
     0..1://blink
          begin
           ext_s:=esNormal;
           state:=esBlink;
          end;
     2..4://step f
          begin
           ext_s:=esNormal;
           side :=false;
           state:=esForward;
          end;
     5..7://step b
          begin
           ext_s:=esNormal;
           side :=true;
           state:=esForward;
          end;
     8://tilt
          begin
           ext_s:=esNormal;
           state:=esTilt1;
          end;
     else;
    end;
   end;
  esBlink:
   case Random(3) of
    0://blink again
      begin
       ext_s:=esBlink;
       state:=esNormal;
      end;
    1://normal
      begin
       state:=esNormal;
      end;
    else;
   end;
  esForward:
   begin
    case Random(3) of
     0://step again
       begin
        ext_s:=esForward;
        state:=esNormal;
       end;
     1://normal
       begin
        state:=esNormal;
       end;
     else;
    end;

    case side of
     False:step_f;
     True :step_b;
    end;

   end;

  esTilt1:
   begin
    if (ext_s<>esTilt4) then
    begin
     state:=esTilt2;
    end else
    begin
     state:=esNormal;
    end;
   end;
  esTilt2:
   begin
    if (ext_s<>esTilt4) then
    begin
     state:=esTilt3;
    end else
    begin
     state:=esTilt1;
    end;
   end;
  esTilt3:
   begin
    if (ext_s<>esTilt4) then
    begin
     state:=esTilt4;
    end else
    begin
     state:=esTilt2;
    end;
   end;

  esTilt4:
   begin
    case Random(5) of
     1://normal
       begin
        ext_s:=esTilt4;
        state:=esTilt3;
       end;
     else;
    end;
   end;

 end;
end;

begin
 Randomize;

 cursoroff;

 max_pos_x:=WindMaxX-1;

 repeat
  ClrScr;
  TextColor(White);
  print_ground(7);

  case side of
   False:print_frame(ord(state)+0,pos.x,pos.y);
   True :print_frame(ord(state)+7,pos.x,pos.y);
  end;

  Delay(300);
  DoAction;
 until false;

 Readln;
end.

