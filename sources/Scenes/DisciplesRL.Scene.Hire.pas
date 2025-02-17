unit DisciplesRL.Scene.Hire;

{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Saga,
  Elinor.Scenario,
  Elinor.Creature.Types,
  Elinor.Creatures,
  Elinor.Ability,
  Elinor.Scenes,
  Elinor.Resources,
  Elinor.Party;

type
  THireSubSceneEnum = (stSpy, stWar);

type

  { TSceneHire }

  TSceneHire = class(TScene)
  private
    class var CurrentIndex: Integer;
  strict private
    function ThiefPoisonDamage: Integer;
    function ThiefChanceOfSuccess(V: TLeaderThiefSpyVar): Integer;
    function WarriorChanceOfSuccess(V: TLeaderWarriorActVar): Integer;
    procedure RenderButtons;
    procedure Ok;
    procedure Back;
    procedure RenderSpyInfo;
    procedure RenderWarInfo;
    procedure RenderSpy(const N: TLeaderThiefSpyVar; const AX, AY: Integer);
    procedure RenderWar(const N: TLeaderWarriorActVar; const AX, AY: Integer);
  private
    procedure UpdEnum<N>(AKey: Word);
    procedure Basic(AKey: Word);
  public
    class var CurCrAbilityEnum: TAbilityEnum;
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class function HireIndex: Integer; static;
    class procedure Show(const ASubScene: THireSubSceneEnum); overload;
    class procedure Show(const Party: TParty; const Position: Integer);
      overload;
    class procedure Show(const ASubScene: THireSubSceneEnum;
      const ABackScene: TSceneEnum; const ALootRes: TResEnum); overload;
    class procedure Show(const ASubScene: THireSubSceneEnum;
      const ABackScene: TSceneEnum); overload;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Faction,
  Elinor.Statistics,
  Elinor.Common,
  Elinor.Map,
  Elinor.Button,
  Elinor.Scene.Party,
  Elinor.Scene.Battle2,
  Elinor.Scene.Settlement,
  Elinor.Items,
  Elinor.Scene.Difficulty,
  Elinor.Scene.Faction,
  Elinor.Difficulty,
  Elinor.Scene.Records,
  Elinor.Scene.Victory;

var
  CurCrEnum: TCreatureEnum;

type
  TButtonEnum = (btOk, btClose);

const
  ButtonText: array [THireSubSceneEnum] of array [TButtonEnum] of TResEnum = (
    // Thief Spy
    (reTextContinue, reTextClose),
    // Warrior War
    (reTextContinue, reTextClose)
    //
    );

const
  AddButtonScene = [];
  CloseButtonScene = AddButtonScene;
  MainButtonsScene = [stSpy, stWar];

var
  HireParty: TParty = nil;
  HirePosition: Integer = 0;
  SubScene: THireSubSceneEnum;
  BackScene: TSceneEnum;
  Button: array [THireSubSceneEnum] of array [TButtonEnum] of TButton;
  Lf, Lk: Integer;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum);
begin
  CurrentIndex := 0;
  SubScene := ASubScene;
  Game.Show(scRecruit);
end;

class procedure TSceneHire.Show(const Party: TParty; const Position: Integer);
begin

end;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum;
  const ABackScene: TSceneEnum);
begin
  SubScene := ASubScene;
  BackScene := ABackScene;
  Game.Show(scRecruit);
end;

class procedure TSceneHire.Show(const ASubScene: THireSubSceneEnum;
  const ABackScene: TSceneEnum; const ALootRes: TResEnum);
begin
  TSceneHire.Show(ASubScene, ABackScene);
end;

class function TSceneHire.HireIndex: Integer;
begin
  Result := CurrentIndex;
end;

procedure TSceneHire.Back;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  case SubScene of
    stSpy, stWar:
      Game.Show(scMap);
  end;
end;

function TSceneHire.ThiefChanceOfSuccess(V: TLeaderThiefSpyVar): Integer;
const
  S: array [TLeaderThiefSpyVar] of Byte = (95, 80, 65);
begin
  Result := S[V] - (20 - EnsureRange(TLeaderParty.Leader.Level * 2, 0, 20));
end;

function TSceneHire.WarriorChanceOfSuccess(V: TLeaderWarriorActVar): Integer;
const
  S: array [TLeaderWarriorActVar] of Byte = (100, 80, 60);
