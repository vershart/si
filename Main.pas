unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.D2D1, Direct2D, Vcl.ExtCtrls, Game, GameObject, User,
  Enemy, Rocket, Bonus, Vcl.StdCtrls, D2DUtils, MMSystem, HelpForm,
  Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    timingApp: TTimer;
    ListBox1: TListBox;
    enemyTime: TTimer;
    bonusTime: TTimer;
    Menu: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PauseMenu: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Image1: TImage;
    procedure timingAppTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DrawBonuses;
    procedure DrawUser;
    procedure DrawEnemies;
    procedure RunBigRocket;
//    procedure DrawGrid; только для тестов
    procedure DrawRockets;
    procedure OnEnemyTimeTimer(Sender: TObject);
    procedure OnGameWin();
    procedure bonusTimeTimer(Sender: TObject);
    procedure DisplayMenu;
    procedure DisplayPauseMenu;
    procedure MenuItemSelected(Sender: TObject);
    procedure MenuItemDeselected(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    FD2DCanvas: TDirect2DCanvas;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
    procedure CreateD2DResources; virtual;
    procedure PaintD2D; virtual;
    function rt: ID2D1RenderTarget;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property D2DCanvas: TDirect2DCanvas read FD2DCanvas;
  end;

var
  Form1: TForm1;
  game: TGame;
  user: TUser;
  FGreenBrush, FBlackBrush, FRedBrush: ID2D1SolidColorBrush;
  UserBitmap: ID2D1Bitmap;
  RocketBitmaps, EnemyBitmaps: array[0..7] of ID2D1Bitmap;
  Backgrounds: array[1..7] of ID2D1Bitmap;
  BonusBitmaps: array[0..1] of ID2D1Bitmap;

implementation

{$R *.dfm}

procedure TForm1.bonusTimeTimer(Sender: TObject);
var bonus: TBonus;
begin
  bonus := TBonus.Create(TBonusType(Random(2)), RPoint(Screen.Width, Random(game.GetWindowSize.Y - 32 * game.SizeK)));
  game.Bonuses.Add(bonus);
end;

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;

  if not TDirect2DCanvas.Supported then
    raise Exception.Create('Direct2D не поддерживается!');

  game := TGame.Initialize(Main.Form1, Screen.Width, Screen.Height, '');
  game.SetGameStatus(TGameStatus.Menu);

  FD2DCanvas := TDirect2DCanvas.Create(Handle);
  CreateD2DResources;

end;

destructor TForm1.Destroy;
begin
  FD2DCanvas.Free;
  inherited;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if game.GameStatus = TGameStatus.Action then
  begin
    case Key of
      VK_DOWN: user.IncreasePositionY(16);
      VK_UP: user.IncreasePositionY(-16);
      VK_LEFT: user.IncreasePositionX(-16);
      VK_RIGHT: user.IncreasePositionX(16);
      VK_SHIFT: RunBigRocket;
      VK_SPACE:
        game.Rockets.Add(TRocket.Create(TRocketType.Basic, 1, user.Size, user.Position));
    end;
  end;
  if Key = VK_ESCAPE then
    DisplayPauseMenu;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
  ShowCursor(false);
  user := TUser.Create(3, 3);
  game := TGame.Initialize(Main.Form1, Screen.Width, Screen.Height, '');
  game.SetGameStatus(TGameStatus.Menu);
  timingApp.Enabled := true;
  enemyTime.Enabled := true;
  bonusTime.Enabled := true;
  Menu.Visible := false;
  ListBox1.Visible := true;
  game.GameStatus := TGameStatus.Action;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin
  Help.Show;
end;

procedure TForm1.Label3Click(Sender: TObject);
begin
  Form1.Destroy;
  Application.Terminate;
end;

procedure TForm1.Label5Click(Sender: TObject);
begin
  ShowCursor(false);
  PauseMenu.Visible := false;
  timingApp.Enabled := true;
  enemyTime.Enabled := true;
  bonusTime.Enabled := true;
  game.GameStatus := TGameStatus.Action;
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
  user.Free;
  game.GameStatus := TGameStatus.Menu;
  timingApp.Enabled := false;
  enemyTime.Enabled := false;
  bonusTime.Enabled := false;
  PauseMenu.Visible := false;
  Menu.Visible := true;
  ListBox1.Visible := false;
end;

procedure TForm1.MenuItemDeselected(Sender: TObject);
begin
  (Sender as TLabel).Font.Color := clBlack;
end;

procedure TForm1.MenuItemSelected(Sender: TObject);
begin
  (Sender as TLabel).Font.Color := clRed;
end;

procedure TForm1.RunBigRocket;
begin
  if user.BigRockets > 0 then
  begin
    game.Rockets.Add(TRocket.Create(TRocketType.Big, 1, user.Size, user.Position));
    user.BigRockets := user.BigRockets - 1;
  end;
end;

procedure TForm1.CreateD2DResources;
begin

  // resources

  rt.CreateSolidColorBrush(
    D2D1ColorF(clGreen, 1),
    nil,
    FGreenBrush
    );

  rt.CreateSolidColorBrush(
    D2D1ColorF(clBlack, 1),
    nil,
    FBlackBrush
    );

  Backgrounds[1] := CreateBitmap('Assets/Background.bmp', rt);
  Backgrounds[2] := CreateBitmap('Assets/Background2.bmp', rt);
  Backgrounds[3] := CreateBitmap('Assets/Background3.bmp', rt);
  Backgrounds[4] := CreateBitmap('Assets/Background4.bmp', rt);
  Backgrounds[5] := CreateBitmap('Assets/Background5.bmp', rt);
  Backgrounds[6] := CreateBitmap('Assets/Background6.bmp', rt);
  Backgrounds[7] := CreateBitmap('Assets/Background.bmp', rt);

  RocketBitmaps[0] := CreateBitmap('Assets/BasicRocket.bmp', rt);
  RocketBitmaps[1] := CreateBitmap('Assets/BigRocket.bmp', rt);

  EnemyBitmaps[0] := CreateBitmap('Assets/Enemy.bmp', rt);
  EnemyBitmaps[1] := CreateBitmap('Assets/Enemy2.bmp', rt);
  EnemyBitmaps[2] := CreateBitmap('Assets/Enemy3.bmp', rt);
  EnemyBitmaps[3] := CreateBitmap('Assets/Enemy4.bmp', rt);
  EnemyBitmaps[4] := CreateBitmap('Assets/Enemy5.bmp', rt);
  EnemyBitmaps[5] := CreateBitmap('Assets/Enemy6.bmp', rt);
  EnemyBitmaps[6] := CreateBitmap('Assets/Enemy7.bmp', rt);

  BonusBitmaps[0] := CreateBitmap('Assets/life.bmp', rt);
  BonusBitmaps[1] := CreateBitmap('Assets/rockets.bmp', rt);

  UserBitmap := CreateBitmap('Assets/bitmap.bmp', rt);

  SndPlaySound('Assets/MainTheme.wav', SND_ASYNC or SND_LOOP);

end;

function TForm1.rt: ID2D1RenderTarget;
begin
  Result := D2DCanvas.RenderTarget;
end;

procedure CreateEnemy();
var enemy: TEnemy;
begin
  enemy := TEnemy.Create(TEnemyType(Random(game.CurrentLevel)), RPoint(Screen.Width, Random(Screen.Height - 32 * game.SizeK)));
  game.Enemies.Add(enemy);
  enemy.Shoot;
end;

procedure TForm1.OnGameWin();
begin
  timingApp.Enabled := false;
  enemyTime.Enabled := false;
  bonusTime.Enabled := false;
  ShowMessage('Jūs vinnējāt! Zeme tagad ir saglabāta!');
  user.Free;
  game.GameStatus := TGameStatus.Menu;
  ListBox1.Visible := false;
end;

procedure TForm1.OnEnemyTimeTimer(Sender: TObject);
begin
  CreateEnemy();

  if (game.Score >= 200) then
  begin
    game.CurrentLevel := 2;
    enemyTime.Interval := 5000;
  end;

  if (game.Score >= 400) then
  begin
    game.CurrentLevel := 3;
    enemyTime.Interval := 4500;
  end;

  if (game.Score >= 750) then
  begin
    game.CurrentLevel := 4;
    enemyTime.Interval := 4000;
  end;

  if (game.Score >= 1000) then
  begin
    game.CurrentLevel := 5;
    enemyTime.Interval := 3500;
  end;

  if (game.Score >= 2000) then
  begin
    game.CurrentLevel := 6;
    enemyTime.Interval := 2500;
  end;

  if (game.Score >= 4000) then
    game.CurrentLevel := 7;

  if game.CurrentLevel = 7 then
  begin

  end;
end;

procedure TForm1.timingAppTimer(Sender: TObject);
begin
  Form1.Paint;
end;

procedure TForm1.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TForm1.Paint;
begin
  inherited;
  D2DCanvas.BeginDraw;
  try
    PaintD2D;
  finally
    D2DCanvas.EndDraw;
  end;
end;

procedure TForm1.DrawUser;
var rect: D2D1_RECT_F;
    ShieldOpacity: Extended;
begin

  rect.left := user.Position.X;
  rect.right := user.EndPosition.X;
  rect.top := user.Position.Y;
  rect.bottom := user.EndPosition.Y;
  rt.DrawBitmap(UserBitmap, @rect, 1, 1, nil);

  ListBox1.Items.Add('Dzīves: ' + IntToStr(user.Lifes));
  ListBox1.Items.Add('Punktu skaits: ' + IntToStr(game.Score));
  ListBox1.Items.Add('Līmenis: ' + IntToStr(game.CurrentLevel));
  ListBox1.Items.Add('Lielas raķetes: ' + IntToStr(user.BigRockets));

  if user.Shield then
  begin

    ShieldOpacity := (user.ShieldSeconds / 5) / 100;

    rt.CreateSolidColorBrush(
    D2D1ColorF(clRed, ShieldOpacity),
    nil,
    FRedBrush
    );

    rt.DrawRectangle(rect, FRedBrush, 1, nil);
    user.IncreaseShield;
  end;
end;

procedure TForm1.DrawBonuses;
var i: integer;
    bonus: TBonus;
    rect: D2D1_RECT_F;
begin
    i := 0;
  while (game.Bonuses.Count > 0) and (i < game.Bonuses.Count) do
  begin
    bonus := TBonus(game.Bonuses[i]);

    rect.left := bonus.Position.X;
    rect.right := bonus.EndPosition.X;
    rect.top := bonus.Position.Y;
    rect.bottom := bonus.EndPosition.Y;

    rt.DrawBitmap(BonusBitmaps[Integer(bonus.BonusType)], @rect, 1, 1, nil);

    bonus.IncreasePosition;
    if (bonus.OutOfBounds = true) and (i < game.Bonuses.Count) then
    begin
      game.Bonuses.Delete(i);
      FreeAndNil(bonus);
      exit;
    end;


    if Collision(bonus, user) then
    begin
      if bonus.BonusType = TBonusType.Life then
        Inc(user.Lifes);
      if bonus.BonusType = TBonusType.Rockets then
        Inc(user.BigRockets);
      game.Bonuses.Delete(i);
      FreeAndNil(bonus);
      exit;
    end;

    Inc(i);
  end;
end;

{
  Только для теста сетки
}
//procedure TForm1.DrawGrid;
//var i: integer;
//begin
//  for i := 0 to 64 do
//  begin
//     rt.DrawLine(RPoint(32 * i, 0), RPoint(32 * i, GameData.GetWindowSize.Y), FGreenBrush, 1);
//     rt.DrawLine(RPoint(0, 32 * i), RPoint(GameData.GetWindowSize.X, 32 * i), FGreenBrush, 1);
//  end;
//end;

procedure TForm1.DrawRockets;
var i: integer;
    rocket: TRocket;
    rect: D2D1_RECT_F;
begin
  i := 0;
  while (game.Rockets.Count > 0) and (i < game.Rockets.Count) do
  begin
    rocket := TRocket(game.Rockets[i]);

    rect.left := rocket.Position.X;
    rect.right := rocket.EndPosition.X;
    rect.top := rocket.Position.Y;
    rect.bottom := rocket.EndPosition.Y;

    rt.DrawBitmap(RocketBitmaps[Integer(rocket.RocketType)], @rect, 1, 1, nil);

    rocket.IncreasePosition;
    if (rocket.OutOfBounds = true) and (i < game.Rockets.Count) then
      game.Rockets.Delete(i);

    if Collision(rocket, user) and (rocket.Direction < 0) then
    begin
      if user.Shield then
      begin
        game.Rockets.Delete(i);
        FreeAndNil(rocket);
        exit;
      end;
      if user.Lifes = 1 then
      begin
        game.Rockets.Delete(i);
        FreeAndNil(rocket);
        ShowMessage('Jums vairs nav dzīves. Jūs zaudējat!');
        Application.Terminate;
      end
      else
      begin
        game.Rockets.Delete(i);
        FreeAndNil(rocket);
        user.Lifes := user.Lifes - 1;
        user.SetShield;
      end;
    end;

    Inc(i);
  end;

end;

procedure TForm1.DrawEnemies;
var i,j: integer;
    enemy: TEnemy;
    rocket: TRocket;
    rect: D2D1_RECT_F;
begin
  i := 0;
  j := 0;
  while (game.Enemies.Count > 0) and (i < game.Enemies.Count) do
  begin

    enemy := TEnemy(game.Enemies[i]);

    while (game.Rockets.Count > 0) and (j < game.Rockets.Count) do
    begin
      rocket := TRocket(game.Rockets[j]);
      if Collision(rocket, enemy) and (rocket.Direction > 0) then
      begin
        if (rocket.RocketType = TRocketType.Big) or (enemy.Lifes = 1) then
        begin
          game.Score := game.Score + 20 * (Integer(enemy.EnemyType) + 1);
          game.Enemies.Delete(i);
          game.Rockets.Delete(j);
          FreeAndNil(rocket);
          FreeAndNil(enemy);
          exit;
        end
        else
        begin
          enemy.Lifes := enemy.Lifes - 1;
          game.Rockets.Delete(j);
          FreeAndNil(rocket);
        end;

      end;
      Inc(j);
    end;

    rect.left := enemy.Position.X;
    rect.right := enemy.EndPosition.X;
    rect.top := enemy.Position.Y;
    rect.bottom := enemy.EndPosition.Y;

    rt.DrawBitmap(EnemyBitmaps[Integer(enemy.EnemyType)], @rect, 1, 1, nil);

    enemy.IncreasePositionX;

    if (enemy.OutOfBounds = true) and (i < game.Enemies.Count) then
    begin
      timingApp.Enabled := false;
      enemyTime.Enabled := false;
      ShowMessage('Jūs zaudējāt. Ienaidnieks dodas uz Zemes.');
      Application.Terminate;
    end;

    if Collision(game.Enemies[i], user) then
    begin
      if (user.Lifes > 1) or (user.Shield) then
      begin
        game.Enemies.Delete(i);
        FreeAndNil(enemy);
        if not user.Shield then
        begin
          user.Lifes := user.Lifes - 1;
          user.SetShield;
        end;
      end
      else
      begin
        timingApp.Enabled := false;
        ShowMessage('Jūs zaudējāt! Jums beidzas dzīves.');
        Application.Terminate;
      end;
    end;


    Inc(i);
  end;

end;

procedure TForm1.DisplayPauseMenu;
begin
  if game.GameStatus = TGameStatus.Action then
  begin
    game.GameStatus := TGameStatus.Paused;
    ShowCursor(true);
    PauseMenu.Visible := true;
    timingApp.Enabled := false;
    enemyTime.Enabled := false;
    bonusTime.Enabled := false;
  end;
end;

procedure TForm1.DisplayMenu;
begin
  Menu.Visible := true;
end;

procedure TForm1.PaintD2D;
var rect: D2D1_RECT_F;
begin
  rt.Clear(D2D1ColorF(clGreen));
  rect.left := 0;
  rect.top := 0;
  rect.right := game.GetWindowSize.X;
  rect.bottom := game.GetWindowSize.Y;
  rt.DrawBitmap(Backgrounds[game.CurrentLevel], @rect, 1, 1, nil);

  if game.GameStatus = TGameStatus.Menu then
    DisplayMenu;
  if game.GameStatus = TGameStatus.Paused then
    DisplayPauseMenu;
  if game.GameStatus = TGameStatus.Action then
  begin
    DrawBonuses;
    DrawRockets;
    //DrawGrid; { только в тестовых случаях. отображает сетку игрового поля }
    DrawUser;
    DrawEnemies;
  end;

end;

end.
