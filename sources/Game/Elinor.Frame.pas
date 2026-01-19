unit Elinor.Frame;

interface

uses
  Elinor.Party;

type
  TFrame = class(TObject)
  public
    class function Row(const ARow: Byte): Integer; overload;
    class function Row(const APosition: TPosition): Integer; overload;
    class function Row(const APosition: TPosition; const APartySide: TPartySide)
      : Integer; overload;
    class function Col(const ACol: Byte): Integer; overload;
    class function Col(const APosition: TPosition; const APartySide: TPartySide)
      : Integer; overload;
  end;

implementation

uses
  Elinor.Scenes;

{ TFrame }

const
  CMid = ScreenWidth - ((320 * 4) + 26);
  CRows: array [0 .. 2] of Integer = (220, 340, 460);
  CCols: array [0 .. 3] of Integer = (10, 332, CMid + 654, CMid + 976);

class function TFrame.Row(const ARow: Byte): Integer;
begin
  if ARow <= High(CRows) then
    Result := CRows[ARow]
  else
    Result := CRows[High(CRows)];
end;

class function TFrame.Col(const ACol: Byte): Integer;
begin
  if ACol <= High(CCols) then
    Result := CCols[ACol]
  else
    Result := CCols[High(CCols)];
end;

class function TFrame.Col(const APosition: TPosition;
  const APartySide: TPartySide): Integer;
begin
  case APosition of
    0, 2, 4:
      begin
        case APartySide of
          psLeft:
            Result := Col(1);
        else
          Result := Col(2);
        end;
      end;
  else
    begin
      case APartySide of
        psLeft:
          Result := Col(0);
      else
        Result := Col(3);
      end;
    end;
  end;
end;

class function TFrame.Row(const APosition: TPosition;
  const APartySide: TPartySide): Integer;
begin
  case APartySide of
    psLeft:
      Row(APosition div 2);
  end;
end;

class function TFrame.Row(const APosition: TPosition): Integer;
begin
  Result := Row(APosition div 2);
end;

end.
