Uses GraphABC;

{
Кнопки:
Стрелки - перемещение плиток
Пробел - новая игра
1, 2, 3 - сменить цветовое плиток
4, 5, 6 - сменить цвет фона текста
A - вкл/откл анимацию
}

var
  ///Размер окна
  W, H: integer;
  ///Код клавиши
  KeyCode: integer;
  ///Нажата ли клавиша
  KeyPressed: boolean;
  ///Массив чисел
  Numbers: array[0..3, 0..3] of integer;
  ///Прошлая позиция
  LastPos: array[0..3, 0..3] of integer;
  ///Массив для анимации
  ANumbers: array[0..3, 0..3] of integer;
  ///Для анимации
  Dir: integer;
  ///Включить анимацию
  A: boolean;
  ///Задержка между кадрами анимации
  ASleep: integer;
  ///Количество кадров анимации
  Steps: integer;
  ///Конец анимации
  StopAnim: boolean;
  ///Очки
  Score, GRecord: integer;
  ///Проигрыш
  GameOver: boolean;
  ///Цвет плиток
  TileColor: integer;
  ///Цвет фона
  BackColor: integer;
  ///Наличие файла
  FileExs: boolean;

procedure Save;
var
  ToSave: array of string;
  NowS: string;
begin
  SetLength(ToSave, 20);
  NowS := IntToStr(Score);
  for i: integer := 1 to Length(NowS) do
    Inc(NowS[i], 10);
  ToSave[0] := NowS;
  NowS := IntToStr(GRecord);
  for i: integer := 1 to Length(NowS) do
    Inc(NowS[i], 10);
  ToSave[1] := NowS;
  ToSave[2] := IntToStr(TileColor);
  ToSave[3] := IntToStr(BackColor);
  for i: integer := 0 to 3 do
    for j: integer := 0 to 3 do
      ToSave[4 + j * 4 + i] := IntToStr((Numbers[j, i]));
  WriteAllLines('Save.txt', ToSave);
end;

procedure Load;
var
  ToLoad: array of string;
  NowS: string;
begin
  if FileExists('Save.txt') then
  begin
    FileExs := true;
    ToLoad := ReadAllLines('Save.txt');
    NowS := ToLoad[0];
    for i: integer := 1 to Length(NowS) do
      Dec(NowS[i], 10);
    Score := StrToInt(NowS);
    NowS := ToLoad[1];
    for i: integer := 1 to Length(NowS) do
      Dec(NowS[i], 10);
    GRecord := StrToInt(NowS);
    TileColor := StrToInt(ToLoad[2]);
    BackColor := StrToInt(ToLoad[3]);
    for i: integer := 0 to 3 do
      for j: integer := 0 to 3 do
      begin
        Numbers[j, i] := StrToInt(ToLoad[4 + j * 4 + i]);
      end;
  end
  else
  begin
    
  end;
end;

