//2048 pro
Uses GraphABC, Control;
var
  ///Ширина окна
  W := 600;//Менять только ширину!
  ///Высота окна
  H := W+100;//Здесь не трогать!
  ///Цвет фона текстовых полей
  MainC := clSilver;
  ///Цвет фона поля
  SelC := clGray;
  ///Цвета плиток
  Colors: array of Color;
  ///Точка отсчета времени кадра для _sleep
  _time := milliseconds;
  //Игровые переменные
  Desk: array[,] of integer;
  ///Размер поля
  DS := 4;
  ///TileSize, размер плитки
  TS := W div DS;
  ///Текущий счет и рекорд
  Score := 0; Rec := 0;
  
///Задержка с привязкой к времени кадра
procedure _sleep(tme: integer);
begin
  while milliseconds < _time + tme do;
  _time := milliseconds;
end;
procedure Spawn24;
var SX, SY: integer;
begin
  repeat
    SX := Random(DS);
    SY := Random(DS);
  until Desk[SX,SY] = 0;
  Desk[SX,SY] := 2;
  if Random(100)<16 then Desk[SX,SY] += 2;
end;
procedure LoadGame;
var Lines: array of string;
begin
  SetWindowTitle('2048 - '+DS+'x'+DS);
  Lines := ReadAllLines('Data\'+DS+'_2048.save',System.Text.Encoding.UTF8);
  SetLength(Lines,3+DS*DS);
  DS := StrToInt(Lines[0]);
  Score := StrToInt(Lines[1]);
  Rec := StrToInt(Lines[2]);
  SetLength(Desk,DS,DS);
  TS := W div DS;
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
    Desk[j,i] := StrToInt(Lines[3+i*DS+j]);
end;
procedure SaveGame;
var Lines: array of string;
begin
  SetLength(Lines,3+DS*DS);
  Lines[0] := IntToStr(DS);
  Lines[1] := IntToStr(Score);
  Lines[2] := IntToStr(Rec);
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
    Lines[3+i*DS+j] := IntToStr(Desk[j,i]);
  WriteAllLines('Data\'+DS+'_2048.save',Lines,System.Text.Encoding.UTF8);
  SetLength(Lines,1);
  Lines[0] := IntToStr(DS);
  WriteAllLines('Data\'+'lastSize.txt',Lines);
end;
procedure NewGame;
begin
  SetWindowTitle('2048 - '+DS+'x'+DS);
  TS := W div DS;
  SetLength(Desk,0,0);
  SetLength(Desk,DS,DS);
  Score := 0;
  Spawn24;
end;
procedure InitGame := if FileExists('Data\'+DS+'_2048.save') then LoadGame else NewGame;
procedure Init;
begin
  if not System.IO.Directory.Exists('Data') then System.IO.Directory.CreateDirectory('Data');
  SetWindowSize(W,H);
  SetWindowPos(ScreenWidth div 2 - (DS div 2) * TS, 16);
  Window.IsFixedSize := true;
  OnClose := SaveGame;
  LockDrawing;
  Font.Size := 20;
  Font.Style := fsBold;
  Pen.Width := 4;
  Pen.Color := ARGB(128,0,0,0);
  SetLength(Colors,64);
  for i: integer := 0 to 63 do Colors[i] := RGB((255-i*16) mod 256,255-i*4,255-i*2);
  if FileExists('Data\'+'lastSize.txt') then DS := StrToInt(ReadAllLines('Data\'+'lastSize.txt')[0]);
  InitGame;
end;
procedure Render;
begin
  Brush.Color := MainC;
  FillRect(0,0,W,50);
  FillRect(0,H-50,W,H);
  DrawTextCentered(0,0,W,50,'Счет: '+Score);
  DrawTextCentered(0,H-50,W,H,'Рекорд: '+Rec);
  Brush.Color := SelC;
  FillRect(0,50,W,H-50);
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
  if Desk[j,i] > 0 then 
  begin
    Brush.Color := Colors[Round(Log2(Desk[j,i]))];
    FillRoundRect(j*TS+2,50+i*TS+2,TS+j*TS-2,50+(i+1)*TS-2,8,8);
    DrawRoundRect(j*TS+3,50+i*TS+3,TS+j*TS-3,50+(i+1)*TS-3,8,8);
    while TextWidth(IntToStr(Desk[j,i]*10)) > TS do Font.Size -= 1;
    DrawTextCentered(j*TS+2, 50+i*TS+2,TS+j*TS-2,50+TS+i*TS-2,Desk[j,i]);
  end;
  Redraw;
  SetFontSize(20);
end;
procedure Animate(Move, Was: array[,] of integer; Dir: integer);
var Steps := 16;
    SX, SY, EX, EY: integer;
    SJ, EJ, SI, EI, dJ, dI: integer;
    j, i: integer;
begin
  case Dir of
  0: begin SJ := DS-1; EJ := 0; SI := 0; EI := DS-1; dJ := -1; dI := 1 end;
  1: begin SJ := 0; EJ := DS-1; SI := 0; EI := DS-1; dJ := 1; dI := 1 end;
  2: begin SJ := 0; EJ := DS-1; SI := DS-1; EI := 0; dJ := 1; dI := -1 end;
  3: begin SJ := 0; EJ := DS-1; SI := 0; EI := DS-1; dJ := 1; dI := 1 end;
  end;
  for f: integer := 0 to Steps do
  begin
    Brush.Color := MainC;
    FillRect(0,0,W,50);
    FillRect(0,H-50,W,H);
    DrawTextCentered(0,0,W,50,'Счет: '+Score);
    DrawTextCentered(0,H-50,W,H,'Рекорд: '+Rec);
    Brush.Color := SelC;
    FillRect(0,50,W,H-50);
    i := SI;
    while i <> EI do
    begin
      j := SJ;
      while j <> EJ do
      begin
        if Was[j,i] > 0 then
        begin
          case Dir of
            0:
            begin
              SX := Round((j+Move[j,i] / Steps * f)*TS);
              SY := 50+i*TS;
              EX := TS+Round((j+Move[j,i] / Steps * f)*TS);
              EY := 50+TS+i*TS;
            end;
            1:
            begin
              SX := Round((j-Move[j,i] / Steps * f)*TS);
              SY := 50+i*TS;
              EX := TS+Round((j-Move[j,i] / Steps * f)*TS);
              EY := 50+TS+i*TS;
            end;
            2:
            begin
              SX := j*TS;
              SY := 50+Round((i+Move[j,i] / Steps * f)*TS);
              EX := TS+j*TS;
              EY := 50+TS+Round((i+Move[j,i] / Steps * f)*TS);
            end;
            3:
            begin
              SX := j*TS;
              SY := 50+Round((i-Move[j,i] / Steps * f)*TS);
              EX := TS+j*TS;
              EY := 50+TS+Round((i-Move[j,i] / Steps * f)*TS);
            end;
          end;
          Brush.Color := Colors[Round(Log2(Was[j,i]))];
          FillRoundRect(SX+2,SY+2,EX-2,EY-2,8,8);
          DrawRoundRect(SX+3,SY+3,EX-3,EY-3,8,8);
          while TextWidth(IntToStr(Was[j,i]*10)) > TS do Font.Size -= 1;
          DrawTextCentered(SX+2,SY+2,EX-2,EY-2,Was[j,i]);
        end;
        _sleep(1);
        Redraw;
        j += dJ;
      end;
      i += dI;
    end;
  end;
end;
procedure MoveRight;
var
  Move, Was: array[,] of integer;
  Moves, Actions: boolean;
begin
  SetLength(Move,DS,DS);
  SetLength(Was,DS,DS);
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
    Was[j,i] := Desk[j,i];
  for i: integer := 0 to DS-1 do
  begin
    Actions := false;
    for j2: integer := DS-2 downto 0 do
    for j: integer := j2 to DS-2 do
      if Desk[j+1,i]=Desk[j,i] then
      begin
        if (Desk[j,i] <> 0) and not Actions then
        begin
          Desk[j,i] := 0;
          Desk[j+1,i] *= 2;
          Score += Desk[j+1,i];
          Moves := true; Actions := true;
          Move[j2,i] += 1;
        end;
      end
      else
      if Desk[j+1,i]=0 then
      begin Swap(Desk[j,i], Desk[j+1,i]); Moves := true; Move[j2,i] += 1; end;
    end;
  if Moves then Spawn24;
  Animate(Move, Was, 0);
end;
procedure MoveLeft;
var
  Was, Move: array[,] of integer;
  Moves, Actions: boolean;
begin
  SetLength(Move,DS,DS);
  SetLength(Was,DS,DS);
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
    Was[j,i] := Desk[j,i];
  for i: integer := 0 to DS-1 do
  begin
    Actions := false;
    for j2: integer := 1 to DS-1 do
    for j: integer := j2 downto 1 do
      if Desk[j-1,i]=Desk[j,i] then
      begin
        if (Desk[j,i] <> 0) and not Actions then
        begin
          Desk[j,i] := 0;
          Desk[j-1,i] *= 2;
          Score += Desk[j-1,i];
          Moves := true; Actions := true;
          Move[j2,i] += 1;
        end;
      end
      else
      if Desk[j-1,i]=0 then
      begin Swap(Desk[j,i], Desk[j-1,i]); Moves := true; Move[j2,i] += 1; end;
  end;
  if Moves then Spawn24;
  Animate(Move, Was, 1);
end;
procedure MoveDown;
var
  Was, Move: array[,] of integer;
  Moves, Actions: boolean;
begin
  SetLength(Move,DS,DS);
  SetLength(Was,DS,DS);
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
    Was[j,i] := Desk[j,i];
  for j: integer := 0 to DS-1 do
  begin
    Actions := false;
    for j2: integer := DS-2 downto 0 do
    for i: integer := j2 to DS-2 do
      if Desk[j,i+1]=Desk[j,i] then
      begin
        if (Desk[j,i] <> 0) and not Actions then
        begin
          Desk[j,i] := 0;
          Desk[j,i+1] *= 2;
          Score += Desk[j,i+1];
          Moves := true; Actions := true;
          Move[j,j2] += 1;
        end;
      end
      else
      if Desk[j,i+1]=0 then
      begin Swap(Desk[j,i], Desk[j,i+1]); Moves := true; Move[j,j2] += 1; end;
  end;
  if Moves then Spawn24;
  Animate(Move, Was, 2);
end;
procedure MoveUp;
var
  Was, Move: array[,] of integer;
  Moves, Actions: boolean;
begin
  SetLength(Move,DS,DS);
  SetLength(Was,DS,DS);
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
    Was[j,i] := Desk[j,i];
  for j: integer := 0 to DS-1 do
  begin
    Actions := false;
    for j2: integer := 1 to DS-1 do
    for i: integer := j2 downto 1 do
      if Desk[j,i-1]=Desk[j,i] then
      begin
        if (Desk[j,i] <> 0) and not Actions then
        begin
          Desk[j,i] := 0;
          Desk[j,i-1] *= 2;
          Score += Desk[j,i-1];
          Moves := true; Actions := true;
          Move[j,j2] += 1;
        end;
      end
      else
      if Desk[j,i-1]=0 then
      begin Swap(Desk[j,i], Desk[j,i-1]); Moves := true; Move[j,j2] += 1; end;
  end;
  if Moves then Spawn24;
  Animate(Move, Was, 3);
end;
procedure EndScreen;
begin
  Render;
  ClearWindow(ARGB(128,200,240,200));
  DrawTextCentered(0,H div 2 - 128,W,H div 2,'Игра закончена');
  DrawTextCentered(0,H div 2 - 64,W,H div 2 + 64,'Ваш счет: '+Score);
  if Score > Rec then
  begin
    Rec := Score;
    DrawTextCentered(0,H div 2,W,H div 2 + 128,'Новый рекорд!');
  end;
  Redraw;
  NewGame;
  while not MousePressed do;
end;
function MoveAvailable(X,Y: integer): boolean;
begin
  if X > 0 then if Desk[X-1,Y] = Desk[X,Y] then Result := true;
  if X < DS-1 then if Desk[X+1,Y] = Desk[X,Y] then Result := true;
  if Y > 0 then if Desk[X,Y-1] = Desk[X,Y] then Result := true;
  if Y < DS-1 then if Desk[X,Y+1] = Desk[X,Y] then Result := true;
  if Desk[X,Y] = 0 then Result := true;
end;
function GameOver: boolean;
begin
  Result := true;
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
    if MoveAvailable(j,i) then Result := false;  
end;
procedure Update;
begin
  if KeyPressed then
  begin
    if RIGHT then MoveRight;
    if LEFT then MoveLeft;
    if DOWN then MoveDown;
    if UP then MoveUp;
    if KeyCode = VK_N then NewGame;
    if KeyCode = VK_Space then SaveGame;
    //+
    if KeyCode = 187 then if DS < 8 then
    begin
      SaveGame;
      DS += 1;
      Rec := 0;
      InitGame;
    end;
    //-
    if KeyCode = 189 then if DS > 2 then
    begin
      SaveGame;
      DS -= 1;
      Rec := 0;
      InitGame;
    end;
  end;
  if GameOver then EndScreen;
  while KeyPressed do;
end;
begin
  Init;
  while true do
  begin
    Render;
    Update;
  end;
end.