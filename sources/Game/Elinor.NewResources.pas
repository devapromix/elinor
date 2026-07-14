unit Elinor.NewResources;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.StrUtils,
  System.IOUtils,
  System.JSON,
  Vcl.Imaging.PNGImage;

type
  IResourceLoader<T> = interface
    ['{8B5E8C4A-5F2D-4E8A-9B3C-7D1E2F4A6B9C}']
    function Get(const Key: string): T;
    property Items[const Key: string]: T read Get; default;
    function GetKeys(const prefix: string = ''): TArray<string>;
  end;

  TEchoResourceLoader = class(TInterfacedObject, IResourceLoader<string>)
  private
    function Get(const Key: string): string;
  public
    function GetKeys(const prefix: string = ''): TArray<string>;
    property Items[const Key: string]: string read Get; default;
  end;

  TPrefixedResourceLoader<T> = class(TInterfacedObject, IResourceLoader<T>)
  private
    FParent: IResourceLoader<T>;
    FPrefix: string;
    function Get(const Key: string): T;
  public
    constructor Create(AParent: IResourceLoader<T>; const APrefix: string);
    property Items[const Key: string]: T read Get; default;
    function GetKeys(const prefix: string = ''): TArray<string>;
  end;

  TJsonResourceLoader = class(TInterfacedObject, IResourceLoader<string>)
  private
    FSection: TJSONObject;
    function Get(const Key: string): string;
  public
    constructor Create(ARoot: TJSONObject; const ASectionName: string);
    property Items[const Key: string]: string read Get; default;
    function GetKeys(const prefix: string = ''): TArray<string>;
  end;

  TValuePathResourceLoader = class(TInterfacedObject, IResourceLoader<string>)
  private
    FParent: IResourceLoader<string>;
    FBasePath: string;
    function Get(const Key: string): string;
  public
    constructor Create(AParent: IResourceLoader<string>; const ABasePath: string);
    property Items[const Key: string]: string read Get; default;
    function GetKeys(const prefix: string = ''): TArray<string>;
  end;

  IResourceCache = interface
    ['{3F2A1B7C-8D4E-4F9A-9B2C-1E7F5A3D6B8E}']
    procedure LoadAll();
  end;

  TCachedResourceLoader<T> = class(TInterfacedObject, IResourceLoader<T>, IResourceCache)
  private
    FParent: IResourceLoader<T>;
    FCache: TDictionary<string, T>;
    function Get(const Key: string): T;
  public
    constructor Create(AParent: IResourceLoader<T>);
    destructor Destroy; override;
    property Items[const Key: string]: T read Get; default;
    function GetKeys(const prefix: string = ''): TArray<string>;
    procedure LoadAll();
  end;

  TPNGImageLoader = class(TInterfacedObject, IResourceLoader<TPNGImage>)
  private
    function Get(const Key: string): TPNGImage;
  public
    property Items[const Key: string]: TPNGImage read Get; default;
    function GetKeys(const prefix: string = ''): TArray<string>;
  end;

  TResourceSchema = class
  private
    FJsonRoot: TJSONObject;
    FMusics, FSounds: IResourceLoader<string>;
    FCharacters, FItems, FSpells: IResourceLoader<TPNGImage>;
    FCharactersCache, FItemsCache, FSpellsCache: IResourceCache;
  public
    constructor Create();
    destructor Destroy; override;
    procedure LoadAll();

    property Musics: IResourceLoader<string> read FMusics;
    property Sounds: IResourceLoader<string> read FSounds;
    property Characters: IResourceLoader<TPNGImage> read FCharacters;
    property Items: IResourceLoader<TPNGImage> read FItems;
    property Spells: IResourceLoader<TPNGImage> read FSpells;
  end;

const
  CMusicGame      = 'game';
  CMusicMagic     = 'magic';
  CMusicBattle    = 'battle';
  CMusicVictory   = 'victory';
  CMusicDefeat    = 'defeat';
  CMusicBattleWin = 'battle_win';
  CMusicMap       = 'map';
  CMusicMenu      = 'menu';