begin
  Result := S[V];
end;

function TSceneHire.ThiefPoisonDamage: Integer;
begin
  Result := CLeaderThiefPoisonDamageAllInPartyPerLevel;
end;

procedure TSceneHire.Ok;
var
  F: Boolean;
  I: Integer;

  procedure NoSpy;
  begin
    InformDialog('Вы использовали все попытки!');
  end;

  function TrySpy(V: TLeaderThiefSpyVar): Boolean;
  begin
    Result := (RandomRange(0, 100) <= ThiefChanceOfSuccess(V));
    if not Result then
    begin
      InformDialog('Вы потерпели неудачу и вступаете в схватку!');
      // TLeaderParty.Leader.PutAt(MPX, MPY);
    end;
  end;

  function TryWar(V: TLeaderWarriorActVar): Boolean;
  begin
    Result := (RandomRange(0, 100) <= WarriorChanceOfSuccess(V));
    if not Result then
    begin
      InformDialog('Вы потерпели неудачу и вступаете в схватку!');
      // TLeaderParty.Leader.PutAt(MPX, MPY);
    end;
  end;

begin
  Game.MediaPlayer.PlaySound(mmClick);
  case SubScene of
    stSpy:
      begin
        case TLeaderThiefSpyVar(CurrentIndex) of
          svIntroduceSpy:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TrySpy(svIntroduceSpy) then
                begin
                TLeaderParty.Leader.PutAt(MPX, MPY, True);
                end;
                end
                else
                NoSpy; }
            end;
          svDuel:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TrySpy(svDuel) then
                begin
                InformDialog('Вы вызвали противника на дуэль!');
                TSceneBattle2.IsDuel := True;
                TLeaderParty.Leader.PutAt(MPX, MPY);
                end;
                end
                else
                NoSpy; }
            end;
          svPoison:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TrySpy(svPoison) then
                begin
                I := TSaga.GetPartyIndex(MPX, MPY);
                Party[I].TakeDamageAll(ThiefPoisonDamage);
                InformDialog('Вы отравили все колодцы в округе!');
                end;
                end
                else
                NoSpy; }
            end
        else
          Game.Show(scMap);
        end;
      end;
    stWar:
      begin
        case TLeaderWarriorActVar(CurrentIndex) of
          avRest:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TryWar(avRest) then
                begin
                // TLeaderParty.Leader.PutAt(MPX, MPY, True);
                end;
                end
                else
                NoSpy; }
            end;
          avRitual:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TryWar(avRitual) then
                begin
                // InformDialog('Вы вызвали противника на дуэль!');
                // TSceneBattle2.IsDuel := True;
                // TLeaderParty.Leader.PutAt(MPX, MPY);
                end;
                end
                else
                NoSpy; }
            end;
          avWar3:
            begin
              { if TLeaderParty.Leader.Spy > 0 then
                begin
                TLeaderParty.Leader.Spy := TLeaderParty.Leader.Spy - 1;
                if TryWar(avWar3) then
                begin
                // I := TSaga.GetPartyIndex(MPX, MPY);
                // Party[I].TakeDamageAll(ThiefPoisonDamage);
                // InformDialog('Вы отравили все колодцы в округе!');
                end;
                end
                else
                NoSpy; }
            end
        else
          Game.Show(scMap);
        end;
      end;
  end;
end;

procedure TSceneHire.RenderSpy(const N: TLeaderThiefSpyVar;
  const AX, AY: Integer);
begin
  case N of
    svIntroduceSpy:
      DrawImage(AX + 7, AY + 7, reThiefSpy);
    svDuel:
      DrawImage(AX + 7, AY + 7, reThiefDuel);
    svPoison:
      DrawImage(AX + 7, AY + 7, reThiefPoison);
  end;
end;

procedure TSceneHire.RenderWar(const N: TLeaderWarriorActVar;
  const AX, AY: Integer);
begin
  case N of
    avRest:
      DrawImage(AX + 7, AY + 7, reWarriorRest);
    avRitual:
      DrawImage(AX + 7, AY + 7, reWarriorRitual);
    avWar3:
      DrawImage(AX + 7, AY + 7, reWarriorWar3);
  end;
end;

procedure TSceneHire.RenderSpyInfo;
var
  J: Integer;
  S: TLeaderThiefSpyVar;
begin
  TextTop := SceneTop + 6;
  TextLeft := Lf + ResImage[reFrameSlotActive].Width + 12;
  S := TLeaderThiefSpyVar(CurrentIndex);
  AddTextLine(TSaga.SpyName[S], True);
  AddTextLine;
  for J := 0 to 4 do
    AddTextLine(TSaga.SpyDescription[S][J]);
  AddTextLine;
  AddTextLine;
  AddTextLine;
  AddTextLine;
  // AddTextLine(Format('Попыток на день: %d/%d', [TLeaderParty.Leader.Spy,
  // TLeaderParty.Leader.GetMaxSpy]));
  AddTextLine(Format('Вероятность успеха: %d %', [ThiefChanceOfSuccess(S)]));
  case S of
    svPoison:
      AddTextLine(Format('Сила ядов: %d', [ThiefPoisonDamage]));
  end;
end;

procedure TSceneHire.RenderWarInfo;
var
  J: Integer;
  S: TLeaderWarriorActVar;
begin
  TextTop := SceneTop + 6;
  TextLeft := Lf + ResImage[reFrameSlotActive].Width + 12;
  S := TLeaderWarriorActVar(CurrentIndex);
  AddTextLine(TSaga.WarName[S], True);
  AddTextLine;
  for J := 0 to 4 do
    AddTextLine(TSaga.WarDescription[S][J]);
  AddTextLine;
  AddTextLine;
  AddTextLine;
  AddTextLine;
  // AddTextLine(Format('Попыток на день: %d/%d', [TLeaderParty.Leader.Spy,
  // TLeaderParty.Leader.GetMaxSpy]));
  AddTextLine(Format('Вероятность успеха: %d %', [WarriorChanceOfSuccess(S)]));
end;

procedure TSceneHire.RenderButtons;
var
  I: TButtonEnum;
begin
  if (SubScene in CloseButtonScene) then
    Button[SubScene][btOk].Render
  else
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      Button[SubScene][I].Render;
end;


{ TSceneHire }

constructor TSceneHire.Create;
var
  I: TButtonEnum;
  J: THireSubSceneEnum;
  Lc, W: Integer;
begin
  inherited;
  for J := Low(THireSubSceneEnum) to High(THireSubSceneEnum) do
  begin
    W := ResImage[reButtonDef].Width + 4;
    if (J in CloseButtonScene) then
      Lc := ScrWidth - (ResImage[reButtonDef].Width div 2)
    else
      Lc := ScrWidth - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
    for I := Low(TButtonEnum) to High(TButtonEnum) do
    begin
      Button[J][I] := TButton.Create(Lc, 600, ButtonText[J][I]);
      if not(J in CloseButtonScene) then
        Inc(Lc, W);
      if (I = btOk) then
        Button[J][I].Sellected := True;
    end;
  end;
  Lf := ScrWidth - (ResImage[reFrameSlot].Width) - 2;
  Lk := ScrWidth - (((ResImage[reFrameSlot].Width) * 2) + 2);
end;

destructor TSceneHire.Destroy;
var
  J: THireSubSceneEnum;
  I: TButtonEnum;
begin
  for J := Low(THireSubSceneEnum) to High(THireSubSceneEnum) do
    for I := Low(TButtonEnum) to High(TButtonEnum) do
      FreeAndNil(Button[J][I]);
  inherited;
end;

procedure TSceneHire.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
end;

procedure TSceneHire.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TSceneHire.Render;
var
  Left, X, Y, I: Integer;
  Z: TLeaderThiefSpyVar;
  N: TLeaderWarriorActVar;

begin
  inherited;
  Y := 0;
  X := 0;
  if SubScene in MainButtonsScene + CloseButtonScene - AddButtonScene then
    DrawImage(Lf + ResImage[reFrameSlotActive].Width + 2, SceneTop,
      reInfoFrame);
  RenderButtons;
end;

procedure TSceneHire.Timer;

begin
  inherited;
end;

procedure TSceneHire.Basic(AKey: Word);
begin
end;

procedure TSceneHire.UpdEnum<N>(AKey: Word);
begin
end;

procedure TSceneHire.Update(var Key: Word);
begin
  inherited;
end;

end.
