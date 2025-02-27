unit Elinor.Scene.Records;

interface

uses
  Vcl.Controls,
  System.Contnrs,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

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
    FFilteredList: TObjectList;
    Button: array [TButtonEnum] of TButton;
    procedure FilterByFaction;
    procedure FilterByClass;
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

{ TSceneHighScores }

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

  procedure DrawRecClassTable;
  var
    I: Integer;
    PlayerRec: TLeaderRecord;
  begin
    FFilteredList := Game.LeaderRecordsTable.FilterByFaction(CurrentIndex);
    try
      for I := 0 to FFilteredList.Count - 1 do
      begin
        PlayerRec := TLeaderRecord(FFilteredList[I]);
        AddTableLine(IntToStr(I + 1), PlayerRec.Name,
          FactionLeaderKindName[PlayerRec.PlayerClass],
          PlayerRec.Score.ToString);
      end;
    finally
      FFilteredList.Free;
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
  begin
    for LRaceCharKind := Low(TFactionLeaderKind) to High(TFactionLeaderKind) do
    begin
      LLeft := IfThen(Ord(LRaceCharKind) > 2, TFrame.Col(1), TFrame.Col(0));
      LTop := IfThen(Ord(LRaceCharKind) > 2, TFrame.Row(Ord(LRaceCharKind) - 3),
        TFrame.Row(Ord(LRaceCharKind)));
      with TCreature.Character(Characters[Game.Scenario.Faction][cgLeaders]
        [LRaceCharKind]) do
        if HitPoints > 0 then
        begin
          DrawUnit(ResEnum, LLeft, LTop, bsCharacter);
          DrawUnitInfo(LLeft, LTop, Characters[Game.Scenario.Faction][cgLeaders]
            [LRaceCharKind], False);
        end;
    end;
    TextTop := TFrame.Row(0) + 6;
    TextLeft := TFrame.Col(2) + 12;
    LFactionLeaderClass := TFactionLeaderKind(CurrentIndex);
    AddTextLine(FactionLeaderKindName[LFactionLeaderClass], True);
    AddTextLine;
    AddTableLine('##', 'Name', 'Faction', 'Scores');
    DrawRecClassTable(); // FactionName[PlayerRec.Faction]
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

  RenderButtons;
end;

class procedure TSceneRecords.ShowScene;
begin

  Game.MediaPlayer.PlaySound(mmClick);
  Game.Show(scHighScores);
end;

procedure TSceneRecords.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
    K_F:
      FilterByFaction;
    K_C:
      FilterByClass;
  end;
end;

end.
