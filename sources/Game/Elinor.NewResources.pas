unit Elinor.NewResources;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.StrUtils,
  Vcl.Imaging.PNGImage;

type
  // Базовый интерфейс для чтения данных о ресурсах
  IResourceLoader<T> = interface
    /// <summary>
    /// Возвращает объект по ключу. Если ключ не найден — бросает ***.
    /// </summary>
    function Get(const Key: string): T;

    property Items[const Key: string]: T read Get; default;

    /// <summary>
    /// Возвращает ключи всех доступных ресурсов, которые начинаются с префикса.
    /// </summary>
    function GetKeys(const prefix: string = ''): TArray<string>;
  end;

  // возвращает сам ключ
  // использовать в тех местах, где нужен только путь к файлу
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

  IResourceCache = interface
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
    FMusics, FSounds: IResourceLoader<string>;

    FCharacters, FItems, FSpells: IResourceLoader<TPNGImage>;

    FCharactersCache, FItemsCache, FSpellsCache: IResourceCache;

  public
    constructor Create();
    procedure LoadAll();
    property Musics: IResourceLoader<string> read FMusics;
    property Sounds: IResourceLoader<string> read FSounds;
    property Characters: IResourceLoader<TPNGImage> read FCharacters;
    property Items: IResourceLoader<TPNGImage> read FItems;
    property Spells: IResourceLoader<TPNGImage> read FSpells;
  end;

const
  CMusicGame = 'soliloquy';
  CMusicMagic = 'wasteland-theme';
  CMusicBattle = 'wasteland-showdown';
  CMusicVictory = 'warsong';
  CMusicDefeat = 'defeat';
  CMusicBattleWin = 'ubermensch';
  CMusicMap = 'prologue';
  CMusicMenu = 'stellardrone';

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

procedure TCachedResourceLoader<T>.LoadAll();
var keys: TArray<string>; key: string;
begin
  keys := FParent.GetKeys();
  for key in keys do
  begin
    FParent[key];
  end;
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
  LFileName: string;
  LFiles: TList<string>;
begin
  LFiles := TList<string>.Create();
  try
    if FindFirst(FPrefix + prefix + '*.*', faAnyFile, LSearchRec) = 0 then
    begin
      repeat
        LFileName := LSearchRec.Name;
        if (LSearchRec.Attr and faDirectory) = 0 then
        begin
          LFiles.Add(LFileName);
        end;
      until FindNext(LSearchRec) <> 0;
    end;
    FindClose(LSearchRec);
    Result := LFiles.ToArray();
  finally
    LFiles.Free;
  end;
end;

function TPNGImageLoader.Get(const Key: string): TPNGImage;
var
  LPath: string;
begin
  Result := TPNGImage.Create;
  Result.LoadFromFile(Key);
end;

function TPNGImageLoader.GetKeys(const prefix: string = ''): TArray<string>;
var
  LSearchRec: TSearchRec;
  LFileName: string;
  LFiles: TList<string>;
begin
  LFiles := TList<string>.Create();
  try
    if FindFirst(prefix + '*.*', faAnyFile, LSearchRec) = 0 then
    begin
      repeat
        LFileName := LSearchRec.Name;
        if (LSearchRec.Attr and faDirectory) = 0 then
        begin
          LFiles.Add(LFileName);
        end;
      until FindNext(LSearchRec) <> 0;
    end;
    FindClose(LSearchRec);
    Result := LFiles.ToArray();
  finally
    LFiles.Free;
  end;
end;

constructor TResourceSchema.Create();
var
  basePath: string;
  echo: IResourceLoader<string>;
  png: TPNGImageLoader;
  cache: TCachedResourceLoader<TPNGImage>;
begin
  basePath := ExtractFilePath(ParamStr(0)) + 'resources/';

  echo := TEchoResourceLoader.Create();
  FMusics := TPrefixedResourceLoader<string>.Create(echo, basePath + 'music/');
  FSounds := TPrefixedResourceLoader<string>.Create(echo, basePath + 'sounds/');

  png := TPNGImageLoader.Create();
  cache := TCachedResourceLoader<TPNGImage>.Create(
    TPrefixedResourceLoader<TPNGImage>.Create(png, basePath + 'characters/')
  );
  FCharacters := cache;
  FCharactersCache := cache;

  cache := TCachedResourceLoader<TPNGImage>.Create(
    TPrefixedResourceLoader<TPNGImage>.Create(png, basePath + 'items/')
  );
  FItems := cache;
  FItemsCache := cache;

  cache := TCachedResourceLoader<TPNGImage>.Create(
    TPrefixedResourceLoader<TPNGImage>.Create(png, basePath + 'spells/')
  );
  FSpells := cache;
  FSpellsCache := cache;
end;

procedure TResourceSchema.LoadAll();
begin
  FCharactersCache.LoadAll();
  FItemsCache.LoadAll();
  FSpellsCache.LoadAll();
end;

initialization

R := TResourceSchema.Create();
R.LoadAll();

finalization

R.Free;

end.