var
  R: TResourceSchema;

implementation

function TEchoResourceLoader.Get(const Key: string): string;
begin
  Result := Key;
end;

function TEchoResourceLoader.GetKeys(const prefix: string = ''): TArray<string>;
begin
  Result := TArray<string>.Create(prefix);
end;

function TCachedResourceLoader<T>.Get(const Key: string): T;
begin
  if not FCache.TryGetValue(Key, Result) then
  begin
    Result := FParent.Get(Key);
    FCache.Add(Key, Result);
  end;
end;

constructor TCachedResourceLoader<T>.Create(AParent: IResourceLoader<T>);
begin
  inherited Create;
  if not Assigned(AParent) then
    raise Exception.Create('Parent IResourceLoader must be not nil!');

  FParent := AParent;
  FCache := TDictionary<string, T>.Create;
end;

function TCachedResourceLoader<T>.GetKeys(const prefix: string = ''): TArray<string>;
begin
  Result := FParent.GetKeys(prefix);
end;

procedure TCachedResourceLoader<T>.LoadAll;
var
  keys: TArray<string>;
  key: string;
begin
  keys := FParent.GetKeys('');
  for key in keys do
    FParent[key];
end;

destructor TCachedResourceLoader<T>.Destroy;
begin
  FCache.Free;
  inherited;
end;

constructor TPrefixedResourceLoader<T>.Create(AParent: IResourceLoader<T>; const APrefix: string);
begin
  inherited Create;
  if not Assigned(AParent) then
    raise Exception.Create('Parent IResourceLoader must be not nil!');

  FParent := AParent;
  FPrefix := APrefix;
end;

function TPrefixedResourceLoader<T>.Get(const Key: string): T;
begin
  Result := FParent.Get(FPrefix + Key);
end;

function TPrefixedResourceLoader<T>.GetKeys(const prefix: string = ''): TArray<string>;
var
  LSearchRec: TSearchRec;
  LFiles: TList<string>;
begin
  LFiles := TList<string>.Create;
  try
    if FindFirst(IncludeTrailingPathDelimiter(FPrefix) + prefix + '*.*', faAnyFile, LSearchRec) = 0 then
    begin
      repeat
        if (LSearchRec.Attr and faDirectory) = 0 then
          LFiles.Add(LSearchRec.Name);
      until FindNext(LSearchRec) <> 0;
    end;
    FindClose(LSearchRec);
    Result := LFiles.ToArray;
  finally
    LFiles.Free;
  end;
end;

constructor TJsonResourceLoader.Create(ARoot: TJSONObject; const ASectionName: string);
var
  LValue: TJSONValue;
begin
  inherited Create;
  if not Assigned(ARoot) then
    raise Exception.Create('Root JSON object is nil');

  LValue := ARoot.GetValue(ASectionName);
  if not (Assigned(LValue) and (LValue is TJSONObject)) then
    raise Exception.CreateFmt('Секцію "%s" не знайдено в JSON', [ASectionName]);

  FSection := TJSONObject(LValue);
end;

function TJsonResourceLoader.Get(const Key: string): string;
var
  LValue: TJSONValue;
  CleanKey: string;
begin
  CleanKey := ChangeFileExt(ExtractFileName(Key), '');
  LValue := FSection.GetValue(CleanKey);
  if not Assigned(LValue) then
    LValue := FSection.GetValue(Key);

  if not Assigned(LValue) then
    raise Exception.CreateFmt('Ключ "%s" не знайдено в JSON', [Key]);

  Result := LValue.Value;
end;

function TJsonResourceLoader.GetKeys(const prefix: string = ''): TArray<string>;
var
  LList: TList<string>;
  LPair: TJSONPair;
