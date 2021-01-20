unit Game;
interface
  uses System.Types, System.Classes, Vcl.Forms, D2DUtils;

  type TGameStatus = (Paused, Action, Menu);

  type TGame = class
    private
      Window: TForm;
      WindowSize: TSize;
      PSizeK: integer;
      PStatus: TGameStatus;
    public
      Rockets: TList;
      Enemies: TList;
      Bonuses: Tlist;
      CurrentLevel: integer;
      Score: integer;
      GameBounds: array[0..1] of TPoint;
      function GetWindowSize: TSize;
      property SizeK: integer read PSizeK;
      procedure SetGameStatus(status: TGameStatus);
      property GameStatus: TGameStatus read PStatus write SetGameStatus;

    constructor Initialize(Window: TForm; WindowSize_X, WindowSize_Y: integer; UserData: string);
  end;

  var GameData: TGame;

implementation



  function TGame.GetWindowSize;
  begin
    GetWindowSize := WindowSize;
  end;

  procedure TGame.SetGameStatus(status: TGameStatus);
  begin
    self.PStatus := status;
  end;

  constructor TGame.Initialize(Window: TForm; WindowSize_X, WindowSize_Y: integer; UserData: string);
  begin
    self.Window := Window;

    self.WindowSize.X := WindowSize_X;
    self.WindowSize.Y := WindowSize_Y;

    Window.Width := WindowSize_X;
    Window.Height := WindowSize_Y;
    //self.SetSizeK(WindowSize_X div 32 div 10);
    self.PSizeK := 2;

    self.Rockets := TList.Create;
    self.Enemies := TList.Create;
    self.Bonuses := TList.Create;

    self.CurrentLevel := 1;

    self.GameBounds[0] := RPoint(0,0);
    self.GameBounds[1] := RPoint(WindowSize_X, WindowSize_Y);

    self.GameStatus := TGameStatus.Menu;

    GameData := self;

    //Window.FormStyle := TFormStyle.fsStayOnTop; // --- если произойдёт ошибка, это помешает закрыть форму
  end;



end.
