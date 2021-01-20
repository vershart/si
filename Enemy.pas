unit Enemy;

interface

  uses System.Types, Game, GameObject, Rocket, D2DUtils;

  type TEnemyType = (Enemy1, Enemy2, Enemy3, Enemy4, Enemy5, Enemy6, Enemy7);

  type TEnemy = class (TGameObject)
    private
      PEnemyType: TEnemyType;
    public
      CanShoot: boolean;
      OutOfBounds: boolean;
      Lifes: integer;
      procedure Shoot;
      procedure IncreasePositionX;
      property EnemyType: TEnemyType read PEnemyType;
    constructor Create(EnemyType: TEnemyType; Position: TPoint);
  end;

  var EnemyBitmapPaths: array[0..7] of string;

implementation

  procedure TEnemy.Shoot;
  var ShootOrNotToShoot: integer;
  begin
    // Šaut vai nešaut?
    ShootOrNotToShoot := Random(100) + 1;
    if Odd(ShootOrNotToShoot) and self.CanShoot then
      GameData.Rockets.Add(TRocket.Create(TRocketType.Basic, -1, self.Size, self.Position));
  end;

  procedure TEnemy.IncreasePositionX;
  begin
    if (self.EndPosition.X > GameData.GameBounds[0].X) then
      self.Position := RPoint(self.Position.X - 2, self.Position.Y)
    else
      OutOfBounds := true;
  end;

  constructor TEnemy.Create(EnemyType: TEnemyType; Position: TPoint);
  begin
    inherited Create(Position, EnemyBitmapPaths[Integer(EnemyType)]);
    self.PEnemyType := EnemyType;
    self.OutOfBounds := false;

    self.Lifes := Integer(EnemyType) + 1;
    if EnemyType <> TEnemyType.Enemy1 then
      self.CanShoot := true;
  end;

  initialization
    EnemyBitmapPaths[0] := 'Assets/Enemy.bmp';
    EnemyBitmapPaths[1] := 'Assets/Enemy2.bmp';
    EnemyBitmapPaths[2] := 'Assets/Enemy3.bmp';
    EnemyBitmapPaths[3] := 'Assets/Enemy4.bmp';
    EnemyBitmapPaths[4] := 'Assets/Enemy5.bmp';
    EnemyBitmapPaths[5] := 'Assets/Enemy6.bmp';
    EnemyBitmapPaths[6] := 'Assets/Enemy7.bmp';

end.
