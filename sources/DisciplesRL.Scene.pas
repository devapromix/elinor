unit DisciplesRL.Scene; // Game

interface

uses
  DisciplesRL.Map;

type
  TSceneEnum = (scMenu, scGame);

type
  TScene = class(TObject)
  private
  
  public
    //constructor Create;
    //destructor Destroy; override;
    procedure Render; virtual; abstract;
    procedure Update(var Key: Word); virtual; abstract;
  end;	
  
type

  { TGame }

  TGame = class(TScene)
  private
    FIsDebug: Boolean;
    FKey: Word;
    FCanClose: Boolean;
    FGameName: string;
    FGameVersion: string;
    FMap: TMap;
    procedure MainLoop;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    property GameName: string read FGameName;
    property GameVersion: string read FGameVersion;
    property IsDebug: Boolean read FIsDebug write FIsDebug;
    property CanClose: Boolean read FCanClose write FCanClose;
    property Map: TMap read FMap write FMap;
  end;

var
  Game: TGame;
  
implementation

uses
  Math,
  SysUtils,
  Classes,
  BearLibTerminal;

constructor TGame.Create;
var
  Debug: string;
begin
  inherited Create;
  FGameName := 'DisciplesRL';
  FGameVersion := 'v.0.8';
  FKey := 0;
  FCanClose := False;
  FIsDebug := (ParamCount > 0) and (Trim(ParamStr(1)) = '-d');
  terminal_open();
//  FScene[scMenu] := TSceneMenu.Create;
//  FScene[scGame] := TSceneGame.Create;
//  SceneEnum := scMenu;
  Debug := '';
  if FIsDebug then
    Debug := '[DEBUG]';
  terminal_set(Trim(Format('window.title=%s %s %s',
    [FGameName, FGameVersion, Debug])));
  writeln(Format('%s %s %s'#13#10, [FGameName, FGameVersion, Debug]));
  FMap := TMap.Create;
  terminal_set(Format('window.size=%dx%d', [Map.Width * 4, Map.Height * 2]));
  terminal_set('input.filter={keyboard, mouse+}');
  terminal_refresh();
end;

procedure TGame.MainLoop;
begin
  repeat
    Render;
    FKey := 0;
    if terminal_has_input() then
    begin
      FKey := terminal_read();
      Update(FKey);
      Continue;
    end;
    terminal_delay(1);
  until FCanClose or (FKey = TK_CLOSE);
end;

destructor TGame.Destroy;
var
  I: TSceneEnum;
begin
  FreeAndNil(FMap);
//  for I := Low(TSceneEnum) to High(TSceneEnum) do
//    FreeAndNil(FScene[I]);
  terminal_close();
  inherited;
end;

procedure TGame.Render;
begin

end;

procedure TGame.Update(var Key: Word);
begin

end;

initialization
  Game := TGame.Create;
  Game.MainLoop;
  
finalization
  FreeAndNil(Game);

end.

