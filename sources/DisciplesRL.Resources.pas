unit DisciplesRL.Resources;

interface

uses Vcl.Imaging.PNGImage;

type
  TResEnum = (reNone, reGrass, reUnk, reEnemies, reCursor, rePlayer, reDark, reBag, reCity, reCapital);

type
  TResTypeEnum = (teNone, teTile, teGUI, tePath, teObject, teEnemy, teBag, teCapital, teCity, teRuin);

type
  TResBase = record
    FileName: string;
    ResType: TResTypeEnum;
  end;

const
  ResBase: array [TResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teNone;),
    // Grass
    (FileName: 'grass.png'; ResType: teTile;),
    // Unknown (?)
    (FileName: 'unknown.png'; ResType: teGUI;),
    // Enemy party
    (FileName: 'enemies.png'; ResType: teEnemy;),
    // Frame
    (FileName: 'select.png'; ResType: teGUI;),
    // Player
    (FileName: 'player.png'; ResType: teObject;),
    // Fog
    (FileName: 'transparent.png'; ResType: teGUI;),
    // Bag
    (FileName: 'chest.png'; ResType: teBag;),
    // City
    (FileName: 'city.png'; ResType: teCity;),
    // Capital
    (FileName: 'castle.png'; ResType: teCapital;)
    //
    );

var
  ResImage: array [TResEnum] of TPNGImage;

procedure Init;
procedure Free;

implementation

uses System.SysUtils, Vcl.Graphics, DisciplesRL.Utils;

procedure Init;
var
  I: TResEnum;
begin
  for I := Low(TResEnum) to High(TResEnum) do
  begin
    ResImage[I] := TPNGImage.Create;
    if (ResBase[I].FileName <> '') then
      ResImage[I].LoadFromFile(Utils.GetPath('resources') + ResBase[I].FileName);
  end;
end;

procedure Free;
var
  I: TResEnum;
begin
  for I := Low(TResEnum) to High(TResEnum) do
    FreeAndNil(ResImage[I]);
end;

end.
