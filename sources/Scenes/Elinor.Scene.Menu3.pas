unit Elinor.Scene.Menu3;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

interface

uses
{$IFDEF FPC}
  Controls,
{$ELSE}
  Vcl.Controls,
{$ENDIF}
  Classes,
  Elinor.Button,
  Elinor.Common,
  Elinor.Resources,
  Elinor.Scenes;

{ Malavien's Camp	My mercenaries will join your army ... for a price.
  Guther's Camp	My soldiers are the finest in the region.
  Turion's Camp	My soldiers are the most formidable in the land.
  Uther's Camp	Are you in need of recruits?
  Dennar's Camp	We will join your army, for a price.
  Purthen's Camp	My mercenaries will join your army ... for a price.
  Luther's Camp	My soldiers are the finest in the region.
  Richard's Camp	My soldiers are the most formidable in the land.
  Ebbon's Camp	Are you in need of recruits?
  Righon's Camp	We will join your army, for a price.
  Kigger's Camp	My mercenaries will join your army ... for a price.
  Luggen's Camp	My soldiers are the finest in the region.
  Werric's Camp	My soldiers are the most formidable in the land.
  Xennon's Camp	Are you in need of recruits? }

type

  { TSceneMenu2 }

  TSceneMenu3 = class(TScene)
  private type
    TButtonEnum = (btPlay, btContinue);
    TIconEnum = (itHighScores, itQuit);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextPlay, reTextContinue);
    IconDef: array [TIconEnum] of TResEnum = (reIconScores, reIconClosedGates);
    IconOver: array [TIconEnum] of TResEnum = (reIconScoresOver,
      reIconOpenedGates);
  private
    // ButtonCycler: specialize TEnumCycler<TButtonEnum>;
    CursorPos: TButtonEnum;
    Button: array [TButtonEnum] of TButton;
    Icons: array [TIconEnum] of TIcon;
    procedure Next;
    procedure Quit;
    procedure ConfirmQuit;
    procedure PlayGame;
    procedure ContinueGame;
    procedure ShowHighScores;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  end;

implementation

uses
  Math,
  SysUtils,
  Elinor.Saga,
  DisciplesRL.Scene.Hire,
  Elinor.Scene.HighScores;

procedure TSceneMenu3.Next;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  case CursorPos of
    btPlay:
      PlayGame;
    btContinue:
      ContinueGame;
  end;
end;

procedure TSceneMenu3.Quit;
begin
  Halt;
end;

procedure TSceneMenu3.ConfirmQuit;
begin
  ConfirmDialog('Завершить игру?', {$IFDEF MODEOBJFPC}@{$ENDIF}Quit);
end;

procedure TSceneMenu3.PlayGame;
begin
  Game.IsGame := False;
  Game.Show(scScenario);
end;

procedure TSceneMenu3.ContinueGame;
begin
  if Game.IsGame then
  begin
    Game.MediaPlayer.PlayMusic(mmMap);
    Game.Show(scMap);
  end;
end;

procedure TSceneMenu3.ShowHighScores;
begin
  TSceneHighScores.ShowScene;
end;

{ TSceneMenu }

constructor TSceneMenu3.Create;
var
  L, T, H: Integer;
  I: TButtonEnum;
  J: TIconEnum;
begin
  inherited;
  L := ScrWidth - (ResImage[reButtonDef].Width div 2);
  H := ResImage[reButtonDef].Height + 10;
  T := 500 - ((H * (Ord(High(TButtonEnum)) + 1)) div 2);
  for I := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[I] := TButton.Create(L, T, ButtonText[I]);
    if (I = btPlay) then
      Button[I].Sellected := True;
    Inc(T, H);
  end;

  L := 20;
  T := 500;
  for J := Low(TIconEnum) to High(TIconEnum) do
  begin
    Icons[J] := TIcon.Create(L, T, IconDef[J], IconOver[J]);
    Inc(T, 84);
  end;
end;

destructor TSceneMenu3.Destroy;
var
  I: TButtonEnum;
  J: TIconEnum;
begin
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[I]);
  for J := Low(TIconEnum) to High(TIconEnum) do
    FreeAndNil(Icons[J]);
  inherited;
end;

procedure TSceneMenu3.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  I: TButtonEnum;
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        for I := Low(TButtonEnum) to High(TButtonEnum) do
          if Button[I].MouseDown then
          begin
            CursorPos := I;
            Next;
          end;
        if Icons[itHighScores].MouseDown then
          ShowHighScores;
        if Icons[itQuit].MouseDown then
          ConfirmQuit;
      end;
  end;
end;

procedure TSceneMenu3.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: TButtonEnum;
  J: TIconEnum;
begin
  inherited;
  for I := Low(TButtonEnum) to High(TButtonEnum) do
    Button[I].MouseMove(X, Y);
  for J := Low(TIconEnum) to High(TIconEnum) do
    Icons[J].MouseMove(X, Y);
  Game.Render;
end;

procedure TSceneMenu3.Render;

  procedure RenderButtons;
  var
    I: TButtonEnum;
  begin
    for I := Low(TButtonEnum) to High(TButtonEnum) do
    begin
      Button[I].Sellected := (I = CursorPos);
      Button[I].Render;
    end;
  end;

  procedure RenderIcons;
  var
    J: TIconEnum;
  begin
    for J := Low(TIconEnum) to High(TIconEnum) do
      Icons[J].Render;
  end;

begin
  inherited;
  DrawImage(reWallpaperMenu);
  DrawTitle(reTitleLogo);
  RenderButtons;
  RenderIcons;
  DrawText(650, '2018-2025 by Apromix');
end;

procedure TSceneMenu3.Timer;
begin
  inherited;

end;

procedure TSceneMenu3.Update(var Key: Word);
var
  LButtonCycler: TEnumCycler<TButtonEnum>;
begin
  inherited;
  LButtonCycler := TEnumCycler<TButtonEnum>.Create(Ord(CursorPos));
  case Key of
    K_ENTER:
      Next;
    K_ESCAPE:
      ConfirmQuit;
    K_S:
      ShowHighScores;
    K_UP:
      CursorPos := LButtonCycler.Prev;
    // IIF(CursorPos = ButtonMin, ButtonMax, Pred(CursorPos));
    // CursorPos := TButtonEnum(EnsureRange(Ord(CursorPos) - 1, 0,
    // Ord(High(TButtonEnum))));
    K_DOWN:
      CursorPos := LButtonCycler.Next;
    // CursorPos := TButtonEnum(EnsureRange(Ord(CursorPos) + 1, 0,
    // Ord(High(TButtonEnum))));
  end;
end;

end.
