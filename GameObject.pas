unit GameObject;

interface

  uses System.Types, Winapi.D2D1, Sysutils, D2DUtils, Graphics, Game;

  type TGameObject = class
    private
      PPosition: TPoint;
      PEndPosition: TPoint;
    public
      Size: TSize;
      OriginalSize: TSize;

      function GetPosition: TPoint;
      procedure SetPosition(Position: TPoint);
      property Position: TPoint read PPosition write SetPosition;

      function GetEndPosition: TPoint;
      property EndPosition: TPoint read PEndPosition;

      procedure IncreasePositionX(X: integer);
      procedure IncreasePositionY(Y: integer);

    constructor Create(Position: TPoint; FileName: string);
  end;

  function Collision(Object1, Object2: TGameObject): boolean;

implementation

  function TGameObject.GetPosition: TPoint;
  begin
    GetPosition := self.PPosition;
  end;

  procedure TGameObject.SetPosition(Position: TPoint);
  begin
    self.PPosition := Position;
    self.PEndPosition.X := self.Position.X + self.Size.X;
    self.PEndPosition.Y := self.Position.Y + self.Size.Y;
  end;

  function TGameObject.GetEndPosition: TPoint;
  begin
    GetEndPosition := self.PEndPosition;
  end;

  procedure TGameObject.IncreasePositionX(X: integer);
  begin
    if ((X < 0) and (self.Position.X > GameData.GameBounds[0].X)) or ((X > 0) and (self.EndPosition.X < GameData.GameBounds[1].X)) then
      self.SetPosition(RPoint(self.Position.X + X, self.Position.Y));
  end;

  procedure TGameObject.IncreasePositionY(Y: integer);
  begin
    if ((Y < 0) and (self.Position.Y > GameData.GameBounds[0].Y)) or ((Y > 0) and (self.EndPosition.Y < GameData.GameBounds[1].Y)) then
      self.SetPosition(RPoint(self.Position.X, self.Position.Y + Y));
  end;

  constructor TGameObject.Create(Position: TPoint; FileName: string);
  var BitMap: TBitMap;
  begin
    self.SetPosition(Position);

    BitMap := TBitMap.Create;
    BitMap.AlphaFormat := afDefined;
    BitMap.LoadFromFile(FileName);

    self.OriginalSize.X := BitMap.Width;
    self.OriginalSize.Y := BitMap.Height;
    self.Size := RSize(BitMap.Width * GameData.SizeK, BitMap.Height * GameData.SizeK);

    PEndPosition.X := Position.X + Size.X;
    PEndPosition.Y := Position.Y + Size.Y;

  end;

  function Collision(Object1, Object2: TGameObject): boolean;
  begin
      if (Object1.Position.X < Object2.Position.X + Object2.Size.X ) and
      (Object1.Position.X + Object1.Size.X > Object2.Position.X ) and
      (Object1.Position.Y < Object2.Position.Y + Object2.Size.Y ) and
      (Object1.Size.Y + Object1.Position.Y > Object2.Position.Y) then
      Result := true
    else
      Result := false;
  end;

end.
