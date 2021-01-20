unit User;

interface

  uses Game, GameObject, D2DUtils;

  const DefaultShieldSeconds = 500;

  type TUser = class (TGameObject)
    private
      TShieldSeconds: integer;
    public
      Lifes: integer;
      BigRockets: integer;
      Shield: boolean;
      property ShieldSeconds: integer read TShieldSeconds;
      procedure SetShield;
      procedure IncreaseShield;
    constructor Create(Lifes, BigRockets: integer);
  end;

implementation

  procedure TUser.SetShield;
  begin
    self.Shield := true;
    self.TShieldSeconds := DefaultShieldSeconds;
  end;

  procedure TUser.IncreaseShield;
  begin
    if self.TShieldSeconds > 0 then
      self.TShieldSeconds := self.TShieldSeconds - 1
    else
      self.Shield := false;
  end;


  constructor TUser.Create(Lifes: Integer; BigRockets: Integer);
  begin
    inherited Create(RPoint(0,0),'Assets/bitmap.bmp');

    self.Lifes := Lifes;
    self.BigRockets := BigRockets;
    self.Shield := true;
  end;

end.
