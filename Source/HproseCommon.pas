{
/**********************************************************\
|                                                          |
|                          hprose                          |
|                                                          |
| Official WebSite: http://www.hprose.com/                 |
|                   http://www.hprose.org/                 |
|                                                          |
\**********************************************************/

/**********************************************************\
 *                                                        *
 * HproseCommon.pas                                       *
 *                                                        *
 * hprose common unit for delphi.                         *
 *                                                        *
 * LastModified: Sep 13, 2014                             *
 * Author: Ma Bingyao <andot@hprose.com>                  *
 *                                                        *
\**********************************************************/
}
unit HproseCommon;

{$I Hprose.inc}

interface

uses Classes, SyncObjs, SysUtils, TypInfo, Variants;

type

{$IFDEF FPC}
  UInt64 = QWord;
{$ENDIF}

{$IFNDEF DELPHI2009_UP}
  RawByteString = type AnsiString;
{$IFDEF CPU64}
  NativeInt = Int64;
  NativeUInt = UInt64;
{$ELSE}
  NativeInt = Integer;
  NativeUInt = Cardinal;
{$ENDIF}
{$ENDIF}

  THproseResultMode = (Normal, Serialized, Raw, RawWithEndTag);

{$IF NOT DEFINED(DELPHI2007_UP) AND NOT DEFINED(FPC)}
  TBytes = array of Byte;
{$IFEND}

  TVariants = array of Variant;
  PVariants = ^TVariants;

  TConstArray = array of TVarRec;

  EHproseException = class(Exception);
  EHashBucketError = class(Exception);
  EArrayListError = class(Exception);

  IHproseFilter = interface
  ['{4AD7CCF2-1121-4CA4-92A7-5704C5956BA4}']
    function InputFilter(const Data: TBytes; const Context: TObject): TBytes;
    function OutputFilter(const Data: TBytes; const Context: TObject): TBytes;
  end;

  IInvokeableVarObject = interface
  ['{FDC126C2-EF9F-4898-BF97-87C01B050F88}']
    function Invoke(const Name: string; const Arguments: TVarDataArray): Variant;
  end;

  IListEnumerator = interface
  ['{767477EC-A143-4DC6-9962-A6837A7AEC01}']
    function GetCurrent: Variant;
    function MoveNext: Boolean;
    property Current: Variant read GetCurrent;
  end;

  IList = interface(IReadWriteSync)
  ['{DE925411-42B8-4DB3-A00C-B585C087EC4C}']
    function Get(Index: Integer): Variant;
    procedure Put(Index: Integer; const Value: Variant);
    function GetCapacity: Integer;
    function GetCount: Integer;
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    function Add(const Value: Variant): Integer;
    procedure AddAll(const ArrayList: IList); overload;
    procedure AddAll(const Container: Variant); overload;
    procedure Assign(const Source: IList);
    procedure Clear;
    function Contains(const Value: Variant): Boolean;
    function Delete(Index: Integer): Variant;
    procedure Exchange(Index1, Index2: Integer);
    function GetEnumerator: IListEnumerator;
    function IndexOf(const Value: Variant): Integer;
    procedure Insert(Index: Integer; const Value: Variant);
    function Join(const Glue: string = ',';
                  const LeftPad: string = '';
                  const RightPad: string = ''): string;
    procedure InitLock;
    procedure InitReadWriteLock;
    procedure Lock;
    procedure Unlock;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(const Value: Variant): Integer;
    function ToArray: TVariants; overload;
    function ToArray(VarType: TVarType): Variant; overload;
    property Item[Index: Integer]: Variant read Get write Put; default;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
  end;

  TAbstractList = class(TInterfacedObject, IList)
  private
    FLock: TCriticalSection;
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  protected
    function Get(Index: Integer): Variant; virtual; abstract;
    procedure Put(Index: Integer; const Value: Variant); virtual; abstract;
    function GetCapacity: Integer; virtual; abstract;
    function GetCount: Integer; virtual; abstract;
    procedure SetCapacity(NewCapacity: Integer); virtual; abstract;
    procedure SetCount(NewCount: Integer); virtual; abstract;
  public
    constructor Create(Capacity: Integer = 4; Sync: Boolean = True;
      ReadWriteSync: Boolean = False); overload; virtual; abstract;
    constructor Create(Sync: Boolean;
      ReadWriteSync: Boolean = False); overload; virtual; abstract;
    destructor Destroy; override;
    function Add(const Value: Variant): Integer; virtual; abstract;
    procedure AddAll(const ArrayList: IList); overload; virtual; abstract;
    procedure AddAll(const Container: Variant); overload; virtual; abstract;
    procedure Assign(const Source: IList); virtual;
    procedure Clear; virtual; abstract;
    function Contains(const Value: Variant): Boolean; virtual; abstract;
    function Delete(Index: Integer): Variant; virtual; abstract;
    procedure Exchange(Index1, Index2: Integer); virtual; abstract;
    function GetEnumerator: IListEnumerator; virtual;
    function IndexOf(const Value: Variant): Integer; virtual; abstract;
    procedure Insert(Index: Integer; const Value: Variant); virtual; abstract;
    function Join(const Glue: string = ',';
                  const LeftPad: string = '';
                  const RightPad: string = ''): string; virtual;
    class function Split(Str: string; const Separator: string = ',';
      Limit: Integer = 0; TrimItem: Boolean = False;
      SkipEmptyItem: Boolean = False; Sync: Boolean = True;
      ReadWriteSync: Boolean = False): IList; virtual;
    procedure InitLock;
    procedure InitReadWriteLock;
    procedure Lock;
    procedure Unlock;
    procedure BeginRead;
    procedure EndRead;
    function BeginWrite: Boolean;
    procedure EndWrite;
    procedure Move(CurIndex, NewIndex: Integer); virtual; abstract;
    function Remove(const Value: Variant): Integer; virtual; abstract;
    function ToArray: TVariants; overload; virtual; abstract;
    function ToArray(VarType: TVarType): Variant; overload; virtual; abstract;
    property Item[Index: Integer]: Variant read Get write Put; default;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
  end;

  TListClass = class of TAbstractList;

  IArrayList = interface(IList)
  ['{0D12803C-6B0B-476B-A9E3-C219BF651BD1}']
  end;

  TArrayList = class(TAbstractList, IArrayList)
  private
    FCount: Integer;
    FCapacity: Integer;
    FList: TVariants;
  protected
    function Get(Index: Integer): Variant; override;
    procedure Grow; virtual;
    procedure Put(Index: Integer; const Value: Variant); override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetCount(NewCount: Integer); override;
  public
    constructor Create(Capacity: Integer = 4; Sync: Boolean = True;
      ReadWriteSync: Boolean = False); overload; override;
    constructor Create(Sync: Boolean;
      ReadWriteSync: Boolean = False); overload; override;
{$IFDEF BCB}
    constructor Create0; virtual; // for C++ Builder
    constructor Create1(Capacity: Integer); virtual; // for C++ Builder
    constructor Create2(Capacity: Integer; Sync: Boolean); virtual; // for C++ Builder
    constructor CreateS(Sync: Boolean); virtual; // for C++ Builder
{$ENDIF}
    function Add(const Value: Variant): Integer; override;
    procedure AddAll(const AList: IList); overload; override;
    procedure AddAll(const Container: Variant); overload; override;
    procedure Clear; override;
    function Contains(const Value: Variant): Boolean; override;
    function Delete(Index: Integer): Variant; override;
    procedure Exchange(Index1, Index2: Integer); override;
    function IndexOf(const Value: Variant): Integer; override;
    procedure Insert(Index: Integer; const Value: Variant); override;
    procedure Move(CurIndex, NewIndex: Integer); override;
    function Remove(const Value: Variant): Integer; override;
    function ToArray: TVariants; overload; override;
    function ToArray(VarType: TVarType): Variant; overload; override;
    property Item[Index: Integer]: Variant read Get write Put; default;
    property Count: Integer read GetCount write SetCount;
    property Capacity: Integer read GetCapacity write SetCapacity;
  end;

  PHashItem = ^THashItem;

  THashItem = record
    Next: PHashItem;
    Index: Integer;
    HashCode: Integer;
  end;

  THashItemDynArray = array of PHashItem;

  TIndexCompareMethod = function (Index: Integer;
    const Value: Variant): Boolean of object;

  THashBucket = class(TObject)
  private
    FCount: Integer;
    FFactor: Single;
    FCapacity: Integer;
    FIndices: THashItemDynArray;
    procedure Grow;
    procedure SetCapacity(NewCapacity: Integer);
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75);
    destructor Destroy; override;
    function Add(HashCode, Index: Integer): PHashItem;
    procedure Clear;
    procedure Delete(HashCode, Index: Integer);
    function IndexOf(HashCode: Integer; const Value: Variant;
      CompareProc: TIndexCompareMethod): Integer;
    function Modify(OldHashCode, NewHashCode, Index: Integer): PHashItem;
    property Count: Integer read FCount;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  IHashedList = interface(IArrayList)
  ['{D2392014-7451-40EF-809E-D25BFB0FA661}']
  end;

  THashedList = class(TArrayList, IHashedList)
  private
    FHashBucket: THashBucket;
  protected
    function HashOf(const Value: Variant): Integer; virtual;
    function IndexCompare(Index: Integer; const Value: Variant):
      Boolean; virtual;
    procedure Put(Index: Integer; const Value: Variant); override;
  public
    constructor Create(Capacity: Integer = 4; Sync: Boolean = True;
      ReadWriteSync: Boolean = False); overload; override;
    constructor Create(Capacity: Integer; Factor: Single; Sync: Boolean = True;
      ReadWriteSync: Boolean = False); reintroduce; overload; virtual;
{$IFDEF BCB}
    constructor Create3(Capacity: Integer; Factor: Single;
      Sync: Boolean); virtual; // for C++ Builder
{$ENDIF}
    destructor Destroy; override;
    function Add(const Value: Variant): Integer; override;
    procedure Clear; override;
    function Delete(Index: Integer): Variant; override;
    procedure Exchange(Index1, Index2: Integer); override;
    function IndexOf(const Value: Variant): Integer; override;
    procedure Insert(Index: Integer; const Value: Variant); override;
  end;

  ICaseInsensitiveHashedList = interface(IHashedList)
  ['{9ECA15EC-9486-4BF6-AADD-BBD88890FAF8}']
  end;

  TCaseInsensitiveHashedList = class(THashedList, ICaseInsensitiveHashedList)
  protected
    function HashOf(const Value: Variant): Integer; override;
    function IndexCompare(Index: Integer; const Value: Variant):
      Boolean; override;
{$IFDEF BCB}
  public
    constructor Create4(Capacity: Integer; Factor: Single; Sync,
      ReadWriteSync: Boolean); virtual; // for C++ Builder
{$ENDIF}
  end;

  TMapEntry = record
    Key: Variant;
    Value: Variant;
  end;

  IMapEnumerator = interface
  ['{5DE7A194-4476-42A6-A1E7-CB1D20AA7B0A}']
    function GetCurrent: TMapEntry;
    function MoveNext: Boolean;
    property Current: TMapEntry read GetCurrent;
  end;

  IMap = interface(IReadWriteSync)
  ['{28B78387-CB07-4C28-B642-09716DAA2170}']
    procedure Assign(const Source: IMap);
    function GetCount: Integer;
    function GetKeys: IList;
    function GetValues: IList;
    function GetKey(const Value: Variant): Variant;
    function Get(const Key: Variant): Variant;
    procedure Put(const Key, Value: Variant);
    procedure Clear;
    function ContainsKey(const Key: Variant): Boolean;
    function ContainsValue(const Value: Variant): Boolean;
    function Delete(const Key: Variant): Variant;
    function GetEnumerator: IMapEnumerator;
    function Join(const ItemGlue: string = ';';
                  const KeyValueGlue: string = '=';
                  const LeftPad: string = '';
                  const RightPad: string = ''): string;
    procedure InitLock;
    procedure InitReadWriteLock;
    procedure Lock;
    procedure Unlock;
    procedure PutAll(const AList: IList); overload;
    procedure PutAll(const AMap: IMap); overload;
    procedure PutAll(const Container: Variant); overload;
    function ToList(ListClass: TListClass; Sync: Boolean = True;
      ReadWriteSync: Boolean = False): IList;
    property Count: Integer read GetCount;
    property Key[const Value: Variant]: Variant read GetKey;
    property Value[const Key: Variant]: Variant read Get write Put; default;
    property Keys: IList read GetKeys;
    property Values: IList read GetValues;
  end;

  TAbstractMap = class(TInterfacedObject, IMap)
  private
    FLock: TCriticalSection;
    FReadWriteLock: TMultiReadExclusiveWriteSynchronizer;
  protected
    procedure Assign(const Source: IMap);
    function GetCount: Integer; virtual; abstract;
    function GetKeys: IList; virtual; abstract;
    function GetValues: IList; virtual; abstract;
    function GetKey(const Value: Variant): Variant; virtual; abstract;
    function Get(const Key: Variant): Variant; virtual; abstract;
    procedure Put(const Key, Value: Variant); virtual; abstract;
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); overload; virtual; abstract;
    constructor Create(Sync: Boolean;
      ReadWriteSync: Boolean = False); overload; virtual; abstract;
    destructor Destroy; override;
    procedure Clear; virtual; abstract;
    function ContainsKey(const Key: Variant): Boolean; virtual; abstract;
    function ContainsValue(const Value: Variant): Boolean; virtual; abstract;
    function Delete(const Key: Variant): Variant; virtual; abstract;
    function GetEnumerator: IMapEnumerator; virtual;
    function Join(const ItemGlue: string = ';';
                  const KeyValueGlue: string = '=';
                  const LeftPad: string = '';
                  const RightPad: string = ''): string; virtual;
    class function Split(Str: string; const ItemSeparator: string = ';';
      const KeyValueSeparator: string = '='; Limit: Integer = 0;
      TrimKey: Boolean = False; TrimValue: Boolean = False;
      SkipEmptyKey: Boolean = False; SkipEmptyValue: Boolean = False;
      Sync: Boolean = True; ReadWriteSync: Boolean = False): IMap; virtual;
    procedure InitLock;
    procedure InitReadWriteLock;
    procedure Lock;
    procedure Unlock;
    procedure BeginRead;
    procedure EndRead;
    function BeginWrite: Boolean;
    procedure EndWrite;
    procedure PutAll(const AList: IList); overload; virtual; abstract;
    procedure PutAll(const AMap: IMap); overload; virtual; abstract;
    procedure PutAll(const Container: Variant); overload; virtual; abstract;
    function ToList(ListClass: TListClass; Sync: Boolean = True;
      ReadWriteSync: Boolean = False): IList; virtual; abstract;
    property Count: Integer read GetCount;
    property Key[const Value: Variant]: Variant read GetKey;
    property Value[const Key: Variant]: Variant read Get write Put; default;
    property Keys: IList read GetKeys;
    property Values: IList read GetValues;
  end;

  TMapClass = class of TAbstractMap;
  { function ContainsValue is an O(n) operation in THashMap,
    and property Key is also an O(n) operation. They perform
    a linear search. THashedMap is faster than THashMap when
    do those operations. But THashMap needs less memory than
    THashedMap. }

  IHashMap = interface(IMap)
  ['{B66C3C4F-3FBB-41FF-B0FA-5E73D87CBE56}']
  end;

  THashMap = class(TAbstractMap, IHashMap)
  private
    FKeys: IList;
    FValues: IList;
  protected
    function GetCount: Integer; override;
    function GetKeys: IList; override;
    function GetValues: IList; override;
    function GetKey(const Value: Variant): Variant; override;
    function Get(const Key: Variant): Variant; override;
    procedure Put(const Key, Value: Variant); override;
    procedure InitData(Keys, Values: IList);
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); overload; override;
    constructor Create(Sync: Boolean;
      ReadWriteSync: Boolean = False); overload; override;
{$IFDEF BCB}
    constructor Create0; virtual;
    constructor Create1(Capacity: Integer); virtual;
    constructor Create2(Capacity: Integer; Factor: Single); virtual;
    constructor Create3(Capacity: Integer; Factor: Single; Sync: Boolean); virtual;
    constructor CreateS(Sync: Boolean); virtual;
{$ENDIF}
    procedure Clear; override;
    function ContainsKey(const Key: Variant): Boolean; override;
    function ContainsValue(const Value: Variant): Boolean; override;
    function Delete(const Key: Variant): Variant; override;
    procedure PutAll(const AList: IList); overload; override;
    procedure PutAll(const AMap: IMap); overload; override;
    procedure PutAll(const Container: Variant); overload; override;
    function ToList(ListClass: TListClass; Sync: Boolean = True;
      ReadWriteSync: Boolean = False): IList; override;
    function ToArrayList(Sync: Boolean = True;
      ReadWriteSync: Boolean = False): TArrayList; virtual;
    property Key[const Value: Variant]: Variant read GetKey;
    property Value[const Key: Variant]: Variant read Get write Put; default;
    property Count: Integer read GetCount;
    property Keys: IList read GetKeys;
    property Values: IList read GetValues;
  end;

  { function ContainsValue is an O(1) operation in THashedMap,
    and property Key is also an O(1) operation. }

  IHashedMap = interface(IHashMap)
  ['{D2598919-07DA-401A-A971-7DB8624E2660}']
  end;

  THashedMap = class(THashMap, IHashedMap)
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); override;
  end;

  ICaseInsensitiveHashMap = interface(IHashMap)
  ['{B8F8E5E7-53ED-48BE-B171-2EA2548FCAC7}']
  end;

  TCaseInsensitiveHashMap = class(THashMap, ICaseInsensitiveHashMap)
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); override;
  end;

  ICaseInsensitiveHashedMap = interface(IHashMap)
  ['{839DCE08-95DE-462F-B59D-16BA89D3DC6B}']
  end;

  TCaseInsensitiveHashedMap = class(THashMap, ICaseInsensitiveHashedMap)
  public
    constructor Create(Capacity: Integer = 16; Factor: Single = 0.75;
      Sync: Boolean = True; ReadWriteSync: Boolean = False); override;
  end;

