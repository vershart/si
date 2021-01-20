unit Bonus;

interface

  uses System.Types, Game, GameObject, D2DUtils;

  type TBonusType = (Life, Rockets);

  type TBonus = class (TGameObject)
    private
      PBonusType: TBonusType;
    public
      OutOfBounds: boolean;
      procedure IncreasePosition;
      property BonusType: TBonusType read PBonusType;
    constructor Create(BonusType: TBonusType; Position: TPoint);
  end;

  var BonusBitmapPaths: array[0..1] of string;

implementation

  procedure TBonus.IncreasePosition;
  begin
    if (self.EndPosition.X > GameData.GameBounds[0].X)then
      self.Position := RPoint(self.Position.X - 1, self.Position.Y)
    else
      self.OutOfBounds := true;
  end;

  constructor TBonus.Create(BonusType: TBonusType; Position: TPoint);
  begin
    inherited Create(Position, BonusBitmapPaths[Integer(BonusType)]);
    self.PBonusType := BonusType;
    self.OutOfBounds := false;
  end;

  initialization
    BonusBitmapPaths[0] := 'Assets/life.bmp';
    BonusBitmapPaths[1] := 'Assets/rockets.bmp';

end.