procedure Animation;
begin
  Font.Color := clWhite;
  for k: integer := 0 to Steps do
  begin
    Brush.Color := clGray;
    FillRect(0, 0, W, H);
    for i: integer := 0 to 3 do
      for j: integer := 0 to 3 do
      begin
        if TileColor = 1 then Brush.Color := RGB(Round(255 / 16496 * LastPos[j, i]), Round(LastPos[j, i]) + 100, LastPos[j, i] + 100);
        if TileColor = 2 then Brush.Color := RGB(Round(LastPos[j, i]) + 100, Round(255 / 16496 * LastPos[j, i]), LastPos[j, i] + 100);
        if TileColor = 3 then Brush.Color := RGB(Round(LastPos[j, i]) + 100, LastPos[j, i] + 100, Round(255 / 16496 * LastPos[j, i]));
        if LastPos[j, i] > 0 then
        begin
          if Dir = 0 then
          begin
            FillRoundRect(Round(W / 4 * j) + 10,
            Round(H / 4 * i) + 10 - Round(Abs(Round(H / 4 * i) - Round(H / 4 * (i + ANumbers[j, i]))) / Steps * k),
            Round(W / 4 * (j + 1)) - 10,
            Round(H / 4 * (i + 1)) - 10 - Round(Abs(Round(H / 4 * i) - Round(H / 4 * (i + ANumbers[j, i]))) / Steps * k),
            10, 10);
            DrawTextCentered(Round(W / 4 * j) + 10, Round(H / 4 * i) + 10 - Round(Abs(Round(H / 4 * i) - Round(H / 4 * (i + ANumbers[j, i]))) / Steps * k), Round(W / 4 * (j + 1)) - 10, Round(H / 4 * (i + 1)) - 10 - Round(Abs(Round(H / 4 * i) - Round(H / 4 * (i + ANumbers[j, i]))) / Steps * k), IntToStr(LastPos[j, i]));
          end;
          if Dir = 1 then
          begin
            FillRoundRect(
            Round(W / 4 * j) + 10,
            Round(H / 4 * i) + 10 + Round(Abs(Round(H / 4 * i) - Round(H / 4 * (i + ANumbers[j, i]))) / Steps * k),
            Round(W / 4 * (j + 1)) - 10,
            Round(H / 4 * (i + 1)) - 10 + Round(Abs(Round(H / 4 * i) - Round(H / 4 * (i + ANumbers[j, i]))) / Steps * k),
            10, 10);
            DrawTextCentered(Round(W / 4 * j) + 10, Round(H / 4 * i) + 10 + Round(Abs(Round(H / 4 * i) - Round(H / 4 * (i + ANumbers[j, i]))) / Steps * k), Round(W / 4 * (j + 1)) - 10, Round(H / 4 * (i + 1)) - 10 + Round(Abs(Round(H / 4 * i) - Round(H / 4 * (i + ANumbers[j, i]))) / Steps * k), IntToStr(LastPos[j, i]));
          end;
          if Dir = 2 then
          begin
            FillRoundRect(
            Round(W / 4 * j) + 10 - Round(Abs(Round(W / 4 * j) - Round(W / 4 * (j + ANumbers[j, i]))) / Steps * k),
            Round(H / 4 * i) + 10,
            Round(W / 4 * j) - 10 - Round(Abs(Round(W / 4 * j) - Round(W / 4 * (j + ANumbers[j, i]))) / Steps * k) + Round(W / 4),
            Round(H / 4 * (i + 1)) - 10,
            10, 10);
            DrawTextCentered(Round(W / 4 * j) + 10 - Round(Abs(Round(W / 4 * j) - Round(W / 4 * (j + ANumbers[j, i]))) / Steps * k), Round(H / 4 * i) + 10, Round(W / 4 * j) + 10 - Round(Abs(Round(W / 4 * j) - Round(W / 4 * (j + ANumbers[j, i]))) / Steps * k) + Round(W / 4) - 20, Round(H / 4 * (i + 1)) - 10, IntToStr(LastPos[j, i]));
          end;
          if Dir = 3 then
          begin
            FillRoundRect(
            Round(W / 4 * j) + 10 + Round(Abs(Round(W / 4 * j) - Round(W / 4 * (j + ANumbers[j, i]))) / Steps * k),
            Round(H / 4 * i) + 10,
            Round(W / 4 * j) + 10 + Round(Abs(Round(W / 4 * j) - Round(W / 4 * (j + ANumbers[j, i]))) / Steps * k) + Round(W / 4) - 20,
            Round(H / 4 * (i + 1)) - 10,
            10, 10);
            DrawTextCentered(Round(W / 4 * j) + 10 + Round(Abs(Round(W / 4 * j) - Round(W / 4 * (j + ANumbers[j, i]))) / Steps * k), Round(H / 4 * i) + 10, Round(W / 4 * j) + 10 + Round(Abs(Round(W / 4 * j) - Round(W / 4 * (j + ANumbers[j, i]))) / Steps * k) + Round(W / 4) - 20, Round(H / 4 * (i + 1)) - 10, IntToStr(LastPos[j, i]));
          end;
        end;
      end;
    Redraw;
    Sleep(ASleep);
  end;
  StopAnim := true;