{$IF NOT DEFINED(DELPHI2009_UP) AND NOT DEFINED(FPC)}
  TBytesStream = class(TMemoryStream)
  private
    FBytes: TBytes;
  protected
    function Realloc(var NewCapacity: Longint): Pointer; override;
  public
    constructor Create(const ABytes: TBytes); overload;
    property Bytes: TBytes read FBytes;
  end;
{$IFEND}

  TChars = array of Char;

  TStringBuffer = class(TObject)
  private
    FData: TChars;
    FPosition: Integer;
    FCapacity: Integer;
    FLength: Integer;
    procedure Grow;
    procedure SetPosition(NewPosition: Integer);
    procedure SetCapacity(NewCapacity: Integer);
  public
    constructor Create(Capacity: Integer = 255); overload;
    constructor Create(const AString: string); overload;
    function ReadString(Count: Longint): string;
    procedure WriteString(const AString: string);
    procedure InsertString(const AString: string);
    function Seek(Offset: Longint; Origin: Word): Longint;
    function ToString: string; {$IFDEF DELPHI2009_UP}override;{$ENDIF}{$IFDEF FPC}override;{$ENDIF}
    property Position: Integer read FPosition write SetPosition;
    property Length: Integer read FLength;
    property Capacity: Integer read FCapacity write SetCapacity;
  end;

  ISmartObject = interface
  ['{496CD091-9C33-423A-BC4A-61AF16C74A75}']
    function Value: TObject;
  end;

  TSmartObject = class(TInterfacedObject, ISmartObject)
  protected
    FObject: TObject;
    constructor Create(const AClass: TClass); overload;
  public
    constructor Create(AObject: TObject); overload; virtual;
    class function New(const AClass: TClass): ISmartObject;
    function Value: TObject;
    destructor Destroy; override;
  end;

  TSmartClass = class of TSmartObject;

{$IFDEF Supports_Generics}
  ISmartObject<T> = interface
  ['{91FEB85D-1284-4516-A9DA-5D370A338DA0}']
    function _: T;
  end;

{$M+}
  TSmartObject<T> = class(TSmartObject, ISmartObject<T>)
  protected
    constructor Create0;
  public
    constructor Create(AObject: TObject); override;
    class function New: ISmartObject<T>;
    function _: T;
  end;
{$M-}
{$ENDIF}

{$IFDEF DELPHI2009}
  TArray<T> = array of T;
{$ENDIF}

const

{$IFDEF CPU64}
  varNativeInt = varInt64;
{$ELSE}
  varNativeInt = varInteger;
{$ENDIF}

var
  varObject: TVarType;

{$IFNDEF DELPHI2009_UP}
function GetTypeName(const Info: PTypeInfo): string;
{$ENDIF}
function GetTypeSize(const Info: PTypeInfo): Integer;
{$IFDEF DELPHI6}
function FindVarData(const Value: Variant): PVarData;
function VarIsType(const V: Variant; AVarType: TVarType): Boolean; overload;
function VarIsType(const V: Variant; const AVarTypes: array of TVarType):
  Boolean; overload;
function VarIsCustom(const V: Variant): Boolean;
function VarIsOrdinal(const V: Variant): Boolean;
function VarIsFloat(const V: Variant): Boolean;
function VarIsNumeric(const V: Variant): Boolean;
function VarIsStr(const V: Variant): Boolean;
function VarIsEmpty(const V: Variant): Boolean;
function VarIsNull(const V: Variant): Boolean;
{$ENDIF}
function VarIsObj(const Value: Variant): Boolean; overload;
function VarIsObj(const Value: Variant; AClass: TClass): Boolean; overload;
function VarToObj(const Value: Variant): TObject; overload;
function VarToObj(const Value: Variant; AClass: TClass):
  TObject; overload;
function VarToObj(const Value: Variant; AClass: TClass; out AObject):
  Boolean; overload;
function ObjToVar(const Value: TObject): Variant;
function VarEquals(const Left, Right: Variant): Boolean;
function VarIsList(const Value: Variant): Boolean;
function VarIsMap(const Value: Variant): Boolean;
function VarToList(const Value: Variant): IList;
function VarToMap(const Value: Variant): IMap;
function VarIsIntf(const Value: Variant): Boolean; overload;
function VarIsIntf(const Value: Variant; const IID: TGUID): Boolean; overload;
function VarToIntf(const Value: Variant; const IID: TGUID; out AIntf): Boolean;
function IntfToObj(const Intf: IInterface): TInterfacedObject;

function GetPropValue(Instance: TObject; PropInfo: PPropInfo): Variant;
procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo;
  const Value: Variant);

function CopyVarRec(const Item: TVarRec): TVarRec;
function CreateConstArray(const Elements: array of const): TConstArray;
procedure FinalizeVarRec(var Item: TVarRec);
procedure FinalizeConstArray(var Arr: TConstArray);

procedure RegisterClass(const AClass: TClass; const Alias: string); overload;
procedure RegisterClass(const AClass: TInterfacedClass; const IID: TGUID; const Alias: string); overload;
function GetClassByAlias(const Alias: string): TClass;
function GetClassAlias(const AClass: TClass): string;
function GetClassByInterface(const IID: TGUID): TInterfacedClass;
function HasRegisterWithInterface(const AClass: TInterfacedClass): Boolean;
function GetInterfaceByClass(const AClass: TInterfacedClass): TGUID;

type
  THproseClassManager = class
{$IFDEF Supports_Generics}
  private
    class procedure RegisterSmartObject<T, I>(const Alias: string);
    class procedure Register(const TypeInfo: PTypeInfo; TypeName: string); overload;
  public
    class procedure Register(const TypeInfo: PTypeInfo); overload;
    class procedure Register<T>; overload;
    class procedure Register<T: class>(const Alias: string); overload;
    class procedure Register<T: TInterfacedObject; I: IInterface>(const Alias: string); overload;
    class function GetAlias<T: class>: string; overload;
    class function GetInterface<T: TInterfacedObject>: TGUID; overload;
    class function GetClass<I>: TInterfacedClass; overload;
    class function TypeInfo(const Name: string): PTypeInfo; overload;
{$ENDIF}
    class procedure Register(const AClass: TClass; const Alias: string); overload;
    class procedure Register(const AClass: TInterfacedClass; const IID: TGUID; const Alias: string); overload;
    class function GetAlias(const AClass: TClass): string; overload;
    class function GetClass(const Alias: string): TClass; overload;
    class function GetClass(const IID: TGUID): TInterfacedClass; overload;
    class function GetInterface(const AClass: TInterfacedClass): TGUID; overload;
  end;

function ListSplit(ListClass: TListClass; Str: string;
  const Separator: string = ','; Limit: Integer = 0; TrimItem: Boolean = False;
  SkipEmptyItem: Boolean = False): IList;
function MapSplit(MapClass: TMapClass; Str: string;
  const ItemSeparator: string = ';'; const KeyValueSeparator: string = '=';
  Limit: Integer = 0; TrimKey: Boolean = False; TrimValue: Boolean = False;
  SkipEmptyKey: Boolean = False; SkipEmptyValue: Boolean = False): IMap;

{$IFNDEF DELPHI2009_UP}
  // TBytes/string conversion routines
function BytesOf(const Val: RawByteString): TBytes; overload;
function BytesOf(const Val: WideChar): TBytes; overload;
function BytesOf(const Val: AnsiChar): TBytes; overload;
function BytesOf(const Val: WideString): TBytes; overload;
function StringOf(const Bytes: TBytes): RawByteString;
function WideStringOf(const Value: TBytes): WideString;
function WideBytesOf(const Value: WideString): TBytes;
{$ENDIF}

{$IFNDEF DELPHIXE3_UP}
function BytesOf(const Val: Pointer; const Len: integer): TBytes; overload;
{$ENDIF}

implementation

{$IFDEF NEXTGEN}
{$ZEROBASEDSTRINGS OFF}
{$ENDIF}

uses RTLConsts
{$IFNDEF FPC}, StrUtils{$ENDIF}
{$IFDEF DELPHIXE4_UP}{$IFNDEF NEXTGEN}, AnsiStrings{$ENDIF}{$ENDIF}
{$IFDEF Supports_Rtti}, Rtti{$ENDIF}{$IFDEF DELPHIXE2_UP}, ObjAuto{$ENDIF}
{$IFNDEF FPC}, ObjAutoX{$ENDIF};

type

  TVarObjectType = class(TInvokeableVariantType, IVarInstanceReference)
  protected
{$IFDEF FPC}
    procedure DispInvoke(Dest: PVarData; const Source: TVarData;
      CallDesc: PCallDesc; Params: Pointer); override;
{$ENDIF}
    { IVarInstanceReference }
    function GetInstance(const V: TVarData): TObject;
  public
    { IVarInvokeable }
    function DoFunction(var Dest: TVarData; const V: TVarData;
      const Name: string; const Arguments: TVarDataArray): Boolean; override;
    function GetProperty(var Dest: TVarData; const V: TVarData;
      const Name: string): Boolean; override;
    function SetProperty(const V: TVarData; const Name: string;
      const Value: TVarData): Boolean; override;

    procedure CastTo(var Dest: TVarData; const Source: TVarData;
      const AVarType: TVarType); override;
    procedure Clear(var V: TVarData); override;
    function CompareOp(const Left, Right: TVarData;
      const Operation: TVarOp): Boolean; override;
    procedure Copy(var Dest: TVarData; const Source: TVarData;
      const Indirect: Boolean); override;
    function IsClear(const V: TVarData): Boolean; override;
  end;

var
  VarObjectType: TVarObjectType;

{$IFDEF DELPHIXE2_UP}
const
{ Maximum TList size }
  MaxListSize = Maxint div 16;
{$ENDIF}

{$IFNDEF DELPHI2009_UP}
function GetTypeName(const Info: PTypeInfo): string;
begin
  Result := string(Info^.Name);
end;
{$ENDIF}

function GetTypeSize(const Info: PTypeInfo): Integer;
{$IFNDEF Supports_Rtti}
var
  TypeData: PTypeData;
begin
  Result := 4;
  TypeData := GetTypeData(Info);
  case Info^.Kind of
    tkInteger:
      case TypeData^.OrdType of
        otSByte,
        otUByte:
            Result := SizeOf(Byte);
        otSWord,
        otUWord:
          begin
            Result := SizeOf(Word);
          end;
        otSLong,
        otULong:
          ;
      end;
    tkFloat:
      case TypeData.FloatType of
        ftSingle:
          Result := SizeOf(Single);
        ftDouble:
          Result := SizeOf(Double);
        ftComp:
          Result := SizeOf(Comp);
        ftCurr:
          Result := SizeOf(Currency);
        ftExtended:
          Result := SizeOf(Extended);
      end;
    tkChar:
      Result := 1;
    tkWChar:
      Result := 2;
    tkInt64:
      Result := SizeOf(Int64);
    tkVariant:
      Result := SizeOf(TVarData);
    tkEnumeration:
      Result := 1;
  end;
end;
{$ELSE}
var
  Context: TRttiContext;
  Typ: TRttiType;
begin
  if (Info = TypeInfo(Variant)) or (Info = TypeInfo(OleVariant)) then
    Exit(SizeOf(TVarData));
  Result := SizeOf(Pointer);
  Typ := Context.GetType(Info);
  if Assigned(Typ) then Result := Typ.TypeSize;
end;
{$ENDIF}

{$IFDEF DELPHI6}
function FindVarData(const Value: Variant): PVarData;
begin
  Result := @TVarData(Value);
  while Result.VType = varByRef or varVariant do
    Result := PVarData(Result.VPointer);
end;

function VarIsType(const V: Variant; AVarType: TVarType): Boolean;
begin
  Result := FindVarData(V)^.VType = AVarType;
end;

function VarIsType(const V: Variant; const AVarTypes: array of TVarType): Boolean;
var
  I: Integer;
  P: PVarData;
begin
  Result := False;
  P := FindVarData(V);
  for I := Low(AVarTypes) to High(AVarTypes) do
    if P^.VType = AVarTypes[I] then
    begin
      Result := True;
      Break;
    end;
end;

function VarTypeIsCustom(const AVarType: TVarType): Boolean;
var
  LHandler: TCustomVariantType;
begin
  Result := FindCustomVariantType(AVarType, LHandler);
end;

function VarIsCustom(const V: Variant): Boolean;
begin
  Result := VarTypeIsCustom(FindVarData(V)^.VType);
end;

function VarTypeIsOrdinal(const AVarType: TVarType): Boolean;
begin
  Result := AVarType in [varSmallInt, varInteger, varBoolean, varShortInt,
                         varByte, varWord, varLongWord, varInt64];
end;

function VarIsOrdinal(const V: Variant): Boolean;
begin
  Result := VarTypeIsOrdinal(FindVarData(V)^.VType);
end;

function VarTypeIsFloat(const AVarType: TVarType): Boolean;
begin
  Result := AVarType in [varSingle, varDouble, varCurrency];
end;

function VarIsFloat(const V: Variant): Boolean;
begin
  Result := VarTypeIsFloat(FindVarData(V)^.VType);
end;

function VarTypeIsNumeric(const AVarType: TVarType): Boolean;
begin
  Result := VarTypeIsOrdinal(AVarType) or VarTypeIsFloat(AVarType);
end;

function VarIsNumeric(const V: Variant): Boolean;
begin
  Result := VarTypeIsNumeric(FindVarData(V)^.VType);
end;

function VarTypeIsStr(const AVarType: TVarType): Boolean;
begin
  Result := (AVarType = varOleStr) or (AVarType = varString);
end;

function VarIsStr(const V: Variant): Boolean;
begin
  Result := VarTypeIsStr(FindVarData(V)^.VType);
end;

function VarIsEmpty(const V: Variant): Boolean;
begin
  Result := FindVarData(V)^.VType = varEmpty;
end;

function VarIsNull(const V: Variant): Boolean;
begin
  Result := FindVarData(V)^.VType = varNull;
end;
{$ENDIF}

function VarToObj(const Value: Variant): TObject;
var
  P: PVarData;
begin
  Result := nil;
  try
    P := FindVarData(Value);
    if P^.VType = varObject then begin
      Result := TObject(P^.VPointer);
    end
    else if P^.VType <> varNull then Error(reInvalidCast);
  except
    Error(reInvalidCast);
  end;
end;

function VarToObj(const Value: Variant; AClass: TClass): TObject;
var
  P: PVarData;
begin
  Result := nil;
  try
    P := FindVarData(Value);
    if P^.VType = varObject then begin
      Result := TObject(P^.VPointer);
      if not (Result is AClass) then Error(reInvalidCast);
    end
    else if P^.VType <> varNull then Error(reInvalidCast);
  except
    Error(reInvalidCast);
  end;
end;

function VarToObj(const Value: Variant; AClass: TClass; out AObject):
  Boolean;
var
  Obj: TObject absolute AObject;
  P: PVarData;
begin
  Obj := nil;
  Result := True;
  try
    P := FindVarData(Value);
    if P^.VType = varObject then begin
      Obj := TObject(P^.VPointer) as AClass;
      Result := (Obj <> nil) or (P^.VPointer = nil);
    end
    else if P^.VType <> varNull then
      Result := False;
  except
    Result := False;
  end;
end;

function ObjToVar(const Value: TObject): Variant;
begin
  VarClear(Result);
  TObject(TVarData(Result).VPointer) := Value;
  TVarData(Result).VType := varObject;
end;

function VarEquals(const Left, Right: Variant): Boolean;
var
  L, R: PVarData;
  LA, RA: PVarArray;
begin
  Result := False;
  L := FindVarData(Left);
  R := FindVarData(Right);
  if VarIsArray(Left) and VarIsArray(Right) then begin
    if (L^.VType and varByRef) <> 0 then
      LA := PVarArray(L^.VPointer^)
    else
      LA := L^.VArray;
    if (R^.VType and varByRef) <> 0 then
      RA := PVarArray(R^.VPointer^)
    else
      RA := R^.VArray;
    if LA = RA then Result := True;
  end
  else begin
    if (L^.VType = varUnknown) and
       (R^.VType = varUnknown) then
      Result := L^.VUnknown = R^.VUnknown
    else if (L^.VType = varUnknown or varByRef) and
            (R^.VType = varUnknown) then
      Result := Pointer(L^.VPointer^) = R^.VUnknown
    else if (L^.VType = varUnknown) and
            (R^.VType = varUnknown or varByRef) then
      Result := L^.VUnknown = Pointer(R^.VPointer^)
    else if (L^.VType = varUnknown or varByRef) and
            (R^.VType = varUnknown or varByRef) then
      Result := Pointer(L^.VPointer^) = Pointer(R^.VPointer^)
    else
      try
        Result := Left = Right;
      except
        Result := False;
      end;
  end;
end;

function VarIsObj(const Value: Variant): Boolean;
begin
  Result := VarIsObj(Value, TObject);
end;

function VarIsObj(const Value: Variant; AClass: TClass): Boolean;
var
  P: PVarData;
begin
  Result := True;
  try
    P := FindVarData(Value);
    if P^.VType = varObject then
      Result := TObject(P^.VPointer) is AClass
    else if P^.VType <> varNull then
      Result := False;
  except
    Result := False;
  end;
end;

function VarIsList(const Value: Variant): Boolean;
begin
  Result := (FindVarData(Value)^.VType = varUnknown) and
            Supports(IInterface(Value), IList) or
            VarIsObj(Value, TAbstractList);
end;

function VarToList(const Value: Variant): IList;
begin
  if FindVarData(Value)^.VType = varUnknown then
    Supports(IInterface(Value), IList, Result)
  else if VarIsObj(Value, TAbstractList) then
    VarToObj(Value, TAbstractList, Result)
  else
    Error(reInvalidCast);
end;

function VarIsMap(const Value: Variant): Boolean;
begin
  Result := (FindVarData(Value)^.VType = varUnknown) and
            Supports(IInterface(Value), IMap) or
            VarIsObj(Value, TAbstractMap);
end;

function VarToMap(const Value: Variant): IMap;
begin
  if FindVarData(Value)^.VType = varUnknown then
    Supports(IInterface(Value), IMap, Result)
  else if VarIsObj(Value, TAbstractMap) then
    VarToObj(Value, TAbstractMap, Result)
  else
    Error(reInvalidCast);
end;

function VarIsIntf(const Value: Variant): Boolean;
begin
  Result := (FindVarData(Value)^.VType = varUnknown);
end;

function VarIsIntf(const Value: Variant; const IID: TGUID): Boolean;
begin
  Result := (FindVarData(Value)^.VType = varUnknown) and
            Supports(IInterface(Value), IID);
end;

function VarToIntf(const Value: Variant; const IID: TGUID; out AIntf): Boolean;
begin
  if FindVarData(Value)^.VType = varUnknown then
    Result := Supports(IInterface(Value), IID, AIntf)
  else
    Result := false;
end;

{$IFNDEF DELPHI2010_UP}
type
  TObjectFromInterfaceStub = packed record
    Stub: cardinal;
    case integer of
    0: (ShortJmp: ShortInt);
    1: (LongJmp: LongInt)
  end;
  PObjectFromInterfaceStub = ^TObjectFromInterfaceStub;
{$ENDIF}

function IntfToObj(const Intf: IInterface): TInterfacedObject; {$IFDEF DELPHI2010_UP}inline;{$ENDIF}
begin
  if Intf = nil then
    result := nil
  else begin
{$IFDEF DELPHI2010_UP}
    result := Intf as TInterfacedObject; // slower but always working
{$ELSE}
    with PObjectFromInterfaceStub(PPointer(PPointer(Intf)^)^)^ do
    case Stub of
      $04244483: result := Pointer(NativeInt(Intf) + ShortJmp);
      $04244481: result := Pointer(NativeInt(Intf) + LongJmp);
      else       result := nil;
    end;
{$ENDIF}
  end;
end;

{ GetPropValue/SetPropValue }

procedure PropertyNotFound(const Name: string);
begin
  raise EPropertyError.CreateResFmt(@SUnknownProperty, [Name]);
end;

procedure PropertyConvertError(const Name: string);
begin
  raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyType, [Name]);
end;

{$IFNDEF FPC}
{$IFNDEF DELPHI2007_UP}
type
  TAccessStyle = (asFieldData, asAccessor, asIndexedAccessor);

function GetAccessToProperty(Instance: TObject; PropInfo: PPropInfo;
  AccessorProc: Longint; out FieldData: Pointer;
  out Accessor: TMethod): TAccessStyle;
begin
  if (AccessorProc and $FF000000) = $FF000000 then
  begin  // field - Getter is the field's offset in the instance data
    FieldData := Pointer(Integer(Instance) + (AccessorProc and $00FFFFFF));
    Result := asFieldData;
  end
  else
  begin
    if (AccessorProc and $FF000000) = $FE000000 then
      // virtual method  - Getter is a signed 2 byte integer VMT offset
      Accessor.Code := Pointer(PInteger(PInteger(Instance)^ + SmallInt(AccessorProc))^)
    else
      // static method - Getter is the actual address
      Accessor.Code := Pointer(AccessorProc);

    Accessor.Data := Instance;
    if PropInfo^.Index = Integer($80000000) then  // no index
      Result := asAccessor
    else
      Result := asIndexedAccessor;
  end;
end;

function GetDynArrayProp(Instance: TObject; PropInfo: PPropInfo): Pointer;
type
  { Need a(ny) dynamic array type to force correct call setup.
    (Address of result passed in EDX) }
  TDynamicArray = array of Byte;
type
  TDynArrayGetProc = function: TDynamicArray of object;
  TDynArrayIndexedGetProc = function (Index: Integer): TDynamicArray of object;
var
  M: TMethod;
begin
  case GetAccessToProperty(Instance, PropInfo, Longint(PropInfo^.GetProc),
    Result, M) of
    asFieldData:
      Result := PPointer(Result)^;
    asAccessor:
      Result := Pointer(TDynArrayGetProc(M)());
    asIndexedAccessor:
      Result := Pointer(TDynArrayIndexedGetProc(M)(PropInfo^.Index));
  end;
end;

procedure SetDynArrayProp(Instance: TObject; PropInfo: PPropInfo;
  const Value: Pointer);
type
  TDynArraySetProc = procedure (const Value: Pointer) of object;
  TDynArrayIndexedSetProc = procedure (Index: Integer;
                                       const Value: Pointer) of object;
var
  P: Pointer;
  M: TMethod;
begin
  case GetAccessToProperty(Instance, PropInfo, Longint(PropInfo^.SetProc),
    P, M) of
    asFieldData:
      asm
        MOV    ECX, PropInfo
        MOV    ECX, [ECX].TPropInfo.PropType
        MOV    ECX, [ECX]

        MOV    EAX, [P]
        MOV    EDX, Value
        CALL   System.@DynArrayAsg
      end;
    asAccessor:
      TDynArraySetProc(M)(Value);
    asIndexedAccessor:
      TDynArrayIndexedSetProc(M)(PropInfo^.Index, Value);
  end;
end;
{$ENDIF}
{$ELSE}
function GetDynArrayProp(Instance: TObject; PropInfo: PPropInfo): Pointer;
type
  { Need a(ny) dynamic array type to force correct call setup.
    (Address of result passed in EDX) }
  TDynamicArray = array of Byte;
type
  TDynArrayGetProc = function: TDynamicArray of object;
  TDynArrayIndexedGetProc = function (Index: Integer): TDynamicArray of object;
var
  AMethod: TMethod;
begin
  case (PropInfo^.PropProcs) and 3 of
    ptfield:
      Result := PPointer(Pointer(Instance) + PtrUInt(PropInfo^.GetProc))^;
    ptstatic,
    ptvirtual:
    begin
      if (PropInfo^.PropProcs and 3) = ptStatic then
        AMethod.Code := PropInfo^.GetProc
      else
        AMethod.Code := PPointer(Pointer(Instance.ClassType) + PtrUInt(PropInfo^.GetProc))^;
      AMethod.Data := Instance;
      if ((PropInfo^.PropProcs shr 6) and 1) <> 0 then
        Result := TDynArrayIndexedGetProc(AMethod)(PropInfo^.Index)
      else
        Result := TDynArrayGetProc(AMethod)();
    end;
  end;
end;

procedure SetDynArrayProp(Instance: TObject; PropInfo: PPropInfo;
  const Value: Pointer);
type
  TDynArraySetProc = procedure (const Value: Pointer) of object;
  TDynArrayIndexedSetProc = procedure (Index: Integer;
                                       const Value: Pointer) of object;
var
  AMethod: TMethod;
begin
  case (PropInfo^.PropProcs shr 2) and 3 of
    ptfield:
      PPointer(Pointer(Instance) + PtrUInt(PropInfo^.SetProc))^ := Value;
    ptstatic,
    ptvirtual:
    begin
      if ((PropInfo^.PropProcs shr 2) and 3) = ptStatic then
        AMethod.Code := PropInfo^.SetProc
      else
        AMethod.Code := PPointer(Pointer(Instance.ClassType) + PtrUInt(PropInfo^.SetProc))^;
      AMethod.Data := Instance;
      if ((PropInfo^.PropProcs shr 6) and 1) <> 0 then
        TDynArrayIndexedSetProc(AMethod)(PropInfo^.Index, Value)
      else
        TDynArraySetProc(AMethod)(Value);
    end;
  end;
end;
{$ENDIF}

function GetPropValue(Instance: TObject; PropInfo: PPropInfo): Variant;
var
  PropType: PTypeInfo;
  DynArray: Pointer;
begin
  // assume failure
  Result := Null;
  PropType := PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF};
  case PropType^.Kind of
    tkInteger:
      Result := GetOrdProp(Instance, PropInfo);
    tkWChar:
{$IFNDEF NEXTGEN}
      Result := WideString(WideChar(GetOrdProp(Instance, PropInfo)));
{$ELSE}
      Result := string(WideChar(GetOrdProp(Instance, PropInfo)));
{$ENDIF}
    tkEnumeration:
      if GetTypeData(PropType)^.BaseType{$IFNDEF FPC}^{$ENDIF} = TypeInfo(Boolean) then
        Result := Boolean(GetOrdProp(Instance, PropInfo))
      else
        Result := GetOrdProp(Instance, PropInfo);
    tkSet:
      Result := GetOrdProp(Instance, PropInfo);
    tkFloat:
      if ((GetTypeName(PropType) = 'TDateTime') or
          (GetTypeName(PropType) = 'TDate') or
          (GetTypeName(PropType) = 'TTime')) then
        Result := VarAsType(GetFloatProp(Instance, PropInfo), varDate)
      else
        Result := GetFloatProp(Instance, PropInfo);
{$IFNDEF NEXTGEN}
    tkString, {$IFDEF FPC}tkAString, {$ENDIF}tkLString:
      Result := GetStrProp(Instance, PropInfo);
    tkChar:
      Result := Char(GetOrdProp(Instance, PropInfo));
    tkWString:
      Result := GetWideStrProp(Instance, PropInfo);
{$IFDEF Supports_Unicode}
    tkUString:
      Result := GetUnicodeStrProp(Instance, PropInfo);
{$ENDIF}
{$ELSE}
    tkUString:
      Result := GetStrProp(Instance, PropInfo);
{$ENDIF}
    tkVariant:
      Result := GetVariantProp(Instance, PropInfo);
    tkInt64:
{$IFDEF DELPHI2009_UP}
    if (GetTypeName(PropType) = 'UInt64') then
      Result := UInt64(GetInt64Prop(Instance, PropInfo))
    else
{$ENDIF}
      Result := GetInt64Prop(Instance, PropInfo);
{$IFDEF FPC}
    tkBool:
      Result := Boolean(GetOrdProp(Instance, PropInfo));
    tkQWord:
      Result := QWord(GetInt64Prop(Instance, PropInfo));
{$ENDIF}
    tkInterface:
      Result := GetInterfaceProp(Instance, PropInfo);
    tkDynArray:
      begin
        DynArray := GetDynArrayProp(Instance, PropInfo);
        DynArrayToVariant(Result, DynArray, PropType);
      end;
    tkClass:
      Result := ObjToVar(GetObjectProp(Instance, PropInfo));
  else
    PropertyConvertError(GetTypeName(PropType));
  end;
end;

procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo;
  const Value: Variant);
var
  PropType: PTypeInfo;
  TypeData: PTypeData;
  Obj: TObject;
  DynArray: Pointer;
begin
  PropType := PropInfo^.PropType{$IFNDEF FPC}^{$ENDIF};
  TypeData := GetTypeData(PropType);
  // set the right type
  case PropType^.Kind of
    tkInteger, {$IFNDEF NEXTGEN}tkChar, {$ENDIF}tkWChar, tkEnumeration, tkSet:
      SetOrdProp(Instance, PropInfo, Value);
{$IFDEF FPC}
    tkBool:
      SetOrdProp(Instance, PropInfo, Value);
    tkQWord:
      SetInt64Prop(Instance, PropInfo, QWord(Value));
{$ENDIF}
    tkFloat:
      SetFloatProp(Instance, PropInfo, Value);
{$IFNDEF NEXTGEN}
    tkString, {$IFDEF FPC}tkAString, {$ENDIF}tkLString:
      SetStrProp(Instance, PropInfo, VarToStr(Value));
    tkWString:
      SetWideStrProp(Instance, PropInfo, VarToWideStr(Value));
{$IFDEF Supports_Unicode}
    tkUString:
      SetUnicodeStrProp(Instance, PropInfo, VarToStr(Value)); //SB: ??
{$ENDIF}
{$ELSE}
    tkUString:
      SetStrProp(Instance, PropInfo, VarToStr(Value)); //SB: ??
{$ENDIF}
{$IFDEF DELPHI2009_UP}
    tkInt64:
      SetInt64Prop(Instance, PropInfo, Value);
{$ELSE}
    tkInt64:
      SetInt64Prop(Instance, PropInfo, TVarData(VarAsType(Value, varInt64)).VInt64);
{$ENDIF}
    tkVariant:
      SetVariantProp(Instance, PropInfo, Value);
    tkInterface:
        SetInterfaceProp(Instance, PropInfo, Value);
    tkDynArray:
      begin
        DynArray := nil; // "nil array"
        if VarIsNull(Value) or (VarArrayHighBound(Value, 1) >= 0) then begin
          DynArrayFromVariant(DynArray, Value, PropType);
        end;
        SetDynArrayProp(Instance, PropInfo, DynArray);
{$IFNDEF FPC}
        DynArrayClear(DynArray, PropType);
{$ENDIF}
      end;
    tkClass:
      if VarIsNull(Value) then
        SetOrdProp(Instance, PropInfo, 0)
      else if VarIsObj(Value) then begin
        Obj := VarToObj(Value);
        if (Obj.ClassType.InheritsFrom(TypeData^.ClassType)) then
          SetObjectProp(Instance, PropInfo, Obj)
        else
          PropertyConvertError(GetTypeName(PropType));
      end
      else
        PropertyConvertError(GetTypeName(PropType));
  else
    PropertyConvertError(GetTypeName(PropType));
  end;
end;

const
  htNull    = $00000000;
  htBoolean = $10000000;
  htInteger = $20000000;
  htInt64   = $30000000;
  htDouble  = $40000000;
  htOleStr  = $50000000;
  htDate    = $60000000;
  htObject  = $70000000;
  htArray   = $80000000;

{$IFDEF NEXTGEN}
function HashOfString(const Value: string): Integer;
{$ELSE}
function HashOfString(const Value: WideString): Integer;
{$ENDIF}
var
  I, N: Integer;
begin
  N := Length(Value);
  Result := 0;
  for I := 1 to N do
    Result := ((Result shl 2) or (Result shr 30)) xor Ord(Value[I]);
  Result := htOleStr or (Result and $0FFFFFFF);
end;

function GetHashType(VType: Word): Integer;
begin
  case VType of
    varEmpty:    Result := htNull;
    varNull:     Result := htNull;
    varBoolean:  Result := htBoolean;
    varByte:     Result := htInteger;
    varWord:     Result := htInteger;
    varShortInt: Result := htInteger;
    varSmallint: Result := htInteger;
    varInteger:  Result := htInteger;
    varLongWord: Result := htInt64;
    varInt64:    Result := htInt64;
{$IFDEF DELPHI2009_UP}
    varUInt64:   Result := htInt64;
{$ENDIF}
    varSingle:   Result := htDouble;
    varDouble:   Result := htDouble;
    varCurrency: Result := htDouble;
    varOleStr:   Result := htOleStr;
    varDate:     Result := htDate;
    varUnknown:  Result := htObject;
    varVariant:  Result := htObject;
  else
    if VType = varObject then
      Result := htObject
    else
      Result := htNull;
  end;
end;

function HashOfVariant(const Value: Variant): Integer;
var
  P: PVarData;
begin
  P := FindVarData(Value);
  case P^.VType of
    varEmpty:    Result := 0;
    varNull:     Result := 1;
    varBoolean:  Result := htBoolean or Abs(Integer(P^.VBoolean));
    varByte:     Result := htInteger or P^.VByte;
    varWord:     Result := htInteger or P^.VWord;
    varShortInt: Result := htInteger or (P^.VShortInt and $FF);
    varSmallint: Result := htInteger or (P^.VSmallInt and $FFFF);
    varInteger:  Result := htInteger or (P^.VInteger and $0FFFFFFF);
    varLongWord: Result := htInt64 or (P^.VLongWord and $0FFFFFFF)
                           xor (not (P^.VLongWord shr 3) and $10000000);
    varInt64:    Result := htInt64 or (P^.VInt64 and $0FFFFFFF)
                           xor (not (P^.VInt64 shr 3) and $10000000);
{$IFDEF DELPHI2009_UP}
    varUInt64:   Result := htInt64 or (P^.VUInt64 and $0FFFFFFF)
                           xor (not (P^.VUInt64 shr 3) and $10000000);
{$ENDIF}
    varSingle:   Result := htDouble or (P^.VInteger and $0FFFFFFF);
    varDouble:   Result := htDouble or ((P^.VInteger xor (P^.VInt64 shr 32))
                           and $0FFFFFFF);
    varCurrency: Result := htDouble or ((P^.VInteger xor (P^.VInt64 shr 32))
                           and $0FFFFFFF);
    varDate:     Result := htDate or ((P^.VInteger xor (P^.VInt64 shr 32))
                           and $0FFFFFFF);
    varUnknown:  Result := htObject or (P^.VInteger and $0FFFFFFF);
    varVariant:  Result := htObject or (P^.VInteger and $0FFFFFFF);
  else
    if  P^.VType and varByRef <> 0 then
      case P^.VType and not varByRef of
        varBoolean:  Result := htBoolean
                               or Abs(Integer(PWordBool(P^.VPointer)^));
        varByte:     Result := htInteger or PByte(P^.VPointer)^;
        varWord:     Result := htInteger or PWord(P^.VPointer)^;
        varShortInt: Result := htInteger or (PShortInt(P^.VPointer)^ and $FF);
        varSmallInt: Result := htInteger or (PSmallInt(P^.VPointer)^ and $FFFF);
        varInteger:  Result := htInteger or (PInteger(P^.VPointer)^
                               and $0FFFFFFF);
        varLongWord: Result := htInt64 or (PLongWord(P^.VPointer)^ and $0FFFFFFF)
                               xor (not (PLongWord(P^.VPointer)^ shr 3)
                               and $10000000);
        varInt64:    Result := htInt64 or (PInt64(P^.VPointer)^ and $0FFFFFFF)
                               xor (not (PInt64(P^.VPointer)^ shr 3)
                               and $10000000);
{$IFDEF DELPHI2009_UP}
        varUInt64:   Result := htInt64 or (PUInt64(P^.VPointer)^ and $0FFFFFFF)
                               xor (not (PUInt64(P^.VPointer)^ shr 3)
                               and $10000000);
{$ENDIF}
        varSingle:   Result := htDouble or (PInteger(P^.VPointer)^
                               and $0FFFFFFF);
        varDouble:   Result := htDouble or ((PInteger(P^.VPointer)^
                               xor (PInt64(P^.VPointer)^ shr 32)) and $0FFFFFFF);
        varCurrency: Result := htDouble or ((PInteger(P^.VPointer)^
                               xor (PInt64(P^.VPointer)^ shr 32)) and $0FFFFFFF);
        varDate:     Result := htDate or ((PInteger(P^.VPointer)^
                               xor (PInt64(P^.VPointer)^ shr 32)) and $0FFFFFFF);
        varUnknown:  Result := htObject or (PInteger(P^.VPointer)^
                               and $0FFFFFFF);
      else
        if VarIsArray(Value) then
          Result := Integer(htArray) or GetHashType(P^.VType and varTypeMask)
                    or (PInteger(P^.VPointer)^ and $0FFFFFFF)
        else
          Result := 0;
      end
    else if VarIsArray(Value) then
      Result := Integer(htArray) or GetHashType(P^.VType and varTypeMask)
                or (P^.VInteger and $0FFFFFFF)
    else if P^.VType = varObject then
      Result := htObject or (P^.VInteger and $0FFFFFFF)
    else
      Result := (P^.VInteger xor (P^.VInt64 shr 32)) and $0FFFFFFF;
  end;
end;

// Copies a TVarRec and its contents. If the content is referenced
// the value will be copied to a new location and the reference
// updated.
function CopyVarRec(const Item: TVarRec): TVarRec;
var
  S: {$IFNDEF NEXTGEN}WideString{$ELSE}string{$ENDIF};
begin
  // Copy entire TVarRec first
  Result := Item;

  // Now handle special cases
  case Item.VType of
    vtExtended:
      begin
        New(Result.VExtended);
        Result.VExtended^ := Item.VExtended^;
      end;
{$IFNDEF NEXTGEN}
    vtString:
      begin
        New(Result.VString);
        Result.VString^ := Item.VString^;
      end;
    vtPChar:
      Result.VPChar := {$IFDEF DELPHIXE4_UP}AnsiStrings.{$ENDIF}StrNew(Item.VPChar);
    // a little trickier: casting to AnsiString will ensure
    // reference counting is done properly
    vtAnsiString:
      begin
        // nil out first, so no attempt to decrement
        // reference count
        Result.VAnsiString := nil;
        AnsiString(Result.VAnsiString) := AnsiString(Item.VAnsiString);
      end;
{$ENDIF}
    // there is no StrNew for PWideChar
    vtPWideChar:
      begin
        S := Item.VPWideChar;
        GetMem(Result.VPWideChar,
               (Length(S) + 1) * SizeOf(WideChar));
        Move(PWideChar(S)^, Result.VPWideChar^,
             (Length(S) + 1) * SizeOf(WideChar));
      end;
    vtCurrency:
      begin
        New(Result.VCurrency);
        Result.VCurrency^ := Item.VCurrency^;
      end;
    vtVariant:
      begin
        New(Result.VVariant);
        Result.VVariant^ := Item.VVariant^;
      end;
    // casting ensures proper reference counting
    vtInterface:
      begin
        Result.VInterface := nil;
        IInterface(Result.VInterface) := IInterface(Item.VInterface);
      end;
    // casting ensures a proper copy is created
    vtWideString:
      begin
        Result.VWideString := nil;
{$IFNDEF NEXTGEN}
        WideString(Result.VWideString) := WideString(Item.VWideString);
{$ELSE}
        string(Result.VWideString) := string(Item.VWideString);
{$ENDIF}
      end;
    vtInt64:
      begin
        New(Result.VInt64);
        Result.VInt64^ := Item.VInt64^;
      end;
{$IFDEF DELPHI2009_UP}
    vtUnicodeString:
      begin
        // nil out first, so no attempt to decrement
        // reference count
        Result.VUnicodeString := nil;
        UnicodeString(Result.VUnicodeString) := UnicodeString(Item.VUnicodeString);
      end;
{$ENDIF}
{$IFDEF FPC}
    vtQWord:
      begin
        New(Result.VQWord);
        Result.VQWord^ := Item.VQWord^;
      end;
{$ENDIF}
    // VPointer and VObject don't have proper copy semantics so it
    // is impossible to write generic code that copies the contents
  end;
end;

// Creates a TConstArray out of the values given. Uses CopyVarRec
// to make copies of the original elements.
function CreateConstArray(const Elements: array of const): TConstArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Elements));
  for I := Low(Elements) to High(Elements) do
    Result[I] := CopyVarRec(Elements[I]);
end;


// TVarRecs created by CopyVarRec must be finalized with this function.
// You should not use it on other TVarRecs.
// use this function on copied TVarRecs only!
procedure FinalizeVarRec(var Item: TVarRec);
begin
  case Item.VType of
    vtExtended: Dispose(Item.VExtended);
{$IFNDEF NEXTGEN}
    vtString: Dispose(Item.VString);
    vtPChar: {$IFDEF DELPHIXE4_UP}AnsiStrings.{$ENDIF}StrDispose(Item.VPChar);
    vtAnsiString: AnsiString(Item.VAnsiString) := '';
{$ENDIF}
    vtPWideChar: FreeMem(Item.VPWideChar);
    vtCurrency: Dispose(Item.VCurrency);
    vtVariant: Dispose(Item.VVariant);
    vtInterface: IInterface(Item.VInterface) := nil;
{$IFNDEF NEXTGEN}
    vtWideString: WideString(Item.VWideString) := '';
{$ELSE}
    vtWideString: string(Item.VWideString) := '';
{$ENDIF}
{$IFDEF Supports_Unicode}
    vtUnicodeString: UnicodeString(Item.VUnicodeString) := '';
{$ENDIF}
    vtInt64: Dispose(Item.VInt64);
{$IFDEF FPC}
    vtQWord: Dispose(Item.VQWord);
{$ENDIF}
  end;
  Item.VPointer := nil;
end;

// A TConstArray contains TVarRecs that must be finalized. This function
// does that for all items in the array.
procedure FinalizeConstArray(var Arr: TConstArray);
var
  I: Integer;
begin
  for I := Low(Arr) to High(Arr) do
    FinalizeVarRec(Arr[I]);
  Finalize(Arr);
  Arr := nil;
end;

type

  TListEnumerator = class(TInterfacedObject, IListEnumerator)
  private
    FList: TAbstractList;
    FIndex: Integer;
    function GetCurrent: Variant;
  public
    constructor Create(AList: TAbstractList);
    function MoveNext: Boolean;
    property Current: Variant read GetCurrent;
  end;

{ TListEnumerator }

constructor TListEnumerator.Create(AList: TAbstractList);
begin
  FList := AList;
  FIndex := -1;
end;

function TListEnumerator.GetCurrent: Variant;
begin
  Result := FList[FIndex];
end;

function TListEnumerator.MoveNext: Boolean;
begin
  if FIndex < FList.Count - 1 then begin
    Inc(FIndex);
    Result := True;
  end
  else
    Result := False;
end;

{ TAbstractList }

destructor TAbstractList.Destroy;
begin
  Clear;
  FreeAndNil(FLock);
  FreeAndNil(FReadWriteLock);
  inherited Destroy;
end;

procedure TAbstractList.InitLock;
begin
  if FLock = nil then
    FLock := TCriticalSection.Create;
end;

procedure TAbstractList.InitReadWriteLock;
begin
  if FReadWriteLock = nil then
    FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

procedure TAbstractList.Lock;
begin
  FLock.Acquire;
end;

procedure TAbstractList.Unlock;
begin
  FLock.Release;
end;

procedure TAbstractList.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

function TAbstractList.BeginWrite: Boolean;
begin
  Result := FReadWriteLock.BeginWrite;
end;

procedure TAbstractList.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TAbstractList.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

procedure TAbstractList.Assign(const Source: IList);
var
  I: Integer;
begin
  Clear;
  Capacity := Source.Capacity;
  for I := 0 to Source.Count - 1 do Add(Source[I]);
end;

function TAbstractList.GetEnumerator: IListEnumerator;
begin
  Result := TListEnumerator.Create(Self);
end;

function TAbstractList.Join(const Glue, LeftPad, RightPad: string): string;
var
  Buffer: TStringBuffer;
  E: IListEnumerator;
begin
  if Count = 0 then begin
    Result := LeftPad + RightPad;
    Exit;
  end;
  E := GetEnumerator;
  Buffer := TStringBuffer.Create(LeftPad);
  E.MoveNext;
  while True do begin
    Buffer.WriteString(VarToStr(E.Current));
    if not E.MoveNext then Break;
    Buffer.WriteString(Glue);
  end;
  Buffer.WriteString(RightPad);
  Result := Buffer.ToString;
  Buffer.Free;
end;

class function TAbstractList.Split(Str: string; const Separator: string;
  Limit: Integer; TrimItem: Boolean; SkipEmptyItem: Boolean; Sync: Boolean;
      ReadWriteSync: Boolean): IList;
var
  I, N, L: Integer;
  S: string;
begin
  if Str = '' then begin
    Result := nil;
    Exit;
  end;
  Result := Self.Create(Sync, ReadWriteSync);
  L := Length(Separator);
  N := 0;
  I := L;
  while (I > 0) and ((Limit = 0) or (N < Limit - 1)) do begin
    I := AnsiPos(Separator, Str);
    if I > 0 then begin
      S := Copy(Str, 1, I - 1);
      if TrimItem then S := Trim(S);
      if not SkipEmptyItem or (S <> '') then Result.Add(S);
      Str := Copy(Str, I + L, MaxInt);
      Inc(N);
    end
  end;
  if TrimItem then Str := Trim(Str);
  if not SkipEmptyItem or (Str <> '') then Result.Add(Str);
end;

{ TArrayList }

function TArrayList.Add(const Value: Variant): Integer;
begin
  Result := FCount;
  if FCount = FCapacity then Grow;
  FList[Result] := Value;
  Inc(FCount);
end;

procedure TArrayList.AddAll(const AList: IList);
var
  TotalCount, I: Integer;
begin
  TotalCount := FCount + AList.Count;
  if TotalCount > FCapacity then begin
    FCapacity := TotalCount;
    Grow;
  end;
  for I := 0 to AList.Count - 1 do Add(AList[I]);
end;

procedure TArrayList.AddAll(const Container: Variant);
var
  I: Integer;
begin
  if VarIsList(Container) then begin
    AddAll(VarToList(Container));
  end
  else if VarIsArray(Container) then begin
    for I := VarArrayLowBound(Container, 1) to
             VarArrayHighBound(Container, 1) do
      Add(Container[I]);
  end;
end;

procedure TArrayList.Clear;
begin
  SetLength(FList, 0);
  FCount := 0;
  FCapacity := 0;
end;

function TArrayList.Contains(const Value: Variant): Boolean;
begin
  Result := IndexOf(Value) > -1;
end;


constructor TArrayList.Create(Capacity: Integer; Sync, ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  FCapacity := Capacity;
  FCount := 0;
  SetLength(FList, FCapacity);
end;

constructor TArrayList.Create(Sync, ReadWriteSync: Boolean);
begin
  Create(4, Sync, ReadWriteSync);
end;

{$IFDEF BCB}
constructor TArrayList.Create0;
begin
  Create;
end;
constructor TArrayList.Create1(Capacity: Integer);
begin
  Create(Capacity);
end;
constructor TArrayList.Create2(Capacity: Integer; Sync: Boolean);
begin
  Create(Capacity, Sync);
end;

constructor TArrayList.CreateS(Sync: Boolean);
begin
  Create(Sync);
end;
{$ENDIF}

function TArrayList.Delete(Index: Integer): Variant;
begin
  if (Index >= 0) and (Index < FCount) then begin
    Result := FList[Index];
    Dec(FCount);

    VarClear(FList[Index]);

    if Index < FCount then begin
      System.Move(FList[Index + 1], FList[Index],
        (FCount - Index) * SizeOf(Variant));
      FillChar(FList[FCount], SizeOf(Variant), 0);
    end;
  end;
end;

procedure TArrayList.Exchange(Index1, Index2: Integer);
var
  Item: Variant;
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index1]);
  if (Index2 < 0) or (Index2 >= FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index2]);

  Item := FList[Index1];
  FList[Index1] := FList[Index2];
  FList[Index2] := Item;
end;

function TArrayList.Get(Index: Integer): Variant;
begin
  if (Index >= 0) and (Index < FCount) then
    Result := FList[Index]
  else
    Result := Unassigned;
end;

function TArrayList.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TArrayList.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TArrayList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TArrayList.IndexOf(const Value: Variant): Integer;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
    if VarEquals(FList[I], Value) then begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

procedure TArrayList.Insert(Index: Integer; const Value: Variant);
begin
  if (Index < 0) or (Index > FCount) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index]);
  if FCount = FCapacity then Grow;
  if Index < FCount then begin
    System.Move(FList[Index], FList[Index + 1],
      (FCount - Index) * SizeOf(Variant));
    FillChar(FList[Index], SizeOf(Variant), 0);
  end;
  FList[Index] := Value;
  Inc(FCount);
end;

procedure TArrayList.Move(CurIndex, NewIndex: Integer);
var
  Value: Variant;
begin
  if CurIndex <> NewIndex then begin
    if (NewIndex < 0) or (NewIndex >= FCount) then
      raise EArrayListError.CreateResFmt(@SListIndexError, [NewIndex]);
    Value := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Value);
  end;
end;

procedure TArrayList.Put(Index: Integer; const Value: Variant);
begin
  if (Index < 0) or (Index > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListIndexError, [Index]);

  if Index >= FCapacity then begin
    FCapacity := Index;
    Grow;
  end;
  if Index >= FCount then FCount := Index + 1;

  FList[Index] := Value;
end;

function TArrayList.Remove(const Value: Variant): Integer;
begin
  Result := IndexOf(Value);
  if Result >= 0 then Delete(Result);
end;

function TArrayList.ToArray: TVariants;
begin
  Result := Copy(FList, 0, FCount);
end;

function TArrayList.ToArray(VarType: TVarType): Variant;
var
  I: Integer;
begin
  Result := VarArrayCreate([0, FCount - 1], VarType);
  for I := 0 to FCount - 1 do Result[I] := FList[I];
end;

procedure TArrayList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListCapacityError, [NewCapacity]);
  if NewCapacity <> FCapacity then begin
    SetLength(FList, NewCapacity);
    FCapacity := NewCapacity;
  end;
end;

procedure TArrayList.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    raise EArrayListError.CreateResFmt(@SListCountError, [NewCount]);

  if NewCount > FCapacity then begin
    FCapacity := NewCount;
    Grow;
  end
  else if NewCount < FCount then
    for I := FCount - 1 downto NewCount do
      Delete(I);

  FCount := NewCount;
end;

{ THashBucket }

function THashBucket.Add(HashCode, Index: Integer): PHashItem;
var
  HashIndex: Integer;
begin
  if FCount * FFactor >= FCapacity then Grow;
  HashIndex := (HashCode and $7FFFFFFF) mod FCapacity;
  System.New(Result);
  Result.HashCode := HashCode;
  Result.Index := Index;
  Result.Next := FIndices[HashIndex];
  FIndices[HashIndex] := Result;
  Inc(FCount);
end;

procedure THashBucket.Clear;
var
  I: Integer;
  HashItem: PHashItem;
begin
  for I := 0 to FCapacity - 1 do begin
    while FIndices[I] <> nil do begin
      HashItem := FIndices[I].Next;
      Dispose(FIndices[I]);
      FIndices[I] := HashItem;
    end;
  end;
  FCount := 0;
end;

constructor THashBucket.Create(Capacity: Integer; Factor: Single);
begin
  FCount := 0;
  FFactor := Factor;
  FCapacity := Capacity;
  SetLength(FIndices, FCapacity);
end;

procedure THashBucket.Delete(HashCode, Index: Integer);
var
  HashIndex: Integer;
  HashItem, Prev: PHashItem;
begin
  HashIndex := (HashCode and $7FFFFFFF) mod FCapacity;
  HashItem := FIndices[HashIndex];
  Prev := nil;
  while HashItem <> nil do begin
    if HashItem.Index = Index then begin
      if Prev <> nil then
        Prev.Next := HashItem.Next
      else
        FIndices[HashIndex] := HashItem.Next;
      Dispose(HashItem);
      Dec(FCount);
      Exit;
    end;
    Prev := HashItem;
    HashItem := HashItem.Next;
  end;
end;

destructor THashBucket.Destroy;
begin
  Clear;
  inherited;
end;

procedure THashBucket.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function THashBucket.IndexOf(HashCode: Integer; const Value: Variant;
  CompareProc: TIndexCompareMethod): Integer;
var
  HashIndex: Integer;
  HashItem: PHashItem;
begin
  Result := -1;
  HashIndex := (HashCode and $7FFFFFFF) mod FCapacity;
  HashItem := FIndices[HashIndex];
  while HashItem <> nil do
    if (HashItem.HashCode = HashCode) and
       CompareProc(HashItem.Index, Value) then begin
      Result := HashItem.Index;
      Exit;
    end
    else
      HashItem := HashItem.Next;
end;

function THashBucket.Modify(OldHashCode, NewHashCode,
  Index: Integer): PHashItem;
var
  HashIndex: Integer;
  Prev: PHashItem;
begin
  if OldHashCode = NewHashCode then
    Result := nil
  else begin
     HashIndex := (OldHashCode and $7FFFFFFF) mod FCapacity;
    Result := FIndices[HashIndex];
    Prev := nil;
    while Result <> nil do begin
      if Result.Index = Index then begin
        if Prev <> nil then
          Prev.Next := Result.Next
       else
          FIndices[HashIndex] := Result.Next;
        Result.HashCode := NewHashCode;
        HashIndex := (NewHashCode and $7FFFFFFF) mod FCapacity;
        Result.Next := FIndices[HashIndex];
        FIndices[HashIndex] := Result;
        Exit;
      end;
      Prev := Result;
      Result := Result.Next;
    end;
  end;
end;

procedure THashBucket.SetCapacity(NewCapacity: Integer);
var
  HashIndex, I: Integer;
  NewIndices: THashItemDynArray;
  HashItem, NewHashItem: PHashItem;
begin
  if (NewCapacity < 0) or (NewCapacity > MaxListSize) then
    raise EHashBucketError.CreateResFmt(@SListCapacityError, [NewCapacity]);
  if FCapacity = NewCapacity then Exit;
  if NewCapacity = 0 then begin
    Clear;
    SetLength(FIndices, 0);
    FCapacity := 0;
  end
  else begin
    SetLength(NewIndices, NewCapacity);
    for I := 0 to FCapacity - 1 do begin
      HashItem := FIndices[I];
      while HashItem <> nil do begin
        NewHashItem := HashItem;
        HashItem := HashItem.Next;
        HashIndex := (NewHashItem.HashCode and $7FFFFFFF) mod NewCapacity;
        NewHashItem.Next := NewIndices[HashIndex];
        NewIndices[HashIndex] := NewHashItem;
      end;
    end;
    FIndices := NewIndices;
    FCapacity := NewCapacity;
  end;
end;

{ THashedList }

function THashedList.Add(const Value: Variant): Integer;
begin
  Result := inherited Add(Value);
  FHashBucket.Add(HashOf(Value), Result);
end;

procedure THashedList.Clear;
begin
  inherited;
  if FHashBucket <> nil then FHashBucket.Clear;
end;

constructor THashedList.Create(Capacity: Integer; Sync, ReadWriteSync: Boolean);
begin
  Create(Capacity, 0.75, Sync, ReadWriteSync);
end;

constructor THashedList.Create(Capacity: Integer; Factor: Single; Sync,
  ReadWriteSync: Boolean);
begin
  inherited Create(Capacity, Sync, ReadWriteSync);
  FHashBucket := THashBucket.Create(Capacity, Factor);
end;

{$IFDEF BCB}
constructor THashedList.Create3(Capacity: Integer; Factor: Single;
  Sync: Boolean);
begin
  Create(Capacity, Factor, Sync);
end;
{$ENDIF}

function THashedList.Delete(Index: Integer): Variant;
var
  OldHashCode, NewHashCode, I, OldCount: Integer;
begin
  OldCount := Count;
  Result := inherited Delete(Index);
  if (Index >= 0) and (Index < OldCount) then begin
    if Index < Count then begin
      OldHashCode := HashOf(Result);
      for I := Index to Count - 1 do begin
        NewHashCode := HashOf(FList[I]);
        FHashBucket.Modify(OldHashCode, NewHashCode, I);
        OldHashCode := NewHashCode;
      end;
    end;
    FHashBucket.Delete(HashOf(Result), Count);
  end;
end;