begin
  LList := TList<string>.Create;
  try
    for LPair in FSection do
      if StartsText(prefix, LPair.JsonString.Value) then
        LList.Add(LPair.JsonString.Value);

    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

constructor TValuePathResourceLoader.Create(AParent: IResourceLoader<string>; const ABasePath: string);
begin
  inherited Create;
  if not Assigned(AParent) then
    raise Exception.Create('Parent IResourceLoader must be not nil!');

  FParent := AParent;
  FBasePath := IncludeTrailingPathDelimiter(ABasePath);
end;

function TValuePathResourceLoader.Get(const Key: string): string;
begin
  Result := FBasePath + FParent.Get(Key);
end;

function TValuePathResourceLoader.GetKeys(const prefix: string = ''): TArray<string>;
begin
  Result := FParent.GetKeys(prefix);
end;

function TPNGImageLoader.Get(const Key: string): TPNGImage;
begin
  Result := TPNGImage.Create;
  try
    Result.LoadFromFile(Key);
  except
    Result.Free;
    raise;
  end;
end;

function TPNGImageLoader.GetKeys(const prefix: string = ''): TArray<string>;
var
  LSearchRec: TSearchRec;
  LFiles: TList<string>;
begin
  LFiles := TList<string>.Create;
  try
    if FindFirst(IncludeTrailingPathDelimiter(prefix) + '*.*', faAnyFile, LSearchRec) = 0 then
    begin
      repeat
        if (LSearchRec.Attr and faDirectory) = 0 then
          LFiles.Add(LSearchRec.Name);
      until FindNext(LSearchRec) <> 0;
    end;
    FindClose(LSearchRec);
    Result := LFiles.ToArray;
  finally
    LFiles.Free;
  end;
end;

constructor TResourceSchema.Create;
var
  basePath, jsonPath, jsonText: string;
  png: TPNGImageLoader;
  cache: TCachedResourceLoader<TPNGImage>;
begin
  basePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)) + 'resources');

  jsonPath := basePath + 'resources.json';
  if not TFile.Exists(jsonPath) then
    raise Exception.CreateFmt('Файл ресурсів не знайдено: %s', [jsonPath]);

  jsonText := TFile.ReadAllText(jsonPath, TEncoding.UTF8);
  FJsonRoot := TJSONObject.ParseJSONValue(jsonText) as TJSONObject;
  if not Assigned(FJsonRoot) then
    raise Exception.CreateFmt('Не вдалося розпарсити JSON: %s', [jsonPath]);

  FMusics := TValuePathResourceLoader.Create(
    TJsonResourceLoader.Create(FJsonRoot, 'music'), basePath + 'music\');

  FSounds := TValuePathResourceLoader.Create(
    TJsonResourceLoader.Create(FJsonRoot, 'sounds'), basePath + 'sounds');

  png := TPNGImageLoader.Create;

  cache := TCachedResourceLoader<TPNGImage>.Create(
    TPrefixedResourceLoader<TPNGImage>.Create(png, basePath + 'characters'));
  FCharacters := cache;
  FCharactersCache := cache;

  cache := TCachedResourceLoader<TPNGImage>.Create(
    TPrefixedResourceLoader<TPNGImage>.Create(png, basePath + 'items'));
  FItems := cache;
  FItemsCache := cache;

  cache := TCachedResourceLoader<TPNGImage>.Create(
    TPrefixedResourceLoader<TPNGImage>.Create(png, basePath + 'spells\'));
  FSpells := cache;
  FSpellsCache := cache;
end;

destructor TResourceSchema.Destroy;
begin
  FMusics := nil;
  FSounds := nil;
  FJsonRoot.Free;
  inherited;
end;

procedure TResourceSchema.LoadAll;
begin
  FCharactersCache.LoadAll;
  FItemsCache.LoadAll;
  FSpellsCache.LoadAll;
end;

initialization
  R := TResourceSchema.Create;
  R.LoadAll;

finalization
  FreeAndNil(R);

end.
