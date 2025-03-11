unit Elinor.Scene.Records;

interface

uses
  Vcl.Controls,
  System.Contnrs,
  System.Classes,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Direction,
  Elinor.Scenes,
  Elinor.Scene.Frames;

type
  TSceneRecords = class(TSceneFrames)
  private type
    TButtonEnum = (btFaction, btClass, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextFaction, reTextClass,
      reTextClose);
  private
    FCurrentIndex: Integer;
    FFilterByFaction: Boolean;
    Button: array [TButtonEnum] of TButton;
    procedure FilterByFaction;
    procedure FilterByClass;
    procedure MoveCursor(const AArrowKeyDirectionEnum: TArrowKeyDirectionEnum);
  public
    constructor Create;
    destructor Destroy; override;
    property CurrentIndex: Integer read FCurrentIndex write FCurrentIndex;
    procedure Render; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Update(var Key: Word); override;
    class procedure ShowScene;
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Scenario,
  Elinor.Frame,
  Elinor.Creatures,
  Elinor.Faction,
  Elinor.Records,
  Elinor.RecordsTable;

{ TSceneRecords }

procedure TSceneRecords.MoveCursor(const AArrowKeyDirectionEnum
  : TArrowKeyDirectionEnum);
begin
  CurrentIndex := PositionTransitions[AArrowKeyDirectionEnum, CurrentIndex];
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Render;
end;

constructor TSceneRecords.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperLeader, fgLS6, fgRB);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btClose) then
      Button[LButtonEnum].Sellected := True;
  end;
  FFilterByFaction := True;
  FCurrentIndex := 0;
end;

destructor TSceneRecords.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneRecords.FilterByClass;
begin
  FFilterByFaction := False;
end;

procedure TSceneRecords.FilterByFaction;
begin
  FFilterByFaction := True;
end;

class procedure TSceneRecords.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scMenu);
end;

procedure TSceneRecords.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LPartyPosition: Integer;
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        LPartyPosition := GetFramePosition(X, Y);
        case LPartyPosition of
          0 .. 5:
            begin
              CurrentIndex := LPartyPosition;
              Game.MediaPlayer.PlaySound(mmClick);
              Exit;
            end;
        end;
        if Button[btFaction].MouseDown then
          FilterByFaction
        else if Button[btClass].MouseDown then
          FilterByClass
        else if Button[btClose].MouseDown then
          HideScene
      end;
  end;

end;

procedure TSceneRecords.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneRecords.Render;
var
  LScenarioEnum: TScenarioEnum;
  LX, LY: Integer;

  procedure DrawRecFactionTable;
  var
    I: Integer;
    LLeaderRecord: TLeaderRecord;
    LFilteredList: TObjectList;
  begin
    LFilteredList := Game.LeaderRecordsTable.FilterByClass(CurrentIndex);
    try
      for I := 0 to LFilteredList.Count - 1 do
      begin
        LLeaderRecord := TLeaderRecord(LFilteredList[I]);
        AddTableLine(IntToStr(I + 1), LLeaderRecord.Name,
          FactionName[LLeaderRecord.Faction], LLeaderRecord.Score.ToString);
      end;
    finally
      LFilteredList.Free;
    end;
  end;

  procedure DrawRecClassTable;
  var
    I: Integer;
    LLeaderRecord: TLeaderRecord;
    LFilteredList: TObjectList;
  begin
    LFilteredList := Game.LeaderRecordsTable.FilterByFaction(CurrentIndex);
    try
      for I := 0 to LFilteredList.Count - 1 do
      begin
        LLeaderRecord := TLeaderRecord(LFilteredList[I]);
        AddTableLine(IntToStr(I + 1), LLeaderRecord.Name,
          FactionLeaderKindName[LLeaderRecord.PlayerClass],
          LLeaderRecord.Score.ToString);
      end;
    finally
      LFilteredList.Free;
    end;
  end;

  procedure RenderFaction;
  var
    LPlayableRaces: TPlayableFactions;
    LFactionEnum: TFactionEnum;
  const
    LPlayableRacesImage: array [TPlayableFactions] of TResEnum =
      (reTheEmpireLogo, reUndeadHordesLogo, reLegionsOfTheDamnedLogo);
  begin
    for LPlayableRaces := Low(TPlayableFactions) to High(TPlayableFactions) do
    begin
      DrawImage(TFrame.Col(0) + 7, TFrame.Row(Ord(LPlayableRaces)) + 7,
        LPlayableRacesImage[LPlayableRaces]);
    end;
    if CurrentIndex > 2 then
      Exit;
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    LFactionEnum := TFactionEnum(CurrentIndex);
    AddTextLine(FactionName[LFactionEnum], True);
    AddTextLine;
    AddTableLine('##', 'Name', 'Class', 'Scores');
    DrawRecClassTable;
  end;

  procedure RenderClass;
  var
    LRaceCharKind: TFactionLeaderKind;
    LFactionLeaderClass: TFactionLeaderKind;
    LLeft, LTop: Integer;
  const
    LPlayableRacesImage: array [TFactionLeaderKind] of TResEnum =
      (reWarriorLogo, reScoutLogo, reMageLogo, reThiefLogo, reLordLogo,
      reTemplarLogo);
  begin
    for LRaceCharKind := Low(TFactionLeaderKind) to High(TFactionLeaderKind) do
    begin
      LLeft := IfThen(Ord(LRaceCharKind) > 2, TFrame.Col(1), TFrame.Col(0));
      LTop := IfThen(Ord(LRaceCharKind) > 2, TFrame.Row(Ord(LRaceCharKind) - 3),
        TFrame.Row(Ord(LRaceCharKind)));
      if (Ord(LRaceCharKind) > 4) then
        Break;
      DrawImage(LLeft + 7, LTop + 7, LPlayableRacesImage[LRaceCharKind]);
    end;
    if CurrentIndex > 4 then
      Exit;
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    LFactionLeaderClass := TFactionLeaderKind(CurrentIndex);
    AddTextLine(FactionLeaderKindName[LFactionLeaderClass], True);
    AddTextLine;
    AddTableLine('##', 'Name', 'Faction', 'Scores');
    DrawRecFactionTable();
  end;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;
  DrawTitle(reTitleHighScores);

  if FFilterByFaction then
    RenderFaction
  else
    RenderClass;

  case CurrentIndex of
    0 .. 2:
      begin
        LX := TFrame.Col(0);
        LY := TFrame.Row(CurrentIndex);
      end;
    3 .. 5:
      begin
        LX := TFrame.Col(1);
        LY := TFrame.Row(CurrentIndex - 3);
      end;
  end;
  DrawImage(LX, LY, reFrameSlotActive);

  RenderButtons;
end;

class procedure TSceneRecords.ShowScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scRecords);
end;

procedure TSceneRecords.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
    K_LEFT, K_KP_4:
      MoveCursor(kdLeft);
    K_RIGHT, K_KP_6:
      MoveCursor(kdRight);
    K_UP, K_KP_8:
      MoveCursor(kdUp);
    K_DOWN, K_KP_2:
      MoveCursor(kdDown);
    K_F:
      FilterByFaction;
    K_C:
      FilterByClass;
  end;
end;

end.
