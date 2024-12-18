unit Elinor.Frame;

interface

uses
  Elinor.Party;

type
  TFrame = class(TObject)
  public
    class function Row(const ARow: Byte): Integer; overload;
    class function Row(const APosition: TPosition): Integer; overload;
    class function Col(const ACol: Byte): Integer; overload;
    class function Col(const APosition: TPosition; const APartySide: TPartySide)
      : Integer; overload;
    class function Mid: Integer;
  end;

implementation

uses
  Elinor.Scenes;

{ TFrame }

class function TFrame.Col(const ACol: Byte): Integer;
begin
  case ACol of
    0:
      Result := 10;
    1:
      Result := 332;
    2:
      Result := Mid + 654;
  else
    Result := Mid + 976;
  end;
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

class function TFrame.Mid: Integer;
begin
  Result := ScreenWidth - ((320 * 4) + 26);
end;

class function TFrame.Row(const APosition: TPosition): Integer;
begin
  Result := Row(APosition div 2);
end;

class function TFrame.Row(const ARow: Byte): Integer;
begin
  case ARow of
    0:
      Result := 220;
    1:
      Result := 340;
  else
    Result := 460;
  end;
end;

end.
