//2048 pro
{
  Игра 2048
  Управление:
  стрелочки - двигать плитки
  N - новая игра
  A - анимация
  Пробел - новая игра
  +,- размер поля
  При завершении игры клик мыши - новая игра
  * игра сохраняется при закрытии и загружается при открытии
  Автор: @deadpixel_programmer (Давыдов Борис)
  Файл переименовать в .rar, папка 2048 1 - старая версия, как вариант
                             папка 2048 2 - новая версия, 0.0.1 - рабочая версия,
                                                          0.0.2 - с непонятной ошибкой
  
  Коммент:
    Есть вырвиглазная деталь для перфекциониста:
    если поставить задержку анимации 128, то становится заметно
    что плитки рисуются не симметрично движению,
    с одной стороны они накладываются, с другой они заезжают под плитки
    пробовал решить проблему, использую while вместо for, для простого
    выбора направления движения и обработки в нужной последовательности,
    но отрисовка стала жутко тормозить и лагать, хотя вроде всё также,
    но, возможно, есть логическая ошибка, которую я не заметил.
}
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
  ///Включить анимацию
  Anim := true;
  
function BoolToStr(Bool: boolean): string;
begin
  if Bool then Result := 'true' else Result := 'false';
end;
function StrToBool(Str: string) := Str = 'true';
///Задержка с привязкой к времени кадра
procedure _sleep(tme: integer);
begin
  while milliseconds < _time + tme do;
  _time := milliseconds;
end;
function ToNext(Text: string; Pos: integer): string;
begin
  Text := Text.Substring(Pos);
  if Text.IndexOf(' ') > 0 then
  Text := Text.Remove(Text.IndexOf(' '));
  if Text.IndexOf('\n') > 0 then
  Text := Text.Remove(Text.IndexOf('\n'));
  Result := Text;
end;
procedure ATextOut(SX,SY,EX,EY: integer; Title, Text: string);
var
  Lines: array of string;
procedure TextToLines;
var NowLine: string;
begin
  SetLength(Lines,0);
  for i: integer := 1 to Text.Length do
  begin
    if i < Text.Length-1 then
    if (Text[i]+Text[i+1] = '\n') or ((Text[i] = ' ') and (Length(ToNext(Text, i)+NowLine)*Font.Size > EX-SX-Font.Size)) or (Length(NowLine+1)*Font.Size > EX-SX-Font.Size) then
    begin
      SetLength(Lines, Lines.Length+1);
      Lines[Lines.Length-1] := NowLine;
      NowLine := '';
    end;
    if (Text[i] <> '\') and (Text[i] <> 'n') then NowLine += Text[i];
    if NowLine = ' ' then NowLine := NowLine.Substring(1);
  end;
  SetLength(Lines, Lines.Length+1);
  Lines[Lines.Length-1] := NowLine;
end;
procedure Render;
begin
  Brush.Color := ARGB(64,0,0,0);
  FillRect(SX,SY,EX,EY);
  Brush.Color := ARGB(64,128,128,128);
  FillRect(SX+3,SY+3,EX-3,EY-3);
  SetWindowTitle(Title);
  for i: integer := 0 to Lines.Length-1 do
  if not MousePressed and not KeyPressed then
  for j: integer := 1 to Lines[i].Length do
  if not MousePressed and not KeyPressed then
  begin
    DrawTextCentered(SX+5+j*Font.Size,SY+5+Round(i*Font.Size*1.5),SX+5+j*Font.Size,SY+5+Round(i*Font.Size*1.5)+Font.Size*2,Lines[i][j]);
    _sleep(16);
    Redraw;
  end;
end;
begin
  Text += '\nНажмите кнопку для продолжения';
  TextToLines;
  Render;
  while not MousePressed and not KeyPressed do;
  while KeyPressed do;
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
  SetLength(Lines,4+DS*DS);
  DS := StrToInt(Lines[0]);
  Score := StrToInt(Lines[1]);
  Rec := StrToInt(Lines[2]);
  Anim := StrToBool(Lines[3]);
  SetLength(Desk,DS,DS);
  TS := W div DS;
  for i: integer := 0 to DS-1 do
  for j: integer := 0 to DS-1 do
    Desk[j,i] := StrToInt(Lines[4+i*DS+j]);
end;
procedure SaveGame;
var Lines: array of string;
begin
  if Desk <> nil then
  begin
    SetLength(Lines,4+DS*DS);
    Lines[0] := IntToStr(DS);
    Lines[1] := IntToStr(Score);
    Lines[2] := IntToStr(Rec);
    Lines[3] := BoolToStr(Anim);
    for i: integer := 0 to DS-1 do
    for j: integer := 0 to DS-1 do
      Lines[4+i*DS+j] := IntToStr(Desk[j,i]);
    WriteAllLines('Data\'+DS+'_2048.save',Lines,System.Text.Encoding.UTF8);
    SetLength(Lines,1);
    Lines[0] := IntToStr(DS);
    WriteAllLines('Data\'+'lastSize.txt',Lines);
  end;
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
procedure StartScreen;
var Text: string;
begin
  ClearWindow;
  Text += 'Управление:\n';
  Text += 'стрелочки - двигать плитки\n';
  Text += 'N - новая игра\n';
  Text += 'A - анимация\n';
  Text += 'Пробел - новая игра\n';
  Text += '+,- размер поля\n';
  Text += 'При завершении игры клик мыши - новая игра\n';
  Text += '* игра сохраняется при закрытии и загружается при открытии';
  ATextOut(16,16,W-16,H-16,'Инструкция',Text);
end;
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
  StartScreen;
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
begin
  for f: integer := 0 to Steps do
  begin
    Brush.Color := MainC;
    FillRect(0,0,W,50);
    FillRect(0,H-50,W,H);
    DrawTextCentered(0,0,W,50,'Счет: '+Score);
    DrawTextCentered(0,H-50,W,H,'Рекорд: '+Rec);
    Brush.Color := SelC;
    FillRect(0,50,W,H-50);
    case Dir of
    0: begin  end;
    1: begin  end;
    2: begin  end;
    3: begin  end;
    end;
    for i: integer := 0 to DS-1 do
    for j: integer := 0 to DS-1 do
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
  if Anim then Animate(Move, Was, 0);
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
  if Anim then Animate(Move, Was, 1);
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
  if Anim then Animate(Move, Was, 2);
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
  if Anim then Animate(Move, Was, 3);
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
    if KeyCode = VK_A then if Anim then Anim := false else Anim := true;
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