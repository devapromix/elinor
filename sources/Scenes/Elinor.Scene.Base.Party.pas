unit Elinor.Scene.Base.Party;

interface

uses
  System.Classes,
  Vcl.Controls,
  Elinor.Direction,
  Elinor.Resources,
  Elinor.Scene.Frames;

type
  TSceneBaseParty = class(TSceneFrames)
  private
    procedure MoveCursor(const AArrowKeyDirectionEnum: TArrowKeyDirectionEnum);
  public
    constructor Create(const AResEnum: TResEnum);
    destructor Destroy; override;
    procedure Render; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Update(var Key: Word); override;
    procedure GetSceneActivePartyPosition(var LX: Integer; var LY: Integer);
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Frame,
  Elinor.Scenes,
  Elinor.Party,
  Elinor.Scene.Party;

const
  PositionTransitions: array [TArrowKeyDirectionEnum, 0 .. 5] of Integer = (
    // Left
    (1, 0, 3, 2, 5, 4),
    // Right
    (1, 0, 3, 2, 5, 4),
    // Up
    (4, 5, 0, 1, 2, 3),
    // Down
    (2, 3, 4, 5, 0, 1)
    //
    );

  { TSceneSimpleMenu }

procedure TSceneBaseParty.MoveCursor(const AArrowKeyDirectionEnum
  : TArrowKeyDirectionEnum);
begin
  ActivePartyPosition := PositionTransitions[AArrowKeyDirectionEnum,
    ActivePartyPosition];
  Game.MediaPlayer.PlaySound(mmClick);
  Game.Render;
end;

constructor TSceneBaseParty.Create(const AResEnum: TResEnum);
begin
  inherited Create(AResEnum, fgLS6, fgRM2);
end;

destructor TSceneBaseParty.Destroy;
begin
  inherited;
end;

procedure TSceneBaseParty.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LPartyPosition: Integer;
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        LPartyPosition := GetPartyPosition(X, Y);
        case LPartyPosition of
          0 .. 5:
            ActivePartyPosition := LPartyPosition;
        end;
      end;
  end;
end;

procedure TSceneBaseParty.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TSceneBaseParty.Render;
var
  LX, LY: Integer;
begin
  inherited;
  GetSceneActivePartyPosition(LX, LY);
  DrawImage(LX, LY, reActFrame);
end;

procedure TSceneBaseParty.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_LEFT, K_KP_4:
      MoveCursor(kdLeft);
    K_RIGHT, K_KP_6:
      MoveCursor(kdRight);
    K_UP, K_KP_8:
      MoveCursor(kdUp);
    K_DOWN, K_KP_2:
      MoveCursor(kdDown);
  end;
end;

procedure TSceneBaseParty.GetSceneActivePartyPosition(var LX: Integer; var LY: Integer);
begin
  case ActivePartyPosition of
    0, 2, 4:
      begin
        LX := TFrame.Col(1);
        LY := TFrame.Row(ActivePartyPosition div 2);
      end;
    1, 3, 5:
      begin
        LX := TFrame.Col(0);
        LY := TFrame.Row(ActivePartyPosition div 2);
      end;
  end;
end;

end.