destructor THashedList.Destroy;
begin
  FreeAndNil(FHashBucket);
  inherited;
end;

procedure THashedList.Exchange(Index1, Index2: Integer);
var
  HashCode1, HashCode2: Integer;
begin
  HashCode1 := HashOf(Get(Index1));
  HashCode2 := HashOf(Get(Index2));
  if HashCode1 <> HashCode2 then begin
    FHashBucket.Modify(HashCode1, HashCode2, Index1);
    FHashBucket.Modify(HashCode2, HashCode1, Index2);
  end;

  inherited Exchange(Index1, Index2);
end;

function THashedList.HashOf(const Value: Variant): Integer;
begin
  if VarIsStr(Value) then
    Result := HashOfString(Value)
  else
    Result := HashOfVariant(Value);
end;

function THashedList.IndexCompare(Index: Integer;
  const Value: Variant): Boolean;
var
  Item: Variant;
begin
  Item := Get(Index);
  if VarIsStr(Item) and VarIsStr(Value) then
{$IFNDEF NEXTGEN}
    Result := WideCompareStr(Item, Value) = 0
{$ELSE}
    Result := CompareStr(Item, Value) = 0
{$ENDIF}
  else
    Result := VarEquals(Item, Value)
end;

function THashedList.IndexOf(const Value: Variant): Integer;
begin
  Result := FHashBucket.IndexOf(HashOf(Value), Value, IndexCompare);
end;

procedure THashedList.Insert(Index: Integer; const Value: Variant);
var
  NewHashCode, OldHashCode, I, LastIndex: Integer;
begin
  LastIndex := Count;
  inherited Insert(Index, Value);

  NewHashCode := HashOf(Value);

  if Index < LastIndex then begin
    for I := Index to LastIndex - 1 do begin
      OldHashCode := HashOf(Get(I + 1));
      FHashBucket.Modify(OldHashCode, NewHashCode, I);
      NewHashCode := OldHashCode;
    end;
  end;

  FHashBucket.Add(NewHashCode, LastIndex);
end;

procedure THashedList.Put(Index: Integer; const Value: Variant);
var
  OldHashCode, NewHashCode: Integer;
begin
  OldHashCode := HashOf(Get(Index));
  NewHashCode := HashOf(Value);

  inherited Put(Index, Value);

  if (OldHashCode <> NewHashCode) and
    (FHashBucket.Modify(OldHashCode, NewHashCode, Index) = nil) then
    FHashBucket.Add(NewHashCode, Index);
end;

{ TCaseInsensitiveHashedList }
{$IFDEF BCB}
constructor TCaseInsensitiveHashedList.Create4(Capacity: Integer;
  Factor: Single; Sync, ReadWriteSync: Boolean);
begin
  Create(Capacity, Factor, Sync, ReadWriteSync);
end;
{$ENDIF}

function TCaseInsensitiveHashedList.HashOf(const Value: Variant): Integer;
begin
  if VarIsStr(Value) then
{$IFNDEF NEXTGEN}
    Result := HashOfString(WideLowerCase(Value))
{$ELSE}
    Result := HashOfString(LowerCase(Value))
{$ENDIF}
  else
    Result := HashOfVariant(Value);
end;

function TCaseInsensitiveHashedList.IndexCompare(Index: Integer;
  const Value: Variant): Boolean;
var
  Item: Variant;
begin
  Item := Get(Index);
  if VarIsStr(Item) and VarIsStr(Value) then
{$IFNDEF NEXTGEN}
    Result := WideCompareText(Item, Value) = 0
{$ELSE}
    Result := CompareText(Item, Value) = 0
{$ENDIF}
  else
    Result := VarEquals(Item, Value)
end;

type

  TMapEnumerator = class(TInterfacedObject, IMapEnumerator)
  private
    FMap: TAbstractMap;
    FIndex: Integer;
    function GetCurrent: TMapEntry;
  public
    constructor Create(AMap: TAbstractMap);
    function MoveNext: Boolean;
    property Current: TMapEntry read GetCurrent;
  end;

{ TMapEnumerator }

constructor TMapEnumerator.Create(AMap: TAbstractMap);
begin
  FMap := AMap;
  FIndex := -1;
end;

function TMapEnumerator.GetCurrent: TMapEntry;
begin
  Result.Key := FMap.Keys[FIndex];
  Result.Value := FMap.Values[FIndex];
end;

function TMapEnumerator.MoveNext: Boolean;
begin
    if FIndex < FMap.Count - 1 then begin
    Inc(FIndex);
    Result := True;
  end
  else
    Result := False;
end;

{ TAbstractMap }

destructor TAbstractMap.Destroy;
begin
  FreeAndNil(FLock);
  FreeAndNil(FReadWriteLock);
  inherited Destroy;
end;

function TAbstractMap.GetEnumerator: IMapEnumerator;
begin
  Result := TMapEnumerator.Create(Self);
end;

procedure TAbstractMap.InitLock;
begin
  if FLock = nil then
    FLock := TCriticalSection.Create;
end;

procedure TAbstractMap.InitReadWriteLock;
begin
  if FReadWriteLock = nil then
    FReadWriteLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

procedure TAbstractMap.Lock;
begin
  FLock.Acquire;
end;

procedure TAbstractMap.Unlock;
begin
  FLock.Release;
end;

procedure TAbstractMap.BeginRead;
begin
  FReadWriteLock.BeginRead;
end;

function TAbstractMap.BeginWrite: Boolean;
begin
  Result := FReadWriteLock.BeginWrite;
end;

procedure TAbstractMap.EndRead;
begin
  FReadWriteLock.EndRead;
end;

procedure TAbstractMap.EndWrite;
begin
  FReadWriteLock.EndWrite;
end;

procedure TAbstractMap.Assign(const Source: IMap);
begin
  Keys.Assign(Source.Keys);
  Values.Assign(Source.Values);
end;

function TAbstractMap.Join(const ItemGlue, KeyValueGlue, LeftPad,
  RightPad: string): string;
var
  Buffer: TStringBuffer;
  E: IMapEnumerator;
  Entry: TMapEntry;
begin
  if Count = 0 then begin
    Result := LeftPad + RightPad;
    Exit;
  end;
  E := GetEnumerator;
  Buffer := TStringBuffer.Create(LeftPad);
  E.MoveNext;
  while True do begin
    Entry := E.Current;
    Buffer.WriteString(VarToStr(Entry.Key));
    Buffer.WriteString(KeyValueGlue);
    Buffer.WriteString(VarToStr(Entry.Value));
    if not E.MoveNext then Break;
    Buffer.WriteString(ItemGlue);
  end;
  Buffer.WriteString(RightPad);
  Result := Buffer.ToString;
  Buffer.Free;
end;

class function TAbstractMap.Split(Str: string; const ItemSeparator,
  KeyValueSeparator: string; Limit: Integer; TrimKey, TrimValue,
  SkipEmptyKey, SkipEmptyValue: Boolean; Sync, ReadWriteSync: Boolean): IMap;

var
  I, L, L2, N: Integer;

procedure SetKeyValue(const AMap: IMap; const S: string);
var
  J: Integer;
  Key, Value: string;
begin
  if (SkipEmptyKey or SkipEmptyValue) and (S = '') then Exit;
  J := AnsiPos(KeyValueSeparator, S);
  if J > 0 then begin
    Key := Copy(S, 1, J - 1);
    if TrimKey then Key := Trim(Key);
    Value := Copy(S, J + L2, MaxInt);
    if TrimValue then Value := Trim(Value);
    if SkipEmptyKey and (Key = '') then Exit;
    if SkipEmptyValue and (Value = '') then Exit;
    AMap[Key] := Value;
  end
  else if SkipEmptyValue then
    Exit
  else if TrimKey then begin
    Key := Trim(S);
    if SkipEmptyKey and (Key = '') then Exit;
    AMap[Key] := '';
  end
  else
    AMap[S] := '';
end;

begin
  if Str = '' then begin
    Result := nil;
    Exit;
  end;
  Result := Self.Create(Sync, ReadWriteSync);
  L := Length(ItemSeparator);
  L2 := Length(KeyValueSeparator);
  N := 0;
  I := L;
  while (I > 0) and ((Limit = 0) or (N < Limit - 1)) do begin
    I := AnsiPos(ItemSeparator, Str);
    if I > 0 then begin
      SetKeyValue(Result, Copy(Str, 1, I - 1));
      Str := Copy(Str, I + L, MaxInt);
      Inc(N);
    end
  end;
  SetKeyValue(Result, Str);
end;

{ THashMap }

procedure THashMap.Clear;
begin
  FKeys.Clear;
  FValues.Clear;
end;

function THashMap.ContainsKey(const Key: Variant): Boolean;
begin
  Result := FKeys.Contains(Key);
end;

function THashMap.ContainsValue(const Value: Variant): Boolean;
begin
  Result := FValues.Contains(Value);
end;

