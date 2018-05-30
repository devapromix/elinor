unit DisciplesRL.MapObject;

interface

type
  TLocation = record
    X: Integer;
    Y: Integer;
  end;

type
  TMapObject = class(TObject)
  private
    FLocation: TLocation;
  public
    constructor Create(const AX, AY: Integer);
    destructor Destroy; override;
    property Location: TLocation read FLocation write FLocation;
    procedure SetLocation(const AX, AY: Integer);
    function GetLocation: TLocation;
  end;

implementation

{ TMapObject }

constructor TMapObject.Create(const AX, AY: Integer);
begin
  FLocation.X := AX;
  FLocation.Y := AY;
end;

destructor TMapObject.Destroy;
begin

  inherited;
end;

function TMapObject.GetLocation: TLocation;
begin
  Result := FLocation;
end;

procedure TMapObject.SetLocation(const AX, AY: Integer);
begin
  FLocation.X := AX;
  FLocation.Y := AY;
end;

end.
