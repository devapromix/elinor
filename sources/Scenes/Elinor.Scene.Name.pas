unit Elinor.Scene.Name;

interface

uses
  Vcl.Controls,
  Vcl.Dialogs,
  System.Classes,
  System.SysUtils,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes,
  Elinor.Common,
  Elinor.Creatures,
  Elinor.Creature.Types,
  Elinor.Faction,
  Elinor.Names;

type
  TSceneName = class(TScene)
  private type
    TButtonEnum = (btRandom, btConfirm);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextRandom,
      reTextContinue);
    MAX_NAME_LENGTH = 20;
  private
    Button: array [TButtonEnum] of TButton;
    FNewName: string;
    CursorPosition: Integer;
    CursorVisible: Boolean;
    CursorTimer: Integer;
    FLeaderFaction: TFactionEnum;
    FLeaderGender: TCreatureGender;
    FLeaderClass: TFactionLeaderKind;
    procedure ConfirmName;
    procedure GenerateRandomName;
    procedure ValidateKey(var Key: Word);
    procedure UpdateCursor;
    procedure RefreshLeaderInfo;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene;
    class procedure HideScene;
  end;

implementation

uses
  Vcl.Graphics,
  System.Math,
  Elinor.Frame,
  Elinor.Statistics,
  Elinor.Scene.Settlement,
  Elinor.NewResources;

{ TSceneName }

constructor TSceneName.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited;
  FNewName := '';
  CursorPosition := 0;
  CursorVisible := True;
  CursorTimer := 0;
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btConfirm) then
      Button[LButtonEnum].Selected := True;
  end;
end;

destructor TSceneName.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);

  inherited;
end;

procedure TSceneName.Render;
const
  NameFieldLeft = 600 + 10;
  NameFieldTop = 300 + 6;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

  procedure RenderCursor;
  var
    LCursorLeft: Integer;
  begin
    if not CursorVisible then
      Exit;
    LCursorLeft := NameFieldLeft +
      Game.Surface.Canvas.TextWidth(Copy(FNewName, 1, CursorPosition));
    DrawText(LCursorLeft, NameFieldTop, '|');
  end;

begin
  inherited;
  Game.Surface.Canvas.StretchDraw(Rect(0, 0, ScreenWidth, ScreenHeight),
    ResImage[reWallpaperScenario]);
  DrawTitle(reTitleEnterName);

  DrawImage(340, 220, reBigFrame);
  DrawText(430, 300 + 6, 'Enter Leader''s name');
  DrawImage(600, 300, reFrameItem);
  DrawText(NameFieldLeft, NameFieldTop, FNewName);
  RenderCursor;
  DrawText(550, 350, 'Faction: ' + FactionName[FLeaderFaction]);
  DrawText(550, 380, 'Gender: ' + GenderName[FLeaderGender]);
  DrawText(550, 410, 'Class: ' + FactionLeaderKindName[FLeaderClass]);

  RenderButtons;
end;

procedure TSceneName.ValidateKey(var Key: Word);
var
  CharToInsert: string;
begin
  case Key of
    K_BACKSPACE:
      if (CursorPosition > 0) and (Length(FNewName) > 0) then
      begin
        Delete(FNewName, CursorPosition, 1);
        Dec(CursorPosition);
      end;
    K_LEFT:
      if CursorPosition > 0 then
        Dec(CursorPosition);
    K_RIGHT:
      if CursorPosition < Length(FNewName) then
        Inc(CursorPosition);
    K_HOME:
      CursorPosition := 0;
    K_END:
      CursorPosition := Length(FNewName);
    K_DELETE:
      if CursorPosition < Length(FNewName) then
        Delete(FNewName, CursorPosition + 1, 1);
  else
    if ((Ord(Key) >= 65) and (Ord(Key) <= 90)) or
      ((Ord(Key) >= 97) and (Ord(Key) <= 122)) then
    begin
      if (Length(FNewName) < MAX_NAME_LENGTH) then
      begin
        CharToInsert := Char(Key);
        if CursorPosition = 0 then
          CharToInsert := UpperCase(CharToInsert)
        else
          CharToInsert := LowerCase(CharToInsert);
        Insert(CharToInsert, FNewName, CursorPosition + 1);
        Inc(CursorPosition);
      end;
    end;
  end;
  CursorVisible := True;
  CursorTimer := 0;
end;

procedure TSceneName.UpdateCursor;
begin
  Inc(CursorTimer);
  if CursorTimer >= 30 then
  begin
    CursorVisible := not CursorVisible;
    CursorTimer := 0;
  end;
end;

procedure TSceneName.Timer;
begin
  inherited;
  UpdateCursor;
end;

procedure TSceneName.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        if Button[btRandom].MouseDown then
          GenerateRandomName
        else if Button[btConfirm].MouseDown then
          ConfirmName;
      end;
  end;
end;

procedure TSceneName.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneName.ConfirmName;
var
  LName: string;
begin
  LName := Trim(FNewName);
  if (Length(LName) = 0) then
  begin
    InformDialog('Please enter a name for your character!');
    Exit;
  end;
  if (Length(LName) < 3) then
  begin
    InformDialog('Name must be at least 3 characters long!');
    Exit;
  end;
  TLeaderParty.LeaderName := FNewName;
  HideScene;
end;

procedure TSceneName.GenerateRandomName;
begin
  FNewName := GetRandomNameForFaction(AllFactionNames, FLeaderFaction,
    FLeaderGender);
  CursorPosition := Length(FNewName);
  Game.MediaPlayer.PlaySound(mmClick);
end;

procedure TSceneName.RefreshLeaderInfo;
begin
  FLeaderFaction := PartyList.Party[TLeaderParty.LeaderPartyIndex].Owner;
  FLeaderGender := PartyList.Party[TLeaderParty.LeaderPartyIndex].LeaderGender;
  FLeaderClass := PartyList.Party[TLeaderParty.LeaderPartyIndex].LeaderClass;
end;

class procedure TSceneName.ShowScene;
begin
  with TSceneName(Game.GetScene(scName)) do
  begin
    RefreshLeaderInfo;
    GenerateRandomName;
  end;
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scName);
end;

class procedure TSceneName.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlayMusic(CMusicGame);
  Game.MediaPlayer.PlaySound(mmExit);
  TSceneSettlement.ShowScene(stCapital);
end;

procedure TSceneName.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ENTER:
      ConfirmName;
    K_SPACE:
      GenerateRandomName;
  end;
  ValidateKey(Key);
end;

end.
