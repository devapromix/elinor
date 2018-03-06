unit DisciplesRL.Resources;

interface

uses Vcl.Imaging.PNGImage;

type
  TResEnum = (reNone, reNeutral, reEmpireTerrain, reUnk, reEnemies, reCursor, rePlayer, reDark, reGold, reBag,
    reNeutralCity, reEmpireCity, reEmpireCapital, reRuin, reTower, reTreePine, reTreeOak, reMine, reMountain);

type
  TResTypeEnum = (teNone, teTree, teTile, teGUI, tePath, teObject, teEnemy, teBag, teRes, teCapital, teCity,
    teRuin, teTower, teMine);

type
  TResBase = record
    FileName: string;
    ResType: TResTypeEnum;
  end;

const
  ResBase: array [TResEnum] of TResBase = (
    // None
    (FileName: ''; ResType: teNone;),
    // Neutral
    (FileName: 'dirt.png'; ResType: teTile;),
    // Empire terrain
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
    // Gold
    (FileName: 'gold.png'; ResType: teRes;),
    // Bag
    (FileName: 'chest.png'; ResType: teBag;),
    // Neutral City
    (FileName: 'city.png'; ResType: teCity;),
    // Empire City
    (FileName: 'city.png'; ResType: teCity;),
    // Empire Capital
    (FileName: 'castle.png'; ResType: teCapital;),
    // Ruin
    (FileName: 'ruin.png'; ResType: teRuin;),
    // Tower
    (FileName: 'tower.png'; ResType: teTower;),
    // Pine
    (FileName: 'tree.pine.png'; ResType: teTree;),
    // Oak
    (FileName: 'tree.oak.png'; ResType: teTree;),
    // Mine
    (FileName: 'mine.png'; ResType: teMine;),
    // Mountain
    (FileName: 'mountain.png'; ResType: teObject;)
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
      ResImage[I].LoadFromFile(GetPath('resources') + ResBase[I].FileName);
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