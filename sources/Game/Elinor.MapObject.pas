unit Elinor.MapObject;

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
    constructor Create(const AX, AY: Integer); overload;
    constructor Create; overload;
    destructor Destroy; override;
    property Location: TLocation read FLocation write FLocation;
    procedure SetLocation(const AX, AY: Integer); overload;
    procedure SetLocation(const ALocation: TLocation); overload;
    function GetLocation: TLocation;
    property X: Integer read FLocation.X;
    property Y: Integer read FLocation.Y;
  end;

implementation

constructor TMapObject.Create(const AX, AY: Integer);
begin
  FLocation.X := AX;
  FLocation.Y := AY;
end;

constructor TMapObject.Create;
begin
  Create(0, 0);
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

procedure TMapObject.SetLocation(const ALocation: TLocation);
begin
  FLocation := ALocation;
end;

end.