end;

procedure Draw;
begin
  if A and not StopAnim then Animation;
  Brush.Color := clGray;
  FillRect(0, 0, W, H + 50);
  Font.Color := clWhite;
  for i: integer := 0 to 3 do
    for j: integer := 0 to 3 do
    begin
      if TileColor = 1 then Brush.Color := RGB(Round(255 / 16496 * Numbers[j, i]), Round(Numbers[j, i]) + 100, Numbers[j, i] + 100);
      if TileColor = 2 then Brush.Color := RGB(Round(Numbers[j, i]) + 100, Round(255 / 16496 * Numbers[j, i]), Numbers[j, i] + 100);
      if TileColor = 3 then Brush.Color := RGB(Round(Numbers[j, i]) + 100, Numbers[j, i] + 100, Round(255 / 16496 * Numbers[j, i]));
      if Numbers[j, i] > 0 then
      begin
        FillRoundRect(Round(W / 4 * j) + 10, Round(H / 4 * i) + 10, Round(W / 4 * (j + 1)) - 10, Round(H / 4 * (i + 1)) - 10, 10, 10);
        DrawTextCentered(Round(W / 4 * j) + 10, Round(H / 4 * i) + 10, Round(W / 4 * (j + 1)) - 10, Round(H / 4 * (i + 1)) - 10, IntToStr(Numbers[j, i]));
      end;
    end;
  
  if BackColor = 1 then Brush.Color := clOrange;
  if BackColor = 2 then Brush.Color := clDarkSlateBlue;
  if BackColor = 3 then Brush.Color := clForestGreen;
  Font.Color := RGB(50, 50, 0);
  if BackColor = 2 then Font.Color := RGB(255, 200, 255);
  FillRect(0, H, W, H + 50);
  DrawTextCentered(0, H, W, H + 50, '[Score : ' + IntToStr(Score) + ']  [Record : ' + IntToStr(GRecord) + ']');
  Redraw;
end;

procedure Spawn;
var
  NX, NY: integer;
  FreeSpace: integer;
begin
  for i: integer := 0 to 3 do
    for j: integer := 0 to 3 do
      if Numbers[j, i] = 0 then FreeSpace += 1;
  if FreeSpace < 2 then GameOver := true;
  if not GameOver then
  //for i: integer := 0 to 1 do
  begin
    repeat
      NX := Random(0, 3);
      NY := Random(0, 3);
    until Numbers[NX, NY] = 0;
    Numbers[NX, NY] := 2;
    if Random(10) = 0 then Numbers[NX, NY] := 4;
  end;
end;

procedure KeyDown(key: integer);
begin
  KeyCode := key;
  KeyPressed := true;
  if KeyCode = 27 then
  begin
    Save;
    Halt;
  end;
end;

procedure KeyUp(key: integer);
begin
  KeyPressed := false
end;

procedure Control;
var
  NowP: integer;
  Stop: boolean;
begin
  while not KeyPressed do;
  if KeyPressed then
  begin
    
    if KeyCode = VK_Up then
    begin
      Dir := 0;
      StopAnim := false;
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          LastPos[j, i] := Numbers[j, i];
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          ANumbers[j, i] := 0;
      
      for i: integer := 1 to 3 do
        for j: integer := 0 to 3 do
        begin
          NowP := i;
          Stop := false;
          while not Stop do
          begin
            if Numbers[j, NowP - 1] = 0 then
            begin
              Numbers[j, NowP - 1] := Numbers[j, NowP];
              Numbers[j, NowP] := 0;
              ANumbers[j, i] += 1;
              if NowP > 1 then
                NowP -= 1
              else
                Stop := true;
            end
            else
            if Numbers[j, NowP - 1] = Numbers[j, NowP] then
            begin
              ANumbers[j, i] += 1;
              Numbers[j, NowP - 1] := Numbers[j, NowP] * 2;
              Score += Numbers[j, NowP];
              Numbers[j, NowP] := 0;
              Stop := true;
            end
            else Stop := true;
          end;
        end;
      Spawn;
    end;
    
    if KeyCode = VK_Down then
    begin
      Dir := 1;
      StopAnim := false;
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          LastPos[j, i] := Numbers[j, i];
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          ANumbers[j, i] := 0;
      
      for i: integer := 3 downto 1 do
        for j: integer := 0 to 3 do
        begin
          NowP := i;
          Stop := false;
          while not Stop do
          begin
            if Numbers[j, NowP] = 0 then
            begin
              Numbers[j, NowP] := Numbers[j, NowP - 1];
              Numbers[j, NowP - 1] := 0;
              ANumbers[j, i] += 1;
              if i < 2 then ANumbers[j, i - 1] += 1;
              if NowP < 3 then
                NowP += 1
              else
                Stop := true;
            end
            else
            if Numbers[j, NowP] = Numbers[j, NowP - 1] then
            begin
              if i < 2 then ANumbers[j, i - 1] += 1;
              Numbers[j, NowP] := Numbers[j, NowP - 1] * 2;
              Score += Numbers[j, NowP];
              Numbers[j, NowP - 1] := 0;
              Stop := true;
            end
            else Stop := true;
          end;
        end;
      Spawn;
    end;
    
    if KeyCode = VK_Left then
    begin
      Dir := 2;
      StopAnim := false;
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          LastPos[j, i] := Numbers[j, i];
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          ANumbers[j, i] := 0;
      
      for i: integer := 0 to 3 do
        for j: integer := 1 to 3 do
        begin
          NowP := j;
          Stop := false;
          while not Stop do
          begin
            if Numbers[NowP - 1, i] = 0 then
            begin
              Numbers[NowP - 1, i] := Numbers[NowP, i];
              Numbers[NowP, i] := 0;
              ANumbers[j, i] += 1;
              if NowP > 1 then
                NowP -= 1
              else
                Stop := true;
            end
            else
            if Numbers[NowP - 1, i] = Numbers[NowP, i] then
            begin
              ANumbers[j, i] += 1;
              Numbers[NowP - 1, i] := Numbers[NowP, i] * 2;
              Score += Numbers[NowP, i];
              Numbers[NowP, i] := 0;
              Stop := true;
            end
            else Stop := true;
          end;
        end;
      Spawn;
    end;
    
    if KeyCode = VK_Right then
    begin
      Dir := 3;
      StopAnim := false;
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          LastPos[j, i] := Numbers[j, i];
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          ANumbers[j, i] := 0;
      
      for i: integer := 0 to 3 do
        for j: integer := 3 downto 1 do
        begin
          NowP := j;
          Stop := false;
          while not Stop do
          begin
            if Numbers[NowP, i] = 0 then
            begin
              Numbers[NowP, i] := Numbers[NowP - 1, i];
              Numbers[NowP - 1, i] := 0;
              ANumbers[j, i] += 1;
              if j < 2 then ANumbers[j - 1, i] += 1;
              if NowP < 3 then
                NowP += 1
              else
                Stop := true;
            end
            else
            if Numbers[NowP, i] = Numbers[NowP - 1, i] then
            begin
              if j < 2 then ANumbers[j - 1, i] += 1;
              Numbers[NowP, i] := Numbers[NowP - 1, i] * 2;
              Score += Numbers[NowP, i];
              Numbers[NowP - 1, i] := 0;
              Stop := true;
            end
            else Stop := true;
          end;
        end;
      Spawn;
    end;
    
    if KeyCode = VK_Space then
    begin
      StopAnim := true;
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          LastPos[j, i] := Numbers[j, i];
      for i: integer := 0 to 3 do
        for j: integer := 0 to 3 do
          Numbers[j, i] := 0;
      GameOver := false;
      if Score > GRecord then GRecord := Score;
      Score := 0;
      Spawn;
    end;
    
    if KeyCode = VK_A then
    begin
      if A then A := false else A := true;
    end;
    
    if KeyCode = 49 then
      TileColor := 1;
    
    if KeyCode = 50 then
      TileColor := 2;
    
    if KeyCode = 51 then
      TileColor := 3;
    
    if KeyCode = 52 then
      BackColor := 1;
    
    if KeyCode = 53 then
      BackColor := 2;
    
    if KeyCode = 54 then
      BackColor := 3;
    
  end;
  while KeyPressed do;
