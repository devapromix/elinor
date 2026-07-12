unit NewResources.EchoResourceLoader;

interface

uses
  DUnitX.TestFramework,
  Elinor.NewResources;

type
  [TestFixture]
  TEchoResourceLoaderTests = class
  public
    [Test]
    procedure TestGetReturnsKey;

    [Test]
    procedure PrefixedReturnsKey;

    [Test]
    procedure TestGetKeysReturnsPrefix;
  end;

implementation

{ TEchoResourceLoaderTests }

procedure TEchoResourceLoaderTests.TestGetReturnsKey;
var
  Loader: TEchoResourceLoader;
begin
  Loader := TEchoResourceLoader.Create;
  try
    Assert.AreEqual('test_key', Loader['test_key']);
    Assert.AreEqual('another_key', Loader['another_key']);
  finally
    Loader.Free;
  end;
end;

procedure TEchoResourceLoaderTests.PrefixedReturnsKey;
var
  Loader: IResourceLoader<string>;
begin
  Loader := TPrefixedResourceLoader<string>.Create(TEchoResourceLoader.Create, 'prefix/');
  Assert.AreEqual('prefix/test_key', Loader['test_key']);
  Assert.AreEqual('prefix/another_key', Loader['another_key']);
end;

procedure TEchoResourceLoaderTests.TestGetKeysReturnsPrefix;
var
  Loader: TEchoResourceLoader;
begin
  Loader := TEchoResourceLoader.Create;
  try
    var Keys := Loader.GetKeys();
    Assert.AreEqual(1, Length(Keys));
    Assert.AreEqual('', Keys[0]);
    
    Keys := Loader.GetKeys('prefix_');
    Assert.AreEqual(1, Length(Keys));
    Assert.AreEqual('prefix_', Keys[0]);
  finally
    Loader.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TEchoResourceLoaderTests);

end.
