unit D2DUtils;

interface

  uses Winapi.Windows, Vcl.Controls, Winapi.D2D1, Vcl.Direct2D,
  Vcl.Graphics, System.Classes, System.SysUtils, System.Generics.Collections,
  Winapi.DxgiFormat;

  type TSize = record
    X: integer;
    Y: integer;
  end;

  function RPoint(X, Y: integer): TPoint;
  function RSize(X, Y: integer): TSize;

  function CreateBitmap(Bitmap: TBitmap; renderTarget: ID2D1RenderTarget): ID2D1Bitmap; overload;
  function CreateBitmap(Bitmap: string; renderTarget: ID2D1RenderTarget): ID2D1Bitmap; overload;

implementation

  function RPoint(X, Y: integer): TPoint;
  var a: TPoint;
  begin
    a.X := X;
    a.Y := Y;
    RPoint := a;
  end;

  function RSize(X, Y: integer): TSize;
  var a: TSize;
  begin
    a.X := X;
    a.Y := Y;
    RSize := a;
  end;

function CreateBitmap(Bitmap: TBitmap; renderTarget: ID2D1RenderTarget): ID2D1Bitmap;
var
  BitmapInfo: TBitmapInfo;
  buf: array of Byte;
  BitmapProperties: TD2D1BitmapProperties;
  Hbmp: HBitmap;

begin
  Bitmap.AlphaFormat := afDefined;
  FillChar(BitmapInfo, SizeOf(BitmapInfo), 0);
  BitmapInfo.bmiHeader.biSize := Sizeof(BitmapInfo.bmiHeader);
  BitmapInfo.bmiHeader.biHeight := -Bitmap.Height;
  BitmapInfo.bmiHeader.biWidth := Bitmap.Width;
  BitmapInfo.bmiHeader.biPlanes := 1;
  BitmapInfo.bmiHeader.biBitCount := 32;

  SetLength(buf, Bitmap.Height * Bitmap.Width * 4);
  // Forces evaluation of Bitmap.Handle before Bitmap.Canvas.Handle
  Hbmp := Bitmap.Handle;
  GetDIBits(Bitmap.Canvas.Handle, Hbmp, 0, Bitmap.Height, @buf[0], BitmapInfo, DIB_RGB_COLORS);

  BitmapProperties.dpiX := 0;
  BitmapProperties.dpiY := 0;
  BitmapProperties.pixelFormat.format := DXGI_FORMAT_B8G8R8A8_UNORM;
  if (Bitmap.PixelFormat <> pf32bit) or (Bitmap.AlphaFormat = afIgnored) then
    BitmapProperties.pixelFormat.alphaMode := D2D1_ALPHA_MODE_IGNORE
  else
    BitmapProperties.pixelFormat.alphaMode := D2D1_ALPHA_MODE_PREMULTIPLIED;


  renderTarget.CreateBitmap(D2D1SizeU(Bitmap.Width, Bitmap.Height), @buf[0], 4*Bitmap.Width, BitmapProperties, Result)
end;

function CreateBitmap(Bitmap: string; renderTarget: ID2D1RenderTarget): ID2D1Bitmap;
var bmp: TBitMap;
begin
  bmp := TBitMap.Create;
  bmp.LoadFromFile(BitMap);
  Result := CreateBitMap(bmp, renderTarget);
  bmp.Free;
end;

end.