end;

procedure StartScene;
begin
  ///Установить параметры
  Steps := 15;
  ASleep := 2;
  StopAnim := true;
  if not FileExs then
  begin
    TileColor := 1;
    BackColor := 1;
    for i: integer := 0 to 3 do
      for j: integer := 0 to 3 do
        Numbers[j, i] := 0;
    GameOver := false;
    if Score > GRecord then GRecord := Score;
    Score := 0;
    Spawn;
  end;
  
  ///Отрисовать сообщение
  if BackColor = 1 then Brush.Color := clOrange;
  if BackColor = 2 then Brush.Color := clDarkSlateBlue;
  if BackColor = 3 then Brush.Color := clForestGreen;
  FillRect(0, 0, W, H + 50);
  Font.Color := RGB(50, 50, 0);
  if BackColor = 2 then Font.Color := RGB(255, 200, 255);
  DrawTextCentered(0, 0, W, H, '2048' + newline + newline + 'Для старта нажмите любую кнопку' + newline + newline + 'Для выхода нажмите Esc' + newline + newline + newline + newline + 'Во время игры:' + newline + newline + 'Пробел - новая игра');
  Redraw;
  while KeyPressed do;
  while not KeyPressed do;
end;

procedure EndScene;
begin
  StopAnim := true;
  if BackColor = 1 then Brush.Color := clOrange;
  if BackColor = 2 then Brush.Color := clDarkSlateBlue;
  if BackColor = 3 then Brush.Color := clForestGreen;
  FillRect(0, 0, W, H + 50);
  Font.Color := RGB(50, 50, 0);
  if BackColor = 2 then Font.Color := RGB(255, 200, 255);
  DrawTextCentered(0, 0, W, H, 'Не осталось свободного пространства' + newline + newline + 'Игра закончена' + newline + newline + 'Ваш счет : ' + IntToStr(Score) + newline + newline + 'Для повторения нажмите кнопку Enter' + newline + newline + 'Для выхода нажмите Esc');
  
  Redraw;
  while KeyPressed do;
  while not KeyPressed do;
  while KeyCode <> 13 do;
  for i: integer := 0 to 3 do
    for j: integer := 0 to 3 do
      Numbers[j, i] := 0;
  GameOver := false;
  if Score > GRecord then GRecord := Score;
  Score := 0;
  Spawn;
end;

procedure ChangeAnim;
begin
  ClearWindow(clGray);
  ASleep := Round(W / (Window.Width * 1.5));
  Steps := Round(W / Window.Width * 15);
end;

begin
  Window.SetSize(400, 450);
  Window.Title := '2048';
  W := WindowWidth;
  H := WindowHeight - 50;
  Font.Size := 15;
  Font.Color := RGB(0, 200, 200);
  Randomize;
  LockDrawing;
  OnKeyDown := KeyDown;
  OnKeyUp := KeyUp;
  OnClose := Save;
  OnResize := ChangeAnim;
  Load;
  StartScene;
  while true do
  begin
    while not GameOver do
    begin
      Draw;
      Control;
    end;
    EndScene;
  end;
end.