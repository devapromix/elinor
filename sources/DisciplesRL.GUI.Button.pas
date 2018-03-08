unit DisciplesRL.GUI.Button;

interface

uses DisciplesRL.Resources, Vcl.Graphics;

type
  TButton = class(TObject)
  private

  public
    constructor Create(ALeft, ATop: Integer; ACanvas: TCanvas; ARes: TResEnum);
    destructor Destroy; override;

  end;

implementation

{ TButton }

constructor TButton.Create(ALeft, ATop: Integer; ACanvas: TCanvas; ARes: TResEnum);
begin

end;

destructor TButton.Destroy;
begin

  inherited;
end;

end.