constructor THashMap.Create(Capacity: Integer; Factor: Single; Sync,
  ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  InitData(THashedList.Create(Capacity, Factor, False),
           TArrayList.Create(Capacity, False));
end;

constructor THashMap.Create(Sync, ReadWriteSync: Boolean);
begin
  Create(16, 0.75, Sync, ReadWriteSync);
end;

{$IFDEF BCB}
constructor THashMap.Create0;
begin
  Create;
end;

constructor THashMap.Create1(Capacity: Integer);
begin
  Create(Capacity);
end;

constructor THashMap.Create2(Capacity: Integer; Factor: Single);
begin
  Create(Capacity, Factor);
end;

constructor THashMap.Create3(Capacity: Integer; Factor: Single; Sync: Boolean);
begin
  Create(Capacity, Factor, Sync);
end;

constructor THashMap.CreateS(Sync: Boolean);
begin
  Create(Sync);
end;
{$ENDIF}

function THashMap.Delete(const Key: Variant): Variant;
begin
  Result := FValues.Delete(FKeys.Remove(Key));
end;

function THashMap.GetCount: Integer;
begin
  Result := FKeys.Count;
end;

function THashMap.Get(const Key: Variant): Variant;
begin
  Result := FValues[FKeys.IndexOf(Key)];
end;

function THashMap.GetKey(const Value: Variant): Variant;
begin
  Result := FKeys[FValues.IndexOf(Value)];
end;

procedure THashMap.InitData(Keys, Values: IList);
begin
  FKeys := Keys;
  FValues := Values;
end;

procedure THashMap.PutAll(const AMap: IMap);
var
  I: Integer;
  K, V: IList;
begin
  K := AMap.Keys;
  V := AMap.Values;
  for I := 0 to AMap.Count - 1 do
    Put(K[I], V[I]);
end;

procedure THashMap.PutAll(const Container: Variant);
var
  I: Integer;
begin
  if VarIsList(Container) then
    PutAll(VarToList(Container))
  else if VarIsMap(Container) then
    PutAll(VarToMap(Container))
  else if VarIsArray(Container) then begin
    for I := VarArrayLowBound(Container, 1) to
             VarArrayHighBound(Container, 1) do
      Put(I, Container[I]);
  end;
end;

procedure THashMap.PutAll(const AList: IList);
var
  I: Integer;
begin
  for I := 0 to AList.Count - 1 do
    Put(I, AList[I]);
end;

procedure THashMap.Put(const Key, Value: Variant);
var
  Index: Integer;
begin
  Index := FKeys.IndexOf(Key);
  if Index > -1 then
    FValues[Index] := Value
  else
    FValues[FKeys.Add(Key)] := Value;
end;

function THashMap.ToList(ListClass: TListClass; Sync,
  ReadWriteSync: Boolean): IList;
var
  I: Integer;
begin
  Result := ListClass.Create(Count, Sync, ReadWriteSync) as IList;
  for I := 0 to Count - 1 do
    if (VarIsOrdinal(FKeys[I])) and (FKeys[I] >= 0)
      and (FKeys[I] <= MaxListSize) then Result.Put(FKeys[I], FValues[I]);
end;

function THashMap.ToArrayList(Sync, ReadWriteSync: Boolean): TArrayList;
var
  I: Integer;
begin
  Result := TArrayList.Create(Count, Sync, ReadWriteSync);
  for I := 0 to Count - 1 do
    if (VarIsOrdinal(FKeys[I])) and (FKeys[I] >= 0)
      and (FKeys[I] <= MaxListSize) then Result.Put(FKeys[I], FValues[I]);
end;

function THashMap.GetKeys: IList;
begin
  Result := FKeys;
end;

function THashMap.GetValues: IList;
begin
  Result := FValues;
end;

{ THashedMap }

constructor THashedMap.Create(Capacity: Integer; Factor: Single;
      Sync, ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  InitData(THashedList.Create(Capacity, Factor, False),
           THashedList.Create(Capacity, Factor, False));
end;

{ TCaseInsensitiveHashMap }

constructor TCaseInsensitiveHashMap.Create(Capacity: Integer; Factor: Single;
      Sync, ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  InitData(TCaseInsensitiveHashedList.Create(Capacity, Factor, False),
           TArrayList.Create(Capacity, False));
end;

{ TCaseInsensitiveHashedMap }

constructor TCaseInsensitiveHashedMap.Create(Capacity: Integer; Factor: Single;
      Sync, ReadWriteSync: Boolean);
begin
  if Sync then InitLock;
  if ReadWriteSync then InitReadWriteLock;
  InitData(TCaseInsensitiveHashedList.Create(Capacity, Factor, False),
           THashedList.Create(Capacity, Factor, False));
end;

{$IFNDEF DELPHI2009_UP}

{ TBytes/string conversion routines }

function BytesOf(const Val: RawByteString): TBytes;
var
  Len: Integer;
begin
  Len := Length(Val);
  SetLength(Result, Len);
  Move(Val[1], Result[0], Len);
end;

function BytesOf(const Val: AnsiChar): TBytes;
begin
  SetLength(Result, 1);
  Result[0] := Byte(Val);
end;

function BytesOf(const Val: WideChar): TBytes;
begin
  Result := BytesOf(WideString(Val));
end;

function BytesOf(const Val: WideString): TBytes;
begin
  Result := BytesOf(RawByteString(Val));
end;

function StringOf(const Bytes: TBytes): RawByteString;
var
  Len: Integer;
begin
  if Assigned(Bytes) then begin
    Len := Length(Bytes);
    SetLength(Result, Len);
    Move(Bytes[0], Result[1], Len);
  end
  else
    Result := '';
end;

function WideStringOf(const Value: TBytes): WideString;
var
  Len: Integer;
begin
  if Assigned(Value) then begin
    Len := Length(Value);
    SetLength(Result, Len div 2);
    Move(Value[0], Result[1], Len);
  end
  else
    Result := '';
end;

function WideBytesOf(const Value: WideString): TBytes;
var
  Len: Integer;
begin
  Len := Length(Value) * 2;
  SetLength(Result, Len);
  Move(Value[1], Result[0], Len);
end;

{$ENDIF}

{$IFNDEF DELPHIXE3_UP}
function BytesOf(const Val: Pointer; const Len: integer): TBytes;
begin
  SetLength(Result, Len);
  Move(PByte(Val)^, Result[0], Len);
end;
{$ENDIF}

{$IF NOT DEFINED(DELPHI2009_UP) AND NOT DEFINED(FPC)}
const
  MemoryDelta = $2000; { Must be a power of 2 }

{ TBytesStream }

constructor TBytesStream.Create(const ABytes: TBytes);
begin
  inherited Create;
  FBytes := ABytes;
  SetPointer(FBytes, Length(FBytes));
  Capacity := Size;
end;

function TBytesStream.Realloc(var NewCapacity: Longint): Pointer;
begin
  if (NewCapacity > 0) and (NewCapacity <> Size) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Pointer(FBytes);
  if NewCapacity <> Capacity then
  begin
    SetLength(FBytes, NewCapacity);
    Result := Pointer(FBytes);
    if NewCapacity = 0 then
      Exit;
    if Result = nil then raise EStreamError.CreateRes(@SMemoryStreamError);
  end;
end;
{$IFEND}

{ TStringBuffer }

constructor TStringBuffer.Create(const AString: string);
begin
  FLength := System.Length(AString);
  FCapacity := FLength;
  FPosition := FLength;
  SetLength(FData, FLength);
  Move(PChar(AString)^, FData[0], FLength * SizeOf(Char));
end;

constructor TStringBuffer.Create(Capacity: Integer);
begin
  FLength := 0;
  FPosition := 0;
  FCapacity := Capacity;
  SetLength(FData, Capacity);
end;

procedure TStringBuffer.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

procedure TStringBuffer.InsertString(const AString: string);
var
  Count: Integer;
begin
  if FPosition = FLength then
    WriteString(AString)
  else begin
    Count := System.Length(AString);
    if (FLength + Count > FCapacity) then begin
      FCapacity := FLength + Count;
      Grow;
    end;
    Move(FData[FPosition], FData[FPosition + Count], (FLength - FPosition) * SizeOf(Char));
    Move(PChar(AString)^, FData[FPosition], Count * SizeOf(Char));
    Inc(FPosition, Count);
    Inc(FLength, Count);
  end;
end;


function TStringBuffer.ReadString(Count: Integer): string;
var
  Len: Integer;
begin
  Len := FLength - FPosition;
  if Len > Count then Len := Count;
  if Len > 0 then begin
    SetString(Result, PChar(@FData[FPosition]), Len);
    Inc(FPosition, Len);
  end;
end;

function TStringBuffer.Seek(Offset: Integer; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: FPosition := FPosition + Offset;
    soFromEnd: FPosition := FLength - Offset;
  end;
  if FPosition > FLength then
    FPosition := FLength
  else if FPosition < 0 then FPosition := 0;
  Result := FPosition;
end;

procedure TStringBuffer.SetCapacity(NewCapacity: Integer);
begin
  FCapacity := NewCapacity;
  if FLength > NewCapacity then FLength := NewCapacity;
  if FPosition > NewCapacity then FPosition := NewCapacity;
  SetLength(FData, NewCapacity);
end;

procedure TStringBuffer.SetPosition(NewPosition: Integer);
begin
  if NewPosition < 0 then FPosition := 0
  else if NewPosition > FLength then FPosition := FLength
  else FPosition := NewPosition;
end;

function TStringBuffer.ToString: string;
begin
  SetString(Result, PChar(FData), FLength);
end;

procedure TStringBuffer.WriteString(const AString: string);
var
  Count: Integer;
begin
  Count := System.Length(AString);
  if (FPosition + Count > FCapacity) then begin
    FCapacity := FPosition + Count;
    Grow;
  end;
  Move(PChar(AString)^, FData[FPosition], Count * SizeOf(Char));
  Inc(FPosition, Count);
  if FPosition > FLength then FLength := FPosition;
end;

{ TVarObjectType }
{$IFDEF FPC}

const
  VAR_PARAMNOTFOUND = HRESULT($80020004);

procedure TVarObjectType.DispInvoke(Dest: PVarData; const Source: TVarData;
  CallDesc: PCallDesc; Params: Pointer);
var
  method_name: ansistring;
  arg_count: byte;
  args: TVarDataArray;
  arg_idx: byte;
  arg_type: byte;
  arg_byref, has_result: boolean;
  arg_ptr: pointer;
  arg_data: PVarData;
  dummy_data: TVarData;
const
  argtype_mask = $7F;
  argref_mask = $80;
begin
  arg_count := CallDesc^.ArgCount;
  method_name := ansistring(pchar(@CallDesc^.ArgTypes[arg_count]));
  setLength(args, arg_count);
  if arg_count > 0 then
  begin
    arg_ptr := Params;
    for arg_idx := 0 to arg_count - 1 do
    begin
      arg_type := CallDesc^.ArgTypes[arg_idx] and argtype_mask;
      arg_byref := (CallDesc^.ArgTypes[arg_idx] and argref_mask) <> 0;
      arg_data := @args[arg_count - arg_idx - 1];
      case arg_type of
        varUStrArg: arg_data^.vType := varUString;
        varStrArg: arg_data^.vType := varString;
      else
        arg_data^.vType := arg_type
      end;
      if arg_byref then
      begin
        arg_data^.vType := arg_data^.vType or varByRef;
        arg_data^.vPointer := PPointer(arg_ptr)^;
        Inc(arg_ptr,sizeof(Pointer));
      end
      else
        case arg_type of
          varError:
            arg_data^.vError:=VAR_PARAMNOTFOUND;
          varVariant:
            begin
              arg_data^ := PVarData(PPointer(arg_ptr)^)^;
              Inc(arg_ptr,sizeof(Pointer));
            end;
          varDouble, varCurrency, varInt64, varQWord, varDate:
            begin
              arg_data^.vQWord := PQWord(arg_ptr)^; // 64bit on all platforms
              inc(arg_ptr,sizeof(qword))
            end
        else
          arg_data^.vAny := PPointer(arg_ptr)^; // 32 or 64bit
          inc(arg_ptr,sizeof(pointer))
        end;
    end;
  end;
  has_result := (Dest <> nil);
  if has_result then
    variant(Dest^) := Unassigned;
  case CallDesc^.CallType of

    1:     { DISPATCH_METHOD }
      if has_result then
      begin
        if arg_count = 0 then
        begin
          // no args -- try GetProperty first, then DoFunction
          if not (GetProperty(Dest^,Source,method_name) or
            DoFunction(Dest^,Source,method_name,args)) then
            RaiseDispError
        end
        else
          if not DoFunction(Dest^,Source,method_name,args) then
            RaiseDispError;
      end
      else
      begin
        // may be procedure?
        if not DoProcedure(Source,method_name,args) then
        // may be function?
        try
          variant(dummy_data) := Unassigned;
          if not DoFunction(dummy_data,Source,method_name,args) then
            RaiseDispError;
        finally
          VarDataClear(dummy_data)
        end;
      end;

    2:     { DISPATCH_PROPERTYGET -- currently never generated by compiler for Variant Dispatch }
      if has_result then
      begin
        // must be property...
        if not GetProperty(Dest^,Source,method_name) then
          // may be function?
          if not DoFunction(Dest^,Source,method_name,args) then
            RaiseDispError
      end
      else
        RaiseDispError;

    4:    { DISPATCH_PROPERTYPUT }
      if has_result or (arg_count<>1) or  // must be no result and a single arg
        (not SetProperty(Source,method_name,args[0])) then
        RaiseDispError;
  else
    RaiseDispError;
  end;
end;
{$ENDIF}

function TVarObjectType.GetInstance(const V: TVarData): TObject;
begin
  Result := nil;
  try
    if V.VType = varObject then begin
      Result := TObject(V.VPointer);
    end
    else if V.VType <> varNull then Error(reInvalidCast);
  except
    Error(reInvalidCast);
  end;
end;

function TVarObjectType.DoFunction(var Dest: TVarData; const V: TVarData;
  const Name: string; const Arguments: TVarDataArray): Boolean;
var
  Obj: TObject;
  Intf: IInvokeableVarObject;
begin
  Obj := GetInstance(V);
  Result := True;
  if AnsiSameText(Name, 'Free') and (Length(Arguments) = 0) then
    Obj.Free
  else if Supports(Obj, IInvokeableVarObject, Intf) then begin
    Variant(Dest) := Intf.Invoke(Name, Arguments);
{$IFNDEF FPC}
  end
  else begin
    Result := GetMethodInfo(Obj, Name) <> nil;
    if Result then Variant(Dest) := ObjectInvoke(Obj, Name, TVariants(Arguments));
{$ENDIF}
  end;
end;

function TVarObjectType.GetProperty(var Dest: TVarData;
  const V: TVarData; const Name: string): Boolean;
var
  Obj: TObject;
  Info: PPropInfo;
begin
  Obj := GetInstance(V);
  Info := GetPropInfo(PTypeInfo(Obj.ClassInfo), Name);
  Result := Info <> nil;
  if Result then Variant(Dest) := GetPropValue(Obj, Info);
end;

function TVarObjectType.SetProperty(const V: TVarData;
  const Name: string; const Value: TVarData): Boolean;
var
  Obj: TObject;
  Info: PPropInfo;
begin
  Obj := GetInstance(V);
  Info := GetPropInfo(PTypeInfo(Obj.ClassInfo), Name);
  Result := Info <> nil;
  if Result then SetPropValue(Obj, Info, Variant(Value));
end;

procedure TVarObjectType.CastTo(var Dest: TVarData; const Source: TVarData;
  const AVarType: TVarType);
begin
  if (AVarType = varNull) and IsClear(Source) then
    Variant(Dest) := Null
  else if AVarType = varInteger then
    Variant(Dest) := FindVarData(Variant(Source)).VInteger
  else if AVarType = varInt64 then
    Variant(Dest) := FindVarData(Variant(Source)).VInt64
  else if AVarType = varString then
    Variant(Dest) := string(TObject(FindVarData(Variant(Source)).VPointer).ClassName)
{$IFDEF DELPHI2009_UP}
  else if AVarType = varUString then
    Variant(Dest) := UnicodeString(TObject(FindVarData(Variant(Source)).VPointer).ClassName)
{$ENDIF}
  else if AVarType = varOleStr then
{$IFNDEF NEXTGEN}
    Variant(Dest) := WideString(TObject(FindVarData(Variant(Source)).VPointer).ClassName)
{$ELSE}
    Variant(Dest) := TObject(FindVarData(Variant(Source)).VPointer).ClassName
{$ENDIF}
  else
    RaiseCastError;
end;

procedure TVarObjectType.Clear(var V: TVarData);
begin
  V.VType := varEmpty;
  V.VPointer := nil;
end;

function TVarObjectType.CompareOp(const Left, Right: TVarData;
  const Operation: TVarOp): Boolean;
begin
  Result := False;
  if (Left.VType = varObject) and (Right.VType = varObject) then
    case Operation of
      opCmpEQ:
        Result := Left.VPointer = Right.VPointer;
      opCmpNE:
        Result := Left.VPointer <> Right.VPointer;
    else
      RaiseInvalidOp;
    end
{$IFDEF DELPHI6}
  else if (Left.VType = varObject or varByRef) and
          (Right.VType = varObject) then
    case Operation of
      opCmpEQ:
        Result := PPointer(Left.VPointer)^ = Right.VPointer;
      opCmpNE:
        Result := PPointer(Left.VPointer)^ <> Right.VPointer;
    else
      RaiseInvalidOp;
    end
  else if (Left.VType = varObject) and
          (Right.VType = varObject or varByRef) then
    case Operation of
      opCmpEQ:
        Result := Left.VPointer = PPointer(Right.VPointer)^;
      opCmpNE:
        Result := Left.VPointer <> PPointer(Right.VPointer)^;
    else
      RaiseInvalidOp;
    end
  else if (Left.VType = varObject or varByRef) and
          (Right.VType = varObject or varByRef) then
    case Operation of
      opCmpEQ:
        Result := PPointer(Left.VPointer)^ = PPointer(Right.VPointer)^;
      opCmpNE:
        Result := PPointer(Left.VPointer)^ <> PPointer(Right.VPointer)^;
    else
      RaiseInvalidOp;
    end
{$ENDIF}
  else
    case Operation of
      opCmpEQ:
        Result := False;
      opCmpNE:
        Result := True;
    else
      RaiseInvalidOp;
    end
end;

procedure TVarObjectType.Copy(var Dest: TVarData; const Source: TVarData;
  const Indirect: Boolean);
begin
  if Indirect and VarDataIsByRef(Source) then
    VarDataCopyNoInd(Dest, Source)
  else
    VarDataClear(Dest);
    Dest.VType := Source.VType;
    Dest.VPointer := Source.VPointer;
end;

function TVarObjectType.IsClear(const V: TVarData): Boolean;
begin
  Result := V.VPointer = nil;
end;

function ListSplit(ListClass: TListClass; Str: string;
  const Separator: string; Limit: Integer; TrimItem: Boolean;
  SkipEmptyItem: Boolean): IList;
begin
  Result := ListClass.Split(Str, Separator, Limit, TrimItem, SkipEmptyItem);
end;

function MapSplit(MapClass: TMapClass; Str: string;
  const ItemSeparator: string; const KeyValueSeparator: string;
  Limit: Integer; TrimKey: Boolean; TrimValue: Boolean;
  SkipEmptyKey: Boolean; SkipEmptyValue: Boolean): IMap;
begin
  Result := MapClass.Split(Str, ItemSeparator, KeyValueSeparator, Limit,
    TrimKey, TrimValue, SkipEmptyKey, SkipEmptyValue);
end;

var
  SmartObjectsRef: IMap;

{ TSmartObject }

constructor TSmartObject.Create(const AClass: TClass);
begin
  SmartObjectsRef.Lock;
  FObject := AClass.Create;
  SmartObjectsRef[NativeInt(Pointer(FObject))] := 1;
  SmartObjectsRef.UnLock;
end;

constructor TSmartObject.Create(AObject: TObject);
var
  V: NativeInt;
begin
  SmartObjectsRef.Lock;
  FObject := AObject;
  V := NativeInt(Pointer(FObject));
  if SmartObjectsRef.ContainsKey(V) then
    SmartObjectsRef[V] := SmartObjectsRef[V] + 1
  else
    SmartObjectsRef[V] := 1;
  SmartObjectsRef.UnLock;
end;

destructor TSmartObject.Destroy;
var
  V: NativeInt;
begin
  if SmartObjectsRef <> nil then begin
    SmartObjectsRef.Lock;
    V := NativeInt(Pointer(FObject));
    SmartObjectsRef[V] := SmartObjectsRef[V] - 1;
    if SmartObjectsRef[V] = 0 then begin
      SmartObjectsRef.Delete(V);
      FreeAndNil(FObject);
    end;
    SmartObjectsRef.UnLock;
  end
  else
    FreeAndNil(FObject);
  inherited;
end;

class function TSmartObject.New(const AClass: TClass): ISmartObject;
begin
  Result := TSmartObject.Create(AClass) as ISmartObject;
end;

function TSmartObject.Value: TObject;
begin
  Result := FObject;
end;

var
  HproseClassMap: IMap;
  HproseInterfaceMap: IMap;

procedure RegisterClass(const AClass: TClass; const Alias: string);
begin
  HproseClassMap.BeginWrite;
  try
    HproseClassMap[Alias] := NativeInt(AClass);
  finally
    HproseClassMap.EndWrite;
  end;
end;

procedure RegisterClass(const AClass: TInterfacedClass; const IID: TGUID; const Alias: string);
begin
  HproseInterfaceMap.BeginWrite;
  RegisterClass(AClass, Alias);
  try
    HproseInterfaceMap[Alias] := GuidToString(IID);
  finally
    HproseInterfaceMap.EndWrite;
  end;
end;

function GetClassByAlias(const Alias: string): TClass;
begin
  HproseClassMap.BeginRead;
  try
    Result := TClass(NativeInt(HproseClassMap[Alias]));
  finally
    HproseClassMap.EndRead;
  end;
end;

function GetClassAlias(const AClass: TClass): string;
begin
  HproseClassMap.BeginRead;
  try
    Result := HproseClassMap.Key[NativeInt(AClass)];
  finally
    HproseClassMap.EndRead;
  end;
end;

function GetClassByInterface(const IID: TGUID): TInterfacedClass;
begin
  HproseInterfaceMap.BeginRead;
  try
    Result := TInterfacedClass(GetClassByAlias(HproseInterfaceMap.Key[GuidToString(IID)]));
  finally
    HproseInterfaceMap.EndRead;
  end;
end;

function HasRegisterWithInterface(const AClass: TInterfacedClass): Boolean;
begin
  HproseInterfaceMap.BeginRead;
  try
    Result := HproseInterfaceMap.ContainsKey(GetClassAlias(AClass));
  finally
    HproseInterfaceMap.EndRead;
  end;
end;

function GetInterfaceByClass(const AClass: TInterfacedClass): TGUID;
begin
  HproseInterfaceMap.BeginRead;
  try
    Result := StringToGuid(HproseInterfaceMap[GetClassAlias(AClass)]);
  finally
    HproseInterfaceMap.EndRead;
  end;
end;

{$IFDEF Supports_Generics}

{ TSmartObject<T> }

constructor TSmartObject<T>.Create0();
var
  TI: PTypeInfo;
begin
  TI := TypeInfo(T);
  if TI^.Kind <> tkClass then
    raise EHproseException.Create(GetTypeName(TI) + 'is not a Class');
  inherited Create(GetTypeData(TI)^.ClassType)
end;

constructor TSmartObject<T>.Create(AObject: TObject);
var
  TI: PTypeInfo;
begin
  TI := TypeInfo(T);
  if TI^.Kind <> tkClass then
    raise EHproseException.Create(GetTypeName(TI) + 'is not a Class');
  if not AObject.ClassType.InheritsFrom(GetTypeData(TI)^.ClassType) then
    raise EHproseException.Create(AObject.ClassName + 'is not a ' + GetTypeName(TI));
  inherited Create(AObject);
end;

function TSmartObject<T>._: T;
begin
  Result := T(Pointer(@FObject)^);
end;

class function TSmartObject<T>.New: ISmartObject<T>;
begin
  Result := TSmartObject<T>.Create0 as ISmartObject<T>;
end;

var
  HproseTypeMap: IMap;

procedure RegisterType(const TypeName: string; const TypeInfo: PTypeInfo);
begin
  HproseTypeMap.BeginWrite;
  try
    HproseTypeMap[TypeName] := NativeInt(TypeInfo);
  finally
    HproseTypeMap.EndWrite;
  end;
end;

{ THproseClassManager }

class procedure THproseClassManager.Register(const TypeInfo: PTypeInfo; TypeName: string);
var
  UnitName: string;
  TypeData: PTypeData;
begin
  RegisterType(TypeName, TypeInfo);
  TypeData := GetTypeData(TypeInfo);
  case TypeInfo^.Kind of
  tkEnumeration:
{$IFDEF Supports_Rtti}
    TypeName := TRttiContext.Create.GetType(TypeInfo).QualifiedName;
{$ELSE}
    UnitName := string(TypeData^.EnumUnitName);
{$ENDIF}
{$IFNDEF DELPHIXE3_UP}
  tkClass:       UnitName := string(TypeData^.UnitName);
  tkInterface:   UnitName := string(TypeData^.IntfUnit);
  tkDynArray:    UnitName := string(TypeData^.DynUnitName);
{$ELSE}
  tkClass:       UnitName := TypeData^.UnitNameFld.ToString;
  tkInterface:   UnitName := TypeData^.IntfUnitFld.ToString;
  tkDynArray:    UnitName := TypeData^.DynUnitNameFld.ToString;
{$ENDIF}
  else
    raise EHproseException.Create('Can not register this type: ' + TypeName);
  end;
  if UnitName <> '' then TypeName := UnitName + '.' + TypeName;
  RegisterType(TypeName, TypeInfo);
end;

class procedure THproseClassManager.Register(const TypeInfo: PTypeInfo);
begin
  Register(TypeInfo, GetTypeName(TypeInfo));
end;

class procedure THproseClassManager.RegisterSmartObject<T, I>(const Alias: string);
var
  TTI, ITI: PTypeInfo;
begin
  TTI := System.TypeInfo(T);
  ITI := System.TypeInfo(I);
  RegisterClass(TInterfacedClass(GetTypeData(TTI)^.ClassType), GetTypeData(ITI)^.Guid, Alias);
{$IFDEF DELPHIXE3_UP}
  Register(TTI);
{$ELSE}
// Delphi 2010 - XE2 have a bug for GetTypeName from TTI, so I hack it like this
  Register(TTI, string('T' + RightStr(GetTypeName(ITI), Length(GetTypeName(ITI)) - 1)));
{$ENDIF}
  Register(ITI);
end;

class procedure THproseClassManager.Register<T>;
var
  TI: PTypeInfo;
  TypeName: string;
begin
  TI := System.TypeInfo(T);
  Register(TI);
  TypeName := GetTypeName(TI);
  if (TI^.Kind = tkClass) and
     not StrUtils.AnsiStartsText('TSmartObject<', TypeName) then
    Self.RegisterSmartObject<TSmartObject<T>, ISmartObject<T>>(TypeName);
end;

class procedure THproseClassManager.Register<T>(const Alias: string);
var
  TI: PTypeInfo;
begin
  TI := System.TypeInfo(T);
  if PTypeInfo(TI)^.Kind = tkClass then
    RegisterClass(GetTypeData(TI)^.ClassType, Alias);
  Self.Register<T>;
end;

class procedure THproseClassManager.Register<T, I>(const Alias: string);
var
  TTI, ITI: PTypeInfo;
begin
  TTI := System.TypeInfo(T);
  ITI := System.TypeInfo(I);
  if ITI^.Kind <> tkInterface then
    raise EHproseException.Create(GetTypeName(ITI) + ' must be a interface');
  RegisterClass(TInterfacedClass(GetTypeData(TTI)^.ClassType), GetTypeData(ITI)^.Guid, Alias);
  Self.Register<T>;
  Self.Register<I>;
end;

class function THproseClassManager.GetAlias<T>: string;
var
  TI: PTypeInfo;
begin
  Result := '';
  TI := System.TypeInfo(T);
  if PTypeInfo(TI)^.Kind = tkClass then Result := GetClassAlias(GetTypeData(TI)^.ClassType);
end;

class function THproseClassManager.GetInterface<T>: TGUID;
begin
  Result := GetInterfaceByClass(TInterfacedClass(GetTypeData(System.TypeInfo(T))^.ClassType));
end;

class function THproseClassManager.GetClass<I>: TInterfacedClass;
var
  ITI: PTypeInfo;
begin
  ITI := System.TypeInfo(I);
  if ITI^.Kind <> tkInterface then
    raise EHproseException.Create('I must be a interface');
  Result := GetClassByInterface(GetTypeData(ITI)^.Guid);
end;

class function THproseClassManager.TypeInfo(const Name: string): PTypeInfo;
begin
  HproseTypeMap.BeginRead;
  try
    Result := PTypeInfo(NativeInt(HproseTypeMap[Name]));
  finally
    HproseTypeMap.EndRead;
  end;
end;

{$ENDIF}

class function THproseClassManager.GetClass(const IID: TGUID): TInterfacedClass;
begin
  Result := GetClassByInterface(IID);
end;

class function THproseClassManager.GetClass(const Alias: string): TClass;
begin
  Result := GetClassByAlias(Alias);
end;

class function THproseClassManager.GetInterface(const AClass: TInterfacedClass): TGUID;
begin
  Result := GetInterfaceByClass(AClass);
end;

class function THproseClassManager.GetAlias(const AClass: TClass): string;
begin
  Result := GetClassAlias(AClass);
end;

class procedure THproseClassManager.Register(const AClass: TInterfacedClass;
  const IID: TGUID; const Alias: string);
begin
  RegisterClass(AClass, IID, Alias);
end;

class procedure THproseClassManager.Register(const AClass: TClass;
  const Alias: string);
begin
  RegisterClass(AClass, Alias);
end;


initialization
  HproseClassMap := TCaseInsensitiveHashedMap.Create(False, True);
  HproseInterfaceMap := TCaseInsensitiveHashedMap.Create(False, True);

{$IFDEF Supports_Generics}
  HproseTypeMap := TCaseInsensitiveHashMap.Create(64, 0.75, False, True);
  HproseTypeMap.BeginWrite;
  try
    HproseTypeMap['System.NativeInt'] := NativeInt(TypeInfo(NativeInt));
    HproseTypeMap['System.NativeUInt'] := NativeInt(TypeInfo(NativeUInt));
    HproseTypeMap['System.ShortInt'] := NativeInt(TypeInfo(ShortInt));
    HproseTypeMap['System.SmallInt'] := NativeInt(TypeInfo(SmallInt));
    HproseTypeMap['System.Integer'] := NativeInt(TypeInfo(Integer));
    HproseTypeMap['System.Int64'] := NativeInt(TypeInfo(Int64));
    HproseTypeMap['System.Byte'] := NativeInt(TypeInfo(Byte));
    HproseTypeMap['System.Word'] := NativeInt(TypeInfo(Word));
    HproseTypeMap['System.Cardinal'] := NativeInt(TypeInfo(Cardinal));
    HproseTypeMap['System.UInt64'] := NativeInt(TypeInfo(UInt64));
    HproseTypeMap['System.Char'] := NativeInt(TypeInfo(Char));
    HproseTypeMap['System.WideChar'] := NativeInt(TypeInfo(WideChar));
    HproseTypeMap['System.UCS4Char'] := NativeInt(TypeInfo(UCS4Char));
    HproseTypeMap['System.Boolean'] := NativeInt(TypeInfo(Boolean));
    HproseTypeMap['System.ByteBool'] := NativeInt(TypeInfo(ByteBool));
    HproseTypeMap['System.WordBool'] := NativeInt(TypeInfo(WordBool));
    HproseTypeMap['System.LongBool'] := NativeInt(TypeInfo(LongBool));
    HproseTypeMap['System.Single'] := NativeInt(TypeInfo(Single));
    HproseTypeMap['System.Double'] := NativeInt(TypeInfo(Double));
    HproseTypeMap['System.Real'] := NativeInt(TypeInfo(Real));
    HproseTypeMap['System.Extended'] := NativeInt(TypeInfo(Extended));
    HproseTypeMap['System.Comp'] := NativeInt(TypeInfo(Comp));
    HproseTypeMap['System.Currency'] := NativeInt(TypeInfo(Currency));
    HproseTypeMap['System.string'] := NativeInt(TypeInfo(string));
    HproseTypeMap['System.UnicodeString'] := NativeInt(TypeInfo(UnicodeString));
{$IFNDEF NEXTGEN}
    HproseTypeMap['System.AnsiChar'] := NativeInt(TypeInfo(AnsiChar));
    HproseTypeMap['System.AnsiString'] := NativeInt(TypeInfo(AnsiString));
    HproseTypeMap['System.RawByteString'] := NativeInt(TypeInfo(RawByteString));
    HproseTypeMap['System.ShortString'] := NativeInt(TypeInfo(ShortString));
    HproseTypeMap['System.UTF8String'] := NativeInt(TypeInfo(UTF8String));
    HproseTypeMap['System.WideString'] := NativeInt(TypeInfo(WideString));
{$ENDIF}
    HproseTypeMap['System.UCS4String'] := NativeInt(TypeInfo(UCS4String));
    HproseTypeMap['System.TDateTime'] := NativeInt(TypeInfo(TDateTime));
    HproseTypeMap['System.TDate'] := NativeInt(TypeInfo(TDate));
    HproseTypeMap['System.TTime'] := NativeInt(TypeInfo(TTime));
    HproseTypeMap['System.Variant'] := NativeInt(TypeInfo(Variant));
    HproseTypeMap['System.OleVariant'] := NativeInt(TypeInfo(OleVariant));
  finally
    HproseTypeMap.EndWrite;
  end;

  THproseClassManager.Register<ISmartObject>;
{$ENDIF}

{$IFDEF Supports_Generics}
  THproseClassManager.Register<TArrayList, IList>('!List');
  THproseClassManager.Register<TArrayList, IArrayList>('!ArrayList');
  THproseClassManager.Register<THashedList, IHashedList>('!HashedList');
  THproseClassManager.Register<TCaseInsensitiveHashedList, ICaseInsensitiveHashedList>('!CaseInsensitiveHashedList');
  THproseClassManager.Register<THashMap, IMap>('!Map');
  THproseClassManager.Register<THashMap, IHashMap>('!HashMap');
  THproseClassManager.Register<THashedMap, IHashedMap>('!HashedMap');
  THproseClassManager.Register<TCaseInsensitiveHashMap, ICaseInsensitiveHashMap>('!CaseInsensitiveHashMap');
  THproseClassManager.Register<TCaseInsensitiveHashedMap, ICaseInsensitiveHashedMap>('!CaseInsensitiveHashedMap');
{$ELSE}
  RegisterClass(TArrayList, IList, '!List');
  RegisterClass(TArrayList, IArrayList, '!ArrayList');
  RegisterClass(THashedList, IHashedList, '!HashedList');
  RegisterClass(TCaseInsensitiveHashedList, ICaseInsensitiveHashedList, '!CaseInsensitiveHashedList');
  RegisterClass(THashMap, IMap, '!Map');
  RegisterClass(THashMap, IHashMap, '!HashMap');
  RegisterClass(THashedMap, IHashedMap, '!HashedMap');
  RegisterClass(TCaseInsensitiveHashMap, ICaseInsensitiveHashMap, '!CaseInsensitiveHashMap');
  RegisterClass(TCaseInsensitiveHashedMap, ICaseInsensitiveHashedMap, '!CaseInsensitiveHashedMap');
{$ENDIF}

  VarObjectType := TVarObjectType.Create;
  varObject := VarObjectType.VarType;

  SmartObjectsRef := THashMap.Create;
finalization
  FreeAndNil(VarObjectType);

end.
