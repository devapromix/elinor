unit Elinor.Scene.Base.Party;

interface

uses
  System.Classes,
  Vcl.Controls,
  Elinor.Resources,
  Elinor.Scene.Frames;

type
  TSceneBaseParty = class(TSceneFrames)
  public
    constructor Create(const AResEnum: TResEnum);
    destructor Destroy; override;
    procedure Render; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Update(var Key: Word); override;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Frame,
  Elinor.Scenes,
  Elinor.Party,
  Elinor.Scene.Party;

{ TSceneSimpleMenu }

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
  DrawImage(LX, LY, reActFrame);
end;

procedure TSceneBaseParty.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_UP:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case ActivePartyPosition of
          2, 3, 4, 5:
            ActivePartyPosition := ActivePartyPosition - 2;
          0, 1:
            ActivePartyPosition := ActivePartyPosition + 4;
        end;
      end;
    K_DOWN:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case ActivePartyPosition of
          0, 1, 2, 3:
            ActivePartyPosition := ActivePartyPosition + 2;
          4, 5:
            ActivePartyPosition := ActivePartyPosition - 4;
        end;
      end;
    K_LEFT, K_RIGHT:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case ActivePartyPosition of
          0, 2, 4:
            ActivePartyPosition := ActivePartyPosition + 1;
          1, 3, 5:
            ActivePartyPosition := ActivePartyPosition - 1;
        end;
      end;
  end;
end;

end.
