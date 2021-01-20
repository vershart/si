program SpaceImpact;

uses
  Vcl.Forms,
  Game in 'Game.pas',
  GameObject in 'GameObject.pas',
  Main in 'Main.pas' {Form1},
  HelpForm in 'HelpForm.pas' {Help},
  Rocket in 'Rocket.pas',
  D2DUtils in 'D2DUtils.pas',
  User in 'User.pas',
  Enemy in 'Enemy.pas',
  Bonus in 'Bonus.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(THelp, Help);
  Application.Run;
end.
