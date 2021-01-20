unit Rocket;

interface

  uses SysUtils, Classes, System.Types, Game, GameObject, D2DUtils;

  type TRocketType = (Basic = 0, Big = 1);

  type TRocket = class (TGameObject)
    private
      PRocketType: TRocketType;
      PDirection: integer;
      Speed: integer;
    public
      OutOfBounds: boolean;
      procedure IncreasePosition;
      property RocketType: TRocketType read PRocketType;
      property Direction: integer read PDirection;
    constructor Create(RocketType: TRocketType; Direction: integer; Size: TSize; Position: TPoint);
  end;

  var RocketBitmapPaths: array[0..3] of string;

implementation

  procedure TRocket.IncreasePosition;
  begin
    if ((self.Direction < 0) and (self.EndPosition.X > GameData.GameBounds[0].X)) or ((self.Direction > 0) and (self.EndPosition.X < GameData.GameBounds[1].X)) then
      self.Position := RPoint(self.Position.X + self.Speed * self.Direction, self.Position.Y)
    else
      self.OutOfBounds := true;
  end;

  constructor TRocket.Create(RocketType: TRocketType; Direction: integer; Size: TSize; Position: TPoint);
  begin

    inherited Create(Position, RocketBitmapPaths[Integer(RocketType)]);
    self.Position := RPoint(Position.X + Size.X, (Position.Y + (Position.Y + Size.Y)) div 2);
    self.PDirection := Direction;
    self.PRocketType := RocketType;
    self.OutOfBounds := false;

    if Direction > 0 then
      self.Speed := 4
    else
      self.Speed := 3;

  end;

  initialization
    RocketBitmapPaths[0] := 'Assets/BasicRocket.bmp';
    RocketBitmapPaths[1] := 'Assets/BigRocket.bmp';

end.
