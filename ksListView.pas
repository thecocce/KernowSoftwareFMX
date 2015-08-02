{ *******************************************************************************
  *                                                                              *
  *  TksListView - Cached ListView Component                                     *
  *                                                                              *
  *  https://github.com/gmurt/KernowSoftwareFMX                                  *
  *                                                                              *
  *  Copyright 2015 Graham Murt                                                  *
  *                                                                              *
  *  email: graham@kernow-software.co.uk                                         *
  *                                                                              *
  *  Licensed under the Apache License, Version 2.0 (the "License");             *
  *  you may not use this file except in compliance with the License.            *
  *  You may obtain a copy of the License at                                     *
  *                                                                              *
  *    http://www.apache.org/licenses/LICENSE-2.0                                *
  *                                                                              *
  *  Unless required by applicable law or agreed to in writing, software         *
  *  distributed under the License is distributed on an "AS IS" BASIS,           *
  *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    *
  *  See the License for the specific language governing permissions and         *
  *  limitations under the License.                                              *
  *                                                                              *
  ******************************************************************************* }

unit ksListView;

interface

uses
  Classes, FMX.Types, FMX.Controls, FMX.ListView, Types, FMX.TextLayout,
  FMX.ListView.Types, FMX.Graphics, Generics.Collections, System.UITypes,
  FMX.ImgList, System.UIConsts, FMX.StdCtrls, FMX.Styles.Objects;

{$IFDEF _VER290}
  {$DEFINE XE8_OR_NEWER}
{$ENDIF}

const
  C_LONG_TAP_DURATION     = 5;  // 500 ms
  C_SEGMENT_BUTTON_HEIGHT = 29;

type
  TksListViewCheckMarks = (ksCmNone, ksCmSingleSelect, ksCmMultiSelect);
  TksListViewShape = (ksRectangle, ksRoundRect, ksEllipse);
  TksAccessoryType = (None, More, Checkmark, Detail);

  TksListView = class;
  TKsListItemRow = class;
  TksListItemRowObj = class;
  TksListItemRowSwitch = class;
  TksListItemRowSegmentButtons = class;
  TksControlBitmapCache = class;

  TksListViewRowClickEvent = procedure(Sender: TObject; x, y: single; AItem: TListViewItem; AId: string; ARowObj: TksListItemRowObj) of object;
  TksListViewClickSwitchEvent = procedure(Sender: TObject; AItem: TListViewItem; ASwitch: TksListItemRowSwitch; ARowID: string) of object;
  TksListViewClickSegmentButtonEvent = procedure(Sender: TObject; AItem: TListViewItem; AButtons: TksListItemRowSegmentButtons; ARowID: string) of object;
  TksListViewFinishScrollingEvent = procedure(Sender: TObject; ATopIndex, AVisibleItems: integer) of object;


  // ------------------------------------------------------------------------------

  TksVisibleItems = record
    Count: integer;
    IndexStart: integer;
    IndexEnd: integer;
  end;


  TksListItemRowObj = class
  private
    FId: string;
    FRect: TRectF;
    FPlaceOffset: TPointF;
    FRow: TKsListItemRow;
    FAlign: TListItemAlign;
    FVertAlignment: TListItemAlign;
    FTagBoolean: Boolean;
    FGuid: string;
    FControlImageCache: TksControlBitmapCache;

    procedure SetRect(const Value: TRectF);
    procedure SetID(const Value: string);
    procedure Changed;
    procedure SetAlign(const Value: TListItemAlign);
    procedure SetVertAlign(const Value: TListItemAlign);
  protected
    procedure CalculateRect(ARowBmp: TBitmap); virtual;
    procedure DoChanged(Sender: TObject);
  public
    constructor Create(ARow: TKsListItemRow); virtual;
    function Render(ACanvas: TCanvas): Boolean; virtual;
    procedure Click(x, y: single); virtual;
    property Rect: TRectF read FRect write SetRect;
    property ID: string read FId write SetID;
    property Align: TListItemAlign read FAlign write SetAlign default TListItemAlign.Leading;
    property VertAlign: TListItemAlign read FVertAlignment write SetVertAlign default TListItemAlign.Center;
    property PlaceOffset: TPointF read FPlaceOffset write FPlaceOffset;
    property TagBoolean: Boolean read FTagBoolean write FTagBoolean;
  end;




  TksListItemRowText = class(TksListItemRowObj)
  private
    FFont: TFont;
    FAlignment: TTextAlign;
    FTextLayout: TTextLayout;
    FTextColor: TAlphaColor;
    FText: string;
    FWordWrap: Boolean;
    procedure SetFont(const Value: TFont);
    procedure SetAlignment(const Value: TTextAlign);
    procedure SetTextColor(const Value: TAlphaColor);
    procedure SetText(const Value: string);
    procedure SetWordWrap(const Value: Boolean);
  public
    constructor Create(ARow: TKsListItemRow); override;
    destructor Destroy; override;
    function Render(ACanvas: TCanvas): Boolean; override;
    property Font: TFont read FFont write SetFont;
    property TextAlignment: TTextAlign read FAlignment write SetAlignment;
    property TextColor: TAlphaColor read FTextColor write SetTextColor;
    property Text: string read FText write SetText;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  end;

  // ------------------------------------------------------------------------------

  TksListItemRowImage = class(TksListItemRowObj)
  private
    FBitmap: TBitmap;
    procedure SetBitmap(const Value: TBitmap);
  public
    constructor Create(ARow: TKsListItemRow); override;
    destructor Destroy; override;
    function Render(ACanvas: TCanvas): Boolean; override;
    property Bitmap: TBitmap read FBitmap write SetBitmap;
  end;

  TksListItemRowShape = class(TksListItemRowObj)
  private
    FStroke: TBrush;
    FFill: TBrush;
    FShape: TksListViewShape;
    FCornerRadius: single;
    procedure SetCornerRadius(const Value: single);
    procedure SetShape(const Value: TksListViewShape);
  public
    constructor Create(ARow: TKsListItemRow); override;
    destructor Destroy; override;
    function Render(ACanvas: TCanvas): Boolean; override;
    property Stroke: TBrush read FStroke;
    property Fill: TBrush read FFill;
    property CornerRadius: single read FCornerRadius write SetCornerRadius;
    property Shape: TksListViewShape read FShape write SetShape;
  end;

  TKsListItemRowAccessory = class(TksListItemRowObj)
  private
    FResources: TListItemStyleResources;
    FAccessoryType: TAccessoryType;
    FImage: TStyleObject;
    procedure SetAccessoryType(const Value: TAccessoryType);
  public
    constructor Create(ARow: TKsListItemRow); override;
    function Render(ACanvas: TCanvas): Boolean; override;
    property AccessoryType: TAccessoryType read FAccessoryType write SetAccessoryType;
  end;

  TksListItemRowSwitch = class(TksListItemRowObj)
  private
    FIsChecked: Boolean;
    procedure SetIsChecked(const Value: Boolean);
  public
    function Render(ACanvas: TCanvas): Boolean; override;
    procedure Toggle;
    property IsChecked: Boolean read FIsChecked write SetIsChecked;

  end;

  TksListItemRowSegmentButtons = class(TksListItemRowObj)
  private
    FCaptions: TStrings;
    FItemIndex: integer;
    FButton: TSpeedButton;
    FTintColor: TAlphaColor;
    procedure SetItemIndex(const Value: integer);
    procedure SetTintColor(const Value: TAlphaColor);
  public
    constructor Create(ARow: TKsListItemRow); override;
    destructor Destroy; override;
    procedure Click(x, y: single); override;
    function Render(ACanvas: TCanvas): Boolean; override;
    property ItemIndex: integer read FItemIndex write SetItemIndex;
    property Captions: TStrings read FCaptions;
    property TintColor: TAlphaColor read FTintColor write SetTintColor;
  end;
                  
  // ------------------------------------------------------------------------------

  TKsSegmentButtonPosition = (ksSegmentLeft, ksSegmentMiddle, ksSegmentRight);

  TksControlBitmapCache = class
  private
    FOwner: TksListView;
    FSwitchOn: TBitmap;
    FSwitchOff: TBitmap;
    FCreatingCache: Boolean;
    FCachedButtons: TStringList;
    FImagesCached: Boolean;
    FButton: TSpeedButton;
    function GetSwitchImage(AChecked: Boolean): TBitmap;
    function GetSegmentButtonImage(APosition: TKsSegmentButtonPosition;
      AWidth, AHeight: single; AText: string; ATintColor: TAlphaColor;
      ASelected: Boolean): TBitmap;
  public
    constructor Create(Owner: TksListView);
    destructor Destroy; override;
    function CreateImageCache: Boolean;
    property SwitchImage[AChecked: Boolean]: TBitmap read GetSwitchImage;
    property SegmentButtonImage[APosition: TKsSegmentButtonPosition;
                                AWidth, AHeight: single;
                                AText: string;
                                ATintColor: TAlphaColor;
                                ASelected: Boolean]: TBitmap read GetSegmentButtonImage;
    property ImagesCached: Boolean read FImagesCached;
  end;

  TKsListItemRow = class(TListItemImage)
  private
    FCached: Boolean;
    FFont: TFont;
    FDetailFont: TFont;
    FText: string;
    FDetailText: string;
    FDetailColor: TAlphaColor;
    FTextColor: TAlphaColor;
    FIndicatorColor: TAlphaColor;
    FList: TObjectList<TksListItemRowObj>;
    FId: string;
    FAccessory: TKsListItemRowAccessory;
    FShowAccessory: Boolean;
    FAutoCheck: Boolean;
    FImage: TBitmap;
    FImageIndex: integer;
    FTextOffset: integer;
    function AddImage(AImage: TBitmap): TksListItemRowImage;
    function AddText(AText: string): TksListItemRowText;
    function AddDetail(AText: string): TksListItemRowText;
    function TextHeight(AText: string): single;
    function TextWidth(AText: string): single;
    function RowHeight(const AScale: Boolean = True): single;
    function RowWidth(const AScale: Boolean = True): single;
    function GetListView: TCustomListView;
    function GetRowObject(AIndex: integer): TksListItemRowObj;
    function GetRowObjectCount: integer;
    procedure SetAccessory(const Value: TAccessoryType);
    procedure SetShowAccessory(const Value: Boolean);
    function GetAccessory: TAccessoryType;
    procedure SetAutoCheck(const Value: Boolean);
    procedure SetChecked(const Value: Boolean);
    procedure SetImageIndex(const Value: integer);
    function GetSearchIndex: string;
    procedure SetSearchIndex(const Value: string);
    procedure SetDetailColor(const Value: TAlphaColor);
    procedure SetIndicatorColor(const Value: TAlphaColor);
    procedure SetTextOffset(const Value: integer);
    procedure SetImage(const Value: TBitmap);
    property ListView: TCustomListView read GetListView;
    procedure DoOnListChanged(Sender: TObject; const Item: TksListItemRowObj;
      Action: TCollectionNotification);
    function ScreenWidth: single;
    procedure ProcessClick;
    procedure DoFontChanged(Sender: TObject);
    procedure DoDetailFontChanged(Sender: TObject);
    procedure RecreateImage;
    procedure RecreateText;
    procedure RecreateDetail;
    procedure Changed;
  public
    constructor Create(const AOwner: TListItem);
    destructor Destroy; override;

    procedure CacheRow;
    // bitmap functions...
    function DrawBitmap(ABmp: TBitmap; x, AWidth, AHeight: single): TksListItemRowImage overload;
    function DrawBitmap(ABmpIndex: integer; x, AWidth, AHeight: single): TksListItemRowImage overload;
    function DrawBitmap(ABmp: TBitmap; x, y, AWidth, AHeight: single): TksListItemRowImage overload;
    function DrawBitmapRight(ABmp: TBitmap; AWidth, AHeight, ARightPadding: single): TksListItemRowImage;
    // shape functions...
    function DrawRect(x, y, AWidth, AHeight: single; AStroke, AFill: TAlphaColor): TksListItemRowShape;
    function DrawRoundRect(x, y, AWidth, AHeight, ACornerRadius: single; AStroke, AFill: TAlphaColor): TksListItemRowShape;
    function DrawEllipse(x, y, AWidth, AHeight: single; AStroke, AFill: TAlphaColor): TksListItemRowShape;
    // switch
    function AddSwitch(x: single; AIsChecked: Boolean; const AAlign: TListItemAlign = TListItemAlign.Leading): TksListItemRowSwitch;
    function AddSwitchRight(AMargin: integer; AIsChecked: Boolean): TksListItemRowSwitch;

    // segment buttons...
    function AddSegmentButtons(AWidth: integer; ACaptions: array of string; const ATintColor: TAlphaColor = claSilver): TksListItemRowSegmentButtons; overload;

    // text functions...

    function TextOut(AText: string; x: single; const AVertAlign: TTextAlign = TTextAlign.Center; const AWordWrap: Boolean = False): TksListItemRowText; overload;
    function TextOut(AText: string; x, AWidth: single; const AVertAlign: TTextAlign = TTextAlign.Center; const AWordWrap: Boolean = False): TksListItemRowText; overload;
    function TextOut(AText: string; x, y, AWidth: single; const AVertAlign: TTextAlign = TTextAlign.Center; const AWordWrap: Boolean = False): TksListItemRowText; overload;
    function TextOutRight(AText: string; y, AWidth: single; AXOffset: single; const AVertAlign: TTextAlign = TTextAlign.Center): TksListItemRowText; overload;

    // font functions...
    procedure SetFontProperties(AName: string; ASize: integer; AColor: TAlphaColor; AStyle: TFontStyles);

    // properties...
    property Font: TFont read FFont;
    property DetailFont: TFont read FDetailFont;
    property DetailColor: TAlphaColor read FDetailColor write SetDetailColor;
    property TextColor: TAlphaColor read FTextColor write FTextColor;
    property RowObject[AIndex: integer]: TksListItemRowObj read GetRowObject;
    property RowObjectCount: integer read GetRowObjectCount;
    property ID: string read FId write FId;
    property Cached: Boolean read FCached write FCached;
    property IndicatorColor: TAlphaColor read FIndicatorColor write SetIndicatorColor;
    property Accessory: TAccessoryType read GetAccessory write SetAccessory;
    property ShowAccessory: Boolean read FShowAccessory write SetShowAccessory default True;
    property AutoCheck: Boolean read FAutoCheck write SetAutoCheck default False;
    property Image: TBitmap read FImage write SetImage;
    property ImageIndex: integer read FImageIndex write SetImageIndex;
    property SearchIndex: string read GetSearchIndex write SetSearchIndex;
    property TextOffset: integer read FTextOffset write SetTextOffset;
  end;


  // ------------------------------------------------------------------------------

  TksListViewAppearence = class(TPersistent)
  private
    FListView: TksListView;
    FBackground: TAlphaColor;
    FItemBackground: TAlphaColor;
    FAlternatingItemBackground: TAlphaColor;
    procedure SetBackground(const Value: TAlphaColor);
    procedure SetItemBackground(const Value: TAlphaColor);
    procedure SetAlternatingItemBackground(const Value: TAlphaColor);
  public
    constructor Create(AListView: TksListView);
  published
    property Background: TAlphaColor read FBackground write SetBackground
      default claWhite;
    property ItemBackground: TAlphaColor read FItemBackground
      write SetItemBackground default claWhite;
    property AlternatingItemBackground: TAlphaColor
      read FAlternatingItemBackground write SetAlternatingItemBackground
      default claGainsboro;
  end;

  // ------------------------------------------------------------------------------

  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidiOSDevice)]
  TksListView = class(TCustomListView)
  private
    FScreenScale: single;
    FDefaultRowHeight: integer;
    FAppearence: TksListViewAppearence;
    FOnItemClickEx: TksListViewRowClickEvent;
    FOnItemRightClickEx: TksListViewRowClickEvent;
    FMouseDownPos: TPointF;
    FDetailFont: TFont;
    FCurrentMousepos: TPointF;
    FItemHeight: integer;
    FClickTimer: TTimer;
    FLastWidth: integer;
    FMouseDownDuration: integer;
    FOnLongClick: TksListViewRowClickEvent;
    FClickedRowObj: TksListItemRowObj;
    FClickedItem: TListViewItem;
    FSelectOnRightClick: Boolean;
    FOnSwitchClicked: TksListViewClickSwitchEvent;
    FOnSegmentButtonClicked: TksListViewClickSegmentButtonEvent;
    FCacheTimer: TTimer;
    FScrollTimer: TTimer;
    FLastScrollPos: integer;
    FScrolling: Boolean;
    FOnFinishScrolling: TksListViewFinishScrollingEvent;
    FControlBitmapCache: TksControlBitmapCache;
    FCheckMarks: TksListViewCheckMarks;
    FUpdateCount: integer;
    procedure SetItemHeight(const Value: integer);
    procedure DoClickTimer(Sender: TObject);
    function GetCachedRow(index: integer): TKsListItemRow;
    procedure OnCacheTimer(Sender: TObject);
    procedure DoScrollTimer(Sender: TObject);
    function CountUncachedRows: integer;
    procedure SetCheckMarks(const Value: TksListViewCheckMarks);
    function GetIsUpdating: Boolean;
    { Private declarations }
  protected
    procedure SetColorStyle(AName: string; AColor: TAlphaColor);
    procedure Resize; override;
    procedure ApplyStyle; override;
    procedure DoItemClick(const AItem: TListViewItem); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: single); override;
    procedure DoItemChange(const AItem: TListViewItem); override;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RedrawAllRows;
    function AddRow(AText, ADetail: string;
                    AAccessory: TksAccessoryType;
                    const AImageIndex: integer = -1;
                    const AFontSize: integer = 14;
                    AFontColor: TAlphaColor = claBlack): TKsListItemRow;
    function AddHeader(AText: string): TKsListItemRow;
    function ItemsInView: TksVisibleItems;
    procedure BeginUpdate; override;
    procedure EndUpdate; override;
    property CachedRow[index: integer]: TKsListItemRow read GetCachedRow;
    procedure UncheckAll;
    procedure CheckAll;
    { Public declarations }
  published
    property Appearence: TksListViewAppearence read FAppearence
      write FAppearence;
    property ItemHeight: integer read FItemHeight write SetItemHeight
      default 44;
    property OnEditModeChange;
    property OnEditModeChanging;
    property EditMode;

    property Transparent default False;
    property AllowSelection;
    property AlternatingColors;
    property ItemIndex;
    property Images;
    property ScrollViewPos;
    property ItemSpaces;
    property SideSpace;
    property OnItemClickEx: TksListViewRowClickEvent read FOnItemClickEx write FOnItemClickEx;
    property OnItemClickRightEx: TksListViewRowClickEvent read FOnItemRightClickEx write FOnItemRightClickEx;
    property Align;
    property Anchors;
    property CanFocus default True;
    property IsUpdating: Boolean read GetIsUpdating;
    property CanParentFocus;
    property CheckMarks: TksListViewCheckMarks read FCheckMarks write SetCheckMarks default ksCmNone;
    property ClipChildren default True;
    property ClipParent default False;
    property Cursor default crDefault;
    property DisableFocusEffect default True;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property Locked default False;
    property Height;
    property HitTest default True;
    property Margins;
    property Opacity;
    property Padding;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property SelectOnRightClick: Boolean read FSelectOnRightClick write FSelectOnRightClick default False;
    property Size;
    property TabOrder;
    property TabStop;
    property Visible default True;
    property Width;
    { events }
    property OnApplyStyleLookup;
    { Drag and Drop events }
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    { Keyboard events }
    property OnKeyDown;
    property OnKeyUp;
    { Mouse events }
    property OnCanFocus;

    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;

    property OnPainting;
    property OnPaint;
    property OnResize;

    property HelpContext;
    property HelpKeyword;
    property HelpType;

    property StyleLookup;
    property TouchTargetExpansion;

    property OnDblClick;

    { ListView selection events }
    property CanSwipeDelete;

    property OnChange;
    property OnChangeRepainted;
    property OnItemsChange;
    property OnScrollViewChange;
    property OnItemClick;

    property OnButtonClick;
    property OnButtonChange;

    property OnDeletingItem;
    property OnDeleteItem;
    property OnDeleteChangeVisible;
    property OnSearchChange;
    property OnFilter;
    property OnPullRefresh;
    property DeleteButtonText;

    property AutoTapScroll;
    property AutoTapTreshold;
    property ShowSelection;
    property DisableMouseWheel;

    property SearchVisible;
    property SearchAlwaysOnTop;
    property SelectionCrossfade;
    property PullToRefresh;
    property PullRefreshWait;
    property OnLongClick: TksListViewRowClickEvent read FOnLongClick write FOnLongClick;
    property OnSwitchClick: TksListViewClickSwitchEvent read FOnSwitchClicked write FOnSwitchClicked;
    property OnSegmentButtonClicked: TksListViewClickSegmentButtonEvent read FOnSegmentButtonClicked write FOnSegmentButtonClicked;
    property OnScrollFinish: TksListViewFinishScrollingEvent read FOnFinishScrolling write FOnFinishScrolling;
  end;

procedure Register;

implementation

uses SysUtils, FMX.Platform, FMX.Forms, FMX.SearchBox;

const
{$IFDEF IOS}
  DefaultScrollBarWidth = 7;
{$ELSE}
{$IFDEF MACOS}
  DefaultScrollBarWidth = 7;
{$ENDIF}
{$ENDIF}

{$IFDEF MSWINDOWS}
  DefaultScrollBarWidth = 16;
{$ENDIF}

{$IFDEF ANDROID}
  DefaultScrollBarWidth = 7;
{$ENDIF}

procedure Register;
begin
  RegisterComponents('kernow Software FMX', [TksListView]);
end;


// ------------------------------------------------------------------------------

function GetScreenScale: single;
var
  Service: IFMXScreenService;
begin
  Service := IFMXScreenService(TPlatformServices.Current.GetPlatformService
    (IFMXScreenService));
  Result := Service.GetScreenScale;

//{$IFDEF IOS}
//  if Result = 1 then
//    Result := 1.5;
//{$ENDIF}
end;

function IsBlankBitmap(ABmp: TBitmap): Boolean;
var
  ABlank: TBitmap;
begin
  Result := False;
  ABlank := TBitmap.Create(ABmp.Width, ABmp.Height);
  try
    ABlank.Clear(claNull);
    Result := ABmp.EqualsBitmap(ABlank);
  finally
    {$IFDEF IOS}
    ABlank.DisposeOf;
    {$ELSE}
    ABlank.Free;
    {$ENDIF}
  end;
end;

function CreateAlphaGuid: string;
var
  AGuid: TGUID;
  AStr: string;
  ICount: integer;
begin
  Result := '';
  CreateGUID(AGuid);
  AStr := GUIDToString(AGuid);
  for ICount := 1 to Length(AStr) do
  begin
    if (UpCase(AStr[ICount]) in ['A'..'Z']) then
      Result := Result + UpCase(AStr[ICount]);
  end;
end;

// ------------------------------------------------------------------------------

{ TksListItemRowObj }

procedure TksListItemRowObj.CalculateRect(ARowBmp: TBitmap);
var
  w,h: single;
  ABmpWidth: single;
begin
  w := FRect.Width;
  h := FRect.Height;

  ABmpWidth := ARowBmp.Width / GetScreenScale;

  FRect := RectF(0, 0, w, h);
  if FAlign = TListItemAlign.Leading then
    OffsetRect(FRect, FPlaceOffset.X, 0);

  if FAlign = TListItemAlign.Trailing then
    OffsetRect(FRect, ABmpWidth - (FRect.Width+ DefaultScrollBarWidth + FPlaceOffset.X {+ FRow.ListView.ItemSpaces.Right}), 0);

  case VertAlign of
    TListItemAlign.Center: OffsetRect(FRect, 0, (FRow.Owner.Height - FRect.Height) / 2);
    TListItemAlign.Trailing: OffsetRect(FRect, 0, (FRow.Owner.Height - FRect.Height));
  end;

  OffsetRect(FRect, 0, FPlaceOffset.Y);
end;

procedure TksListItemRowObj.Changed;
begin
  FRow.Cached := False;
end;

procedure TksListItemRowObj.Click(x, y: single);
begin
  // overridden in descendant classes.
end;

constructor TksListItemRowObj.Create(ARow: TKsListItemRow);
var
  AGuid: TGUID;
begin
  inherited Create;
  FRow := ARow;
  FControlImageCache := TksListView(ARow.ListView).FControlBitmapCache;
  FAlign := TListItemAlign.Leading;
  FPlaceOffset := PointF(0,0);
  FTagBoolean := False;
  CreateGUID(AGuid);
  FGuid := GUIDToString(AGuid);
end;

procedure TksListItemRowObj.DoChanged(Sender: TObject);
begin
  Changed;
end;

function TksListItemRowObj.Render(ACanvas: TCanvas): Boolean;
begin
  Result := True;
end;

procedure TksListItemRowObj.SetAlign(const Value: TListItemAlign);
begin
  FAlign := Value;
  Changed;
end;

procedure TksListItemRowObj.SetID(const Value: string);
begin
  FId := Value;
  Changed;
end;

procedure TksListItemRowObj.SetRect(const Value: TRectF);
begin
  FRect := Value;
  Changed;
end;

procedure TksListItemRowObj.SetVertAlign(const Value: TListItemAlign);
begin
  FVertAlignment := Value;
  Changed;
end;

// ------------------------------------------------------------------------------

{ TksListItemRowText }

constructor TksListItemRowText.Create(ARow: TKsListItemRow);
begin
  inherited Create(ARow);
  FFont := TFont.Create;
  FTextColor := claBlack;
  FWordWrap := False;
end;

destructor TksListItemRowText.Destroy;
begin
  {$IFDEF IOS}
  FFont.DisposeOf;
  {$ELSE}
  FFont.Free;
  {$ENDIF}
  inherited;
end;

function TksListItemRowText.Render(ACanvas: TCanvas): Boolean;
begin
  Result := inherited Render(ACanvas);
  ACanvas.Fill.Color := FTextColor;
  ACanvas.Font.Assign(FFont);
  ACanvas.FillText(FRect, FText, FWordWrap, 1, [], FAlignment);
  Result := True;
end;

procedure TksListItemRowText.SetAlignment(const Value: TTextAlign);
begin
  FAlignment := Value;
  Changed;
end;

procedure TksListItemRowText.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Changed;
end;

procedure TksListItemRowText.SetText(const Value: string);
begin
  FText := Value;
  Changed;
end;

procedure TksListItemRowText.SetTextColor(const Value: TAlphaColor);
begin
  FTextColor := Value;
  Changed;
end;

procedure TksListItemRowText.SetWordWrap(const Value: Boolean);
begin
  FWordWrap := Value;
  Changed;
end;

// ------------------------------------------------------------------------------

{ TksListItemRowImage }

constructor TksListItemRowImage.Create(ARow: TKsListItemRow);
begin
  inherited Create(ARow);
  FBitmap := TBitmap.Create;
  FBitmap.OnChange := DoChanged;
end;

destructor TksListItemRowImage.Destroy;
begin
  {$IFDEF IOS}
  FBitmap.DisposeOf;
  {$ELSE}
  FBitmap.Free;
  {$ENDIF}
  inherited;
end;

function TksListItemRowImage.Render(ACanvas: TCanvas): Boolean;
begin
  Result := inherited Render(ACanvas);
  ACanvas.DrawBitmap(FBitmap, RectF(0, 0, FBitmap.Width, FBitmap.Height),
    FRect, 1, True);
end;

procedure TksListItemRowImage.SetBitmap(const Value: TBitmap);
begin
  FBitmap.Assign(Value);
  FBitmap.BitmapScale := GetScreenScale;
  Changed;
end;

// ------------------------------------------------------------------------------

{ TksListItemRowShape }

constructor TksListItemRowShape.Create(ARow: TKsListItemRow);
begin
  inherited;
  FStroke := TBrush.Create(TBrushKind.Solid, claBlack);
  FFill := TBrush.Create(TBrushKind.Solid, claNull);
  FCornerRadius := 0;
  FShape := ksRectangle;
end;

destructor TksListItemRowShape.Destroy;
begin
  FFill.Free;
  FStroke.Free;
  inherited;
end;

function TksListItemRowShape.Render(ACanvas: TCanvas): Boolean;
var
  ARect: TRectF;
  ACorners: TCorners;
begin
  Result := inherited Render(ACanvas);
  ARect := FRect;
  ACorners := [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight];
  ACanvas.Fill.Assign(FFill);
  if FShape = ksEllipse then
    ACanvas.FillEllipse(ARect, 1)
  else
    ACanvas.FillRect(ARect, FCornerRadius, FCornerRadius, ACorners, 1);
  ACanvas.Fill.Assign(FStroke);
  if FShape = ksEllipse then
    ACanvas.DrawEllipse(ARect, 1)
  else
    ACanvas.DrawRect(ARect, FCornerRadius, FCornerRadius, ACorners, 1);
end;

procedure TksListItemRowShape.SetCornerRadius(const Value: single);
begin
  FCornerRadius := Value;
  Changed;
end;

procedure TksListItemRowShape.SetShape(const Value: TksListViewShape);
begin
  FShape := Value;
  Changed;
end;

// ------------------------------------------------------------------------------

{ TksListItemRow }

procedure TKsListItemRow.CacheRow;
var
  ICount: integer;
  r: TRectF;
  AMargins: TBounds;
  ABmpWidth: integer;
  AImage: TBitmap;
  ASize: TSizeF;
begin
  if FCached then
    Exit;
  AMargins := (Owner.Parent as TCustomListView).ItemSpaces;
  BeginUpdate;
  try
    ABmpWidth := Round(RowWidth) - Round((AMargins.Left + AMargins.Right) * GetScreenScale);
    Bitmap.Height := Round(RowHeight);
    Bitmap.Width := ABmpWidth;
    Bitmap.Clear(claNull);
    Bitmap.Canvas.BeginScene;

    if FIndicatorColor <> claNull then
    begin
      Bitmap.Canvas.Fill.Color := FIndicatorColor;
      Bitmap.Canvas.FillRect(RectF(0, 8, 6, RowHeight(False)-8), 0, 0, [], 1, Bitmap.Canvas.Fill);
    end;

    {$IFDEF XE8_OR_NEWER}

    if FImageIndex > -1 then
    begin
      ASize.cx := 32;
      ASize.cy := 32;
      AImage := ListView.Images.Bitmap(ASize, FImageIndex);
      DrawBitmap(AImage, 0, ASize.cx, ASize.cy);
    end;

    {$ENDIF}

    if FAutoCheck then
    begin
      FAccessory.AccessoryType := TAccessoryType.Checkmark;
      if (Owner as TListViewItem).Checked then
      begin
        FAccessory.CalculateRect(Bitmap);
        FAccessory.Render(Bitmap.Canvas);
      end;
    end
    else
    begin
      if FShowAccessory then
      begin
        FAccessory.CalculateRect(Bitmap);
        FAccessory.Render(Bitmap.Canvas);
      end;
    end;
    for ICount := 0 to FList.Count - 1 do
    begin
      FList[ICount].CalculateRect(Bitmap);
      if FList[ICount].Render(Bitmap.Canvas) = False then
      begin
        FCached := False;
        Bitmap.Canvas.EndScene;
        Bitmap.Clear(claNull);
        Exit;
      end;
    end;
    Bitmap.Canvas.EndScene;
    FCached := True;
  finally
    EndUpdate;
  end;
end;

procedure TKsListItemRow.Changed;
begin
  FCached := False;
  if not ListView.IsUpdating then
  begin
    CacheRow;
    ListView.Repaint;
  end;
end;

constructor TKsListItemRow.Create(const AOwner: TListItem);
var
  ABmp: TBitmap;
begin
  inherited Create(AOwner);
  {$IFDEF MSWINDOWS}
  ScalingMode := TImageScalingMode.Original;
  {$ENDIF}
  PlaceOffset.X := 0;
  FIndicatorColor := claNull;
  OwnsBitmap := True;
  FList := TObjectList<TksListItemRowObj>.Create(True);
  FList.OnNotify := DoOnListChanged;
  FImage := TBitmap.Create;
  ABmp := TBitmap.Create;
  ABmp.BitmapScale := GetScreenScale;
  ABmp.Width := Round(RowWidth);
  ABmp.Height := Round(RowHeight);
  ABmp.Clear(claNull);
  Bitmap := ABmp;
  FTextColor := claBlack;
  FFont := TFont.Create;
  FDetailFont := TFont.Create;
  FFont.OnChanged := DoFontChanged;
  FDetailFont.OnChanged := DoDetailFontChanged;
  FDetailColor := claDodgerblue;
  FCached := False;
  FAccessory := TKsListItemRowAccessory.Create(Self);
  FShowAccessory := True;
  FAutoCheck := False;
  FImageIndex := -1;
  FTextOffset := 0;
end;

destructor TKsListItemRow.Destroy;
begin
  {$IFDEF IOS}
  FList.DisposeOf;
  FFont.DisposeOf;
  FDetailFont.DisposeOf;
  FAccessory.DisposeOf;
  FImage.DisposeOf;
  {$ELSE}
  FList.Free;
  FFont.Free;
  FDetailFont.Free;
  FAccessory.Free;
  FImage.Free;
  {$ENDIF}
  inherited;
end;

function TKsListItemRow.ScreenWidth: single;
begin
  Result := TksListView(Owner.Parent).Width;
{$IFDEF MSWINDOWS}
  Result := Result - 40;
{$ENDIF}
end;

function TKsListItemRow.TextHeight(AText: string): single;
begin
  Bitmap.Canvas.Font.Assign(FFont);
  Result := Bitmap.Canvas.TextHeight(AText);
end;

function TKsListItemRow.TextWidth(AText: string): single;
begin
  Bitmap.Canvas.Font.Assign(FFont);
  Result := Bitmap.Canvas.TextWidth(AText);
end;

procedure TKsListItemRow.RecreateText;
begin
  AddText(FText);
  Changed;
end;

procedure TKsListItemRow.RecreateDetail;
begin
  AddDetail(FDetailText);
  Changed;
end;

procedure TKsListItemRow.RecreateImage;
begin
  AddImage(FImage);
  Changed;
end;

function TKsListItemRow.RowHeight(const AScale: Boolean = True): single;
var
  lv: TksListView;
begin
  lv := TksListView(Owner.Parent);
  Result := lv.ItemAppearance.ItemHeight;
  if AScale then
    Result := Result * GetScreenScale;
end;

function TKsListItemRow.RowWidth(const AScale: Boolean = True): single;
var
  lv: TksListView;
begin
  lv := TksListView(Owner.Parent);
  Result := lv.Width;
  if AScale then
    Result := Result * GetScreenScale;
end;

function TKsListItemRow.GetAccessory: TAccessoryType;
begin
  Result := FAccessory.AccessoryType;
end;

function TKsListItemRow.GetListView: TCustomListView;
begin
  Result := (Owner.Parent as TCustomListView);
end;

function TKsListItemRow.GetRowObject(AIndex: integer): TksListItemRowObj;
begin
  Result := FList[AIndex];
end;

function TKsListItemRow.GetRowObjectCount: integer;
begin
  Result := FList.Count;
end;

function TKsListItemRow.GetSearchIndex: string;
begin
  Result := TListViewItem(Owner).Text;
end;

procedure TKsListItemRow.ProcessClick;
begin
  if FAutoCheck then
  begin
    Accessory := TAccessoryType.Checkmark;
    (Owner as TListViewItem).Checked := not (Owner as TListViewItem).Checked;
    FCached := False;
    CacheRow;
  end;
end;

procedure TKsListItemRow.DoDetailFontChanged(Sender: TObject);
begin
  RecreateDetail;
end;

procedure TKsListItemRow.DoFontChanged(Sender: TObject);
begin
  RecreateText;
end;

procedure TKsListItemRow.DoOnListChanged(Sender: TObject;
  const Item: TksListItemRowObj; Action: TCollectionNotification);
begin
  FCached := False;
end;

// ------------------------------------------------------------------------------

// bitmap drawing functions...

function TKsListItemRow.DrawBitmap(ABmp: TBitmap; x, AWidth, AHeight: single): TksListItemRowImage;
begin
  Result := DrawBitmap(ABmp, x, 0, AWidth, AHeight);
end;

function TKsListItemRow.DrawBitmap(ABmpIndex: integer;
  x, AWidth, AHeight: single): TksListItemRowImage overload;
var
  ABmp: TBitmap;
  il: TCustomImageList;
  ASize: TSizeF;
begin
  il := ListView.Images;
  if il = nil then
    Exit;
  ASize.cx := 64;
  ASize.cy := 64;
  ABmp := il.Bitmap(ASize, ABmpIndex);
  Result := DrawBitmap(ABmp, x, AWidth, AHeight);
end;

function TKsListItemRow.DrawBitmap(ABmp: TBitmap; x, y, AWidth, AHeight: single)
  : TksListItemRowImage;
begin
  Result := TksListItemRowImage.Create(Self);
  Result.FRect := RectF(0, 0, AWidth, AHeight);
  Result.PlaceOffset := PointF(x,y);
  Result.VertAlign := TListItemAlign.Center;
  Result.Bitmap := ABmp;
  FList.Add(Result);
end;

function TKsListItemRow.DrawBitmapRight(ABmp: TBitmap;
  AWidth, AHeight, ARightPadding: single): TksListItemRowImage;
var
  AYpos: single;
  AXPos: single;
begin
  AYpos := (RowHeight(False) - AHeight) / 2;
  AXPos := ScreenWidth - (AWidth + ARightPadding);
  Result := DrawBitmap(ABmp, AXPos, AYpos, AWidth, AHeight);
end;

function TKsListItemRow.DrawRect(x, y, AWidth, AHeight: single; AStroke,
  AFill: TAlphaColor): TksListItemRowShape;
begin
  Result := TksListItemRowShape.Create(Self);
  Result.FRect := RectF(0, 0, AWidth, AHeight);
  Result.PlaceOffset := PointF(x,y);
  Result.Stroke.Color := AStroke;
  Result.Fill.Color := AFill;
  Result.VertAlign := TListItemAlign.Center;
  FList.Add(Result);
end;

function TKsListItemRow.DrawRoundRect(x, y, AWidth, AHeight,
  ACornerRadius: single; AStroke, AFill: TAlphaColor): TksListItemRowShape;
begin
  Result := DrawRect(x, y, AWidth, AHeight, AStroke, AFill);
  Result.CornerRadius := ACornerRadius;
end;

function TKsListItemRow.DrawEllipse(x, y, AWidth, AHeight: single; AStroke,
  AFill: TAlphaColor): TksListItemRowShape;
begin
  Result := DrawRect(x, y, AWidth, AHeight, AStroke, AFill);
  Result.Shape := ksEllipse;
end;

function TKsListItemRow.AddImage(AImage: TBitmap): TksListItemRowImage;
var
  ICount: integer;
begin
  for ICount := FList.Count-1 downto 0 do
  begin
    if FList[ICount].ID = 'item_image' then
    begin
      FList.Delete(ICount);
      Break;
    end;
  end;
  FImage.Assign(AImage);

  with DrawBitmap(FImage,  0, 24, 24) do
  begin
    ID := 'item_image';
  end;
end;

function TKsListItemRow.AddText(AText: string): TksListItemRowText;
var
  ASaveFont: TFont;
  ICount: integer;
  AXPos: integer;
begin
  AXPos := 0;
  for ICount := FList.Count-1 downto 0 do
  begin
    if FList[ICount].ID = 'item_text' then
    begin
      FList.Delete(ICount);
      Break;
    end;
  end;
  FText := AText;
  ASaveFont := TFont.Create;
  try
    ASaveFont.Assign(FFont);
    FFont.Assign(FFont);

    if FTextOffset > 0 then
        AXPos := FTextOffset
    else
    begin
      if (FImageIndex > -1) or (FImage.Width > 0) then AXPos := 32;
      if FIndicatorColor <> claNull then AXPos := 16;
    end;

    with TextOut(AText, AXPos, TextWidth(AText)) do
    begin
      ID := 'item_text';
      FFont.Assign(FFont);
      TextColor := FTextColor;
    end;
    FFont.Assign(ASaveFont);
  finally
    {$IFDEF IOS}
    ASaveFont.DisposeOf;
    {$ELSE}
    ASaveFont.Free;
    {$ENDIF}
  end;
end;

function TKsListItemRow.AddDetail(AText: string): TksListItemRowText;
var
  ASaveFont: TFont;
  ICount: integer;
begin
  for ICount := FList.Count-1 downto 0 do
  begin
    if FList[ICount].ID = 'detail_text' then
    begin
      FList.Delete(ICount);
      Break;
    end;
  end;
  FDetailText := AText;
  ASaveFont := TFont.Create;
  try
    ASaveFont.Assign(FFont);
    FFont.Assign(FDetailFont);

    with TextOutRight(AText, 0, TextWidth(AText), 20) do
    begin
      ID := 'detail_text';
      FFont.Assign(FDetailFont);
      TextColor := FDetailColor;
    end;
    FFont.Assign(ASaveFont);
  finally
    {$IFDEF IOS}
    ASaveFont.DisposeOf;
    {$ELSE}
    ASaveFont.Free;
    {$ENDIF}
  end;
end;

function TKsListItemRow.AddSegmentButtons(AWidth: integer;
                                          ACaptions: array of string;
                                          const ATintColor: TAlphaColor = claSilver): TksListItemRowSegmentButtons;
var
  ICount: integer;
begin
  Result := TksListItemRowSegmentButtons.Create(Self);
  Result.Align := TListItemAlign.Trailing;
  Result.VertAlign := TListItemAlign.Center;
  Result.Rect := RectF(0, 0, AWidth, C_SEGMENT_BUTTON_HEIGHT);
  Result.TintColor := ATintColor;
  for ICount := Low(ACaptions) to High(ACaptions) do
    Result.Captions.Add(ACaptions[ICount]);
  ShowAccessory := False;
  FList.Add(Result);
end;


function TKsListItemRow.AddSwitch(x: single;
                                  AIsChecked: Boolean;
                                  const AAlign: TListItemAlign = TListItemAlign.Leading): TksListItemRowSwitch;
var
  s: TSwitch;
  ASize: TSizeF;
  ARect: TRectF;
begin
  s := TSwitch.Create(nil);
  try
    ASize.Width := s.Width;
    ASize.Height := s.Height;
  finally
    {$IFDEF IOS}
    s.DisposeOf;
    {$ELSE}
    s.Free;
    {$ENDIF}
  end;
  Result := TksListItemRowSwitch.Create(Self);
  Result.Rect := RectF(0, 0, ASize.Width, ASize.Height);
  Result.Align := AAlign;
  Result.VertAlign := TListItemAlign.Center;
  Result.PlaceOffset := PointF(x, 0);
  Result.IsChecked := AIsChecked;
  FList.Add(Result);
end;

function TksListItemRow.AddSwitchRight(AMargin: integer; AIsChecked: Boolean): TksListItemRowSwitch;
begin
  Result := AddSwitch(AMargin, AIsChecked, TListItemAlign.Trailing)
end;

procedure TKsListItemRow.SetAccessory(const Value: TAccessoryType);
begin
  FAccessory.AccessoryType := Value;
end;

procedure TKsListItemRow.SetAutoCheck(const Value: Boolean);
begin
  FAutoCheck := Value;
  if FAutoCheck then
    FAccessory.AccessoryType := TAccessoryType.Checkmark;
  Changed;
end;

procedure TKsListItemRow.SetChecked(const Value: Boolean);
begin
  if (Owner as TListViewItem).Checked <> Value then
  begin
    (Owner as TListViewItem).Checked := Value;
    Changed;
  end;
end;

procedure TKsListItemRow.SetDetailColor(const Value: TAlphaColor);
begin
  if FDetailColor <> Value then
  begin
    FDetailColor := Value;
    RecreateDetail;
  end;
end;

procedure TKsListItemRow.SetFontProperties(AName: string; ASize: integer;
  AColor: TAlphaColor; AStyle: TFontStyles);
begin
  if AName <> '' then
    FFont.Family := AName;
  FFont.Size := ASize;
  FTextColor := AColor;
  FFont.Style := AStyle;
end;

procedure TKsListItemRow.SetImage(const Value: TBitmap);
begin
  FImage.Assign(Value);
  RecreateImage;
  RecreateText;
end;

procedure TKsListItemRow.SetImageIndex(const Value: integer);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    Changed;
  end;
end;

procedure TKsListItemRow.SetIndicatorColor(const Value: TAlphaColor);
begin
  FIndicatorColor := Value;
  RecreateText;
end;

procedure TKsListItemRow.SetSearchIndex(const Value: string);
begin
  TListViewItem(Owner).Text := Value;
end;

procedure TKsListItemRow.SetShowAccessory(const Value: Boolean);
begin
  if FShowAccessory <> Value then
  begin
    FShowAccessory := Value;
    Changed;
  end;
end;

procedure TKsListItemRow.SetTextOffset(const Value: integer);
begin
  FTextOffset := Value;
  RecreateText;
end;

// ------------------------------------------------------------------------------

// text drawing functions...

function TKsListItemRow.TextOut(AText: string; x: single;
  const AVertAlign: TTextAlign = TTextAlign.Center;
  const AWordWrap: Boolean = False): TksListItemRowText;
var
  AWidth: single;
begin
  AWidth := TextWidth(AText);
  Result := TextOut(AText, x,  AWidth, AVertAlign, AWordWrap);
end;

function TKsListItemRow.TextOut(AText: string; x, AWidth: single;
  const AVertAlign: TTextAlign = TTextAlign.Center;
  const AWordWrap: Boolean = False): TksListItemRowText;
begin
  Result := TextOut(AText, x, 0, AWidth, AVertAlign, AWordWrap);
end;


function TKsListItemRow.TextOut(AText: string; x, y, AWidth: single;
  const AVertAlign: TTextAlign = TTextAlign.Center;
  const AWordWrap: Boolean = False): TksListItemRowText;
var
  AHeight: single;

begin
  Result := TksListItemRowText.Create(Self);
  Result.Font.Assign(FFont);
  AHeight := TextHeight(AText);
  Result.FPlaceOffset := PointF(x, y);
  if AWordWrap then
    AHeight := RowHeight(False);
  if AWidth = 0 then
    AWidth := TextWidth(AText);
  Result.FRect := RectF(0, 0, AWidth, AHeight);
  case AVertAlign of
    TTextAlign.Leading: Result.VertAlign := TListItemAlign.Leading;
    TTextAlign.Center: Result.VertAlign := TListItemAlign.Center;
    TTextAlign.Trailing: Result.VertAlign := TListItemAlign.Trailing;
  end;
  Result.TextAlignment := TTextAlign.Leading;
  Result.TextColor := FTextColor;
  Result.Text := AText;
  Result.WordWrap := AWordWrap;
  if SearchIndex = '' then
    SearchIndex := AText;
  FList.Add(Result);
end;

function TKsListItemRow.TextOutRight(AText: string; y, AWidth: single;
  AXOffset: single; const AVertAlign: TTextAlign = TTextAlign.Center)
  : TksListItemRowText;
begin
  Result := TextOut(AText, AXOffset, y, AWidth, AVertAlign);
  Result.Align := TListItemAlign.Trailing;
  Result.TextAlignment := TTextAlign.Trailing;
end;


// ------------------------------------------------------------------------------

{ TksListViewAppearence }

constructor TksListViewAppearence.Create(AListView: TksListView);
begin
  inherited Create;
  FListView := AListView;
  FBackground := claWhite;
  FItemBackground := claWhite;
  FAlternatingItemBackground := claGainsboro;
end;

procedure TksListViewAppearence.SetAlternatingItemBackground
  (const Value: TAlphaColor);
begin
  FAlternatingItemBackground := Value;
  FListView.ApplyStyle;
end;

procedure TksListViewAppearence.SetBackground(const Value: TAlphaColor);
begin
  FBackground := Value;
  FListView.ApplyStyle;
end;

procedure TksListViewAppearence.SetItemBackground(const Value: TAlphaColor);
begin
  FItemBackground := Value;
  FListView.ApplyStyle;
end;

// ------------------------------------------------------------------------------

{ TksListView }

procedure TksListView.CheckAll;
var
  ICount: integer;
begin
  for ICount := 0 to Items.Count-1 do
    Items[ICount].Checked := True;
  RedrawAllRows;
end;

function TksListView.CountUncachedRows: integer;
var
  ICount: integer;
  ARow: TKsListItemRow;
begin
  Result := 0;
  for ICount := 0 to Items.Count - 1 do
  begin
    ARow := CachedRow[ICount];
    if ARow <> nil then
    begin
      if ARow.Cached = False then
        Result := Result + 1;
    end;
  end;
end;

constructor TksListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FScreenScale := GetScreenScale;
  FAppearence := TksListViewAppearence.Create(Self);
  FControlBitmapCache := TksControlBitmapCache.Create(Self);
  FItemHeight := 44;
  FClickTimer := TTimer.Create(Self);
  FLastWidth := 0;
  FSelectOnRightClick := False;
  FCacheTimer := TTimer.Create(Self);
  FCacheTimer.Interval := 100;
  FCacheTimer.OnTimer := OnCacheTimer;
  FCacheTimer.Enabled := True;
  FLastScrollPos := 0;
  FScrolling := False;
  FScrollTimer := TTimer.Create(Self);
  FScrollTimer.Interval := 500;
  FScrollTimer.OnTimer := DoScrollTimer;
  FScrollTimer.Enabled := True;
end;

destructor TksListView.Destroy;
var
  ICount: integer;
begin
  {$IFDEF IOS}
  FAppearence.DisposeOf;
  FClickTimer.DisposeOf;
  FCacheTimer.DisposeOf;
  FScrollTimer.DisposeOf;
  FControlBitmapCache.DisposeOf;
  {$ELSE}
  FAppearence.Free;
  FClickTimer.Free;
  FCacheTimer.Free;
  FScrollTimer.Free;
  FControlBitmapCache.Free;
  {$ENDIF}
  inherited;
end;

function TksListView.AddHeader(AText: string): TKsListItemRow;
begin
  Result := AddRow('', '', None);
  Result.Owner.Purpose := TListItemPurpose.Header;
  Result.Font.Style := [];
  Result.TextColor := claDimgray;
  Result.Font.Size := 14;
  Result.TextOut(AText, 0, -3, 0, TTextAlign.Trailing);
  Result.CacheRow;
end;


function TksListView.AddRow(AText, ADetail: string; AAccessory: TksAccessoryType; const AImageIndex: integer = -1;
  const AFontSize: integer = 14; AFontColor: TAlphaColor = claBlack): TKsListItemRow;
var
  AItem: TListViewItem;
begin
  AItem := Items.Add;
  AItem.Height := ItemHeight;
  AItem.Objects.Clear;
  AItem.Purpose := TListItemPurpose.None;
  Result := TKsListItemRow.Create(AItem);
  if FCheckMarks <> ksCmNone then
    Result.AutoCheck := True;
  Result.Name := 'ksRow';
  Result.ShowAccessory := AAccessory <> None;
  case AAccessory of
    More: Result.Accessory := TAccessoryType.More;
    Checkmark: Result.Accessory := TAccessoryType.Checkmark;
    Detail: Result.Accessory := TAccessoryType.Detail;
  end;
  Result.SetFontProperties('', AFontSize, AFontColor, []);

  if AText <> '' then
    Result.AddText(AText);
  {if AImageIndex = -1 then
    Result.TextOut(AText, 0)
  else
    Result.TextOut(AText, 40); }
  if ADetail <> '' then
    Result.AddDetail(ADetail);
  Result.ImageIndex := AImageIndex;
end;



procedure TksListView.SetCheckMarks(const Value: TksListViewCheckMarks);
begin
  if FCheckMarks <> Value then
  begin
    FCheckMarks := Value;
    UncheckAll;
    RedrawAllRows;
  end;
end;

procedure TksListView.SetColorStyle(AName: string; AColor: TAlphaColor);
var
  StyleObject: TFmxObject;
begin
  StyleObject := FindStyleResource(AName);
  if StyleObject <> nil then
  begin
    (StyleObject as TColorObject).Color := AColor;
    Invalidate;
  end;
end;

procedure TksListView.SetItemHeight(const Value: integer);
var
  ICount: integer;
  ARow: TKsListItemRow;
begin
  BeginUpdate;
  try
    FItemHeight := Value;
    RedrawAllRows;
  finally
    ItemAppearance.ItemHeight := Value;
    EndUpdate;
  end;
  Repaint;
end;

procedure TksListView.UncheckAll;
var
  ICount: integer;
begin
  for ICount := 0 to Items.Count-1 do
    Items[ICount].Checked := False;
  RedrawAllRows;
end;

procedure TksListView.ApplyStyle;
var
  StyleObject: TFmxObject;
begin
  SetColorStyle('background', FAppearence.Background);
  SetColorStyle('itembackground', FAppearence.ItemBackground);
  SetColorStyle('alternatingitembackground',
    FAppearence.AlternatingItemBackground);
  inherited;
end;

procedure TksListView.BeginUpdate;
begin
  inherited;
  Inc(FUpdateCount);
end;

procedure TksListView.DoClickTimer(Sender: TObject);
var
  ARow: TKsListItemRow;
  AId: string;
  AMouseDownRect: TRectF;
begin
  if FClickedItem = nil then
  begin
    FClickTimer.Enabled := False;
    FMouseDownDuration := 0;
    Exit;
  end;

  FMouseDownDuration := FMouseDownDuration + 1;
  AId := '';
  ARow := nil;
  if FMouseDownDuration >= C_LONG_TAP_DURATION  then
  begin
    FClickTimer.Enabled := False;

    ARow := CachedRow[FClickedItem.Index];
    if ARow <> nil then
      AId := ARow.ID;
    AMouseDownRect := RectF(FMouseDownPos.X-8, FMouseDownPos.Y-8, FMouseDownPos.X+8, FMouseDownPos.Y+8);
    if PtInRect(AMouseDownRect, FCurrentMousepos) then
    begin
      if Assigned(FOnLongClick) then
        FOnLongClick(Self, FMouseDownPos.x, FMouseDownPos.y, FClickedItem, AId, FClickedRowObj);
    end;
    ItemIndex := -1;
  end;
end;


procedure TksListView.DoItemChange(const AItem: TListViewItem);
var
  ARow: TKsListItemRow;
begin
  inherited;
  ARow := CachedRow[AItem.Index];
  ARow.FCached := False;
  ARow.CacheRow;
end;

procedure TksListView.DoItemClick(const AItem: TListViewItem);
begin
  inherited;
end;

procedure TksListView.DoScrollTimer(Sender: TObject);
var
  AVisibleItems: TksVisibleItems;
begin

  if FScrolling = False then
  begin
    if Trunc(ScrollViewPos) <> FLastScrollPos then
    begin
      FScrolling := True;
      FLastScrollPos := Trunc(ScrollViewPos);
      Exit;
    end;
  end
  else
  begin
    if FLastScrollPos = Trunc(ScrollViewPos) then
    begin
      FScrolling := False;
      if Assigned(FOnFinishScrolling) then
      begin
        AVisibleItems := ItemsInView;
        FOnFinishScrolling(Self, AVisibleItems.IndexStart, AVisibleItems.Count);
      end;
    end;
  end;
  FLastScrollPos := Trunc(ScrollViewPos);
end;

procedure TksListView.MouseUp(Button: TMouseButton; Shift: TShiftState; x,
  y: single);
var
  AId: string;
  ARow: TKsListItemRow;
  ARow2: TKsListItemRow;
  ICount: integer;
  AObjRect: TRectF;
  AMouseDownRect: TRect;
  ALongTap: Boolean;
begin
  inherited;
  FClickTimer.Enabled := False;
  ALongTap := FMouseDownDuration >= C_LONG_TAP_DURATION ;
  FMouseDownDuration := 0;

  x := x - ItemSpaces.Left;

  AMouseDownRect := Rect(Round(FMouseDownPos.X-8), Round(FMouseDownPos.Y-8), Round(FMouseDownPos.X+8), Round(FMouseDownPos.Y+8));
  if not PtInRect(AMouseDownRect, Point(Round(x),Round(y))) then
    Exit;


  if FClickedItem <> nil then
  begin
    AId := '';
    ARow := CachedRow[FClickedItem.Index];
    if ARow <> nil then
    begin
      AId := ARow.ID;
      for ICount := 0 to ARow.RowObjectCount - 1 do
      begin
        AObjRect := ARow.RowObject[ICount].Rect;
        if (FMouseDownPos.x >= (AObjRect.Left - 5)) and
          (FMouseDownPos.x <= (AObjRect.Right + 5)) then
        begin
          FClickedRowObj := ARow.RowObject[ICount];
        end;
      end;
      ARow.ProcessClick;
      if FCheckMarks = TksListViewCheckMarks.ksCmSingleSelect then
      begin
        for ICount := 0 to Items.Count-1 do
        begin
          if ICount <> FClickedItem.Index then
          begin
            ARow2 := CachedRow[ICount];
            (ARow2.Owner as TListViewItem).Checked := False;
            InvalidateRect(GetItemRect(TListViewItem(ARow2.Owner).Index));
          end;
        end;
      end;
    end;
    if not ALongTap then
    begin
      // normal click.
      if Button = TMouseButton.mbLeft then
      begin
        if Assigned(FOnItemClickEx) then
          FOnItemClickEx(Self, FMouseDownPos.x, FMouseDownPos.y, FClickedItem, AId, FClickedRowObj)
      else
        if Assigned(FOnItemRightClickEx) then
          FOnItemRightClickEx(Self, FMouseDownPos.x, FMouseDownPos.y, FClickedItem, AId, FClickedRowObj);
      end;
      if FClickedRowObj <> nil then
      begin
        FClickedRowObj.Click(FMouseDownPos.X - FClickedRowObj.Rect.Left, FMouseDownPos.Y - FClickedRowObj.Rect.Top);
        if (FClickedRowObj is TksListItemRowSwitch) then
        begin
          (FClickedRowObj as TksListItemRowSwitch).Toggle;
          if Assigned(FOnSwitchClicked) then
            FOnSwitchClicked(Self, FClickedItem, (FClickedRowObj as TksListItemRowSwitch), AId);
        end;
        if (FClickedRowObj is TksListItemRowSegmentButtons) then
        begin
          if Assigned(FOnSegmentButtonClicked) then
            FOnSegmentButtonClicked(Self, FClickedItem, (FClickedRowObj as TksListItemRowSegmentButtons), AId);
        end;
        ARow.CacheRow;

      end;
      InvalidateRect(GetItemRect(TListViewItem(ARow.Owner).Index));
    end;
  end;
end;




procedure TksListView.OnCacheTimer(Sender: TObject);
var
  ICount: integer;
begin
  FCacheTimer.Enabled := False;
  if FControlBitmapCache.ImagesCached = False then
    FControlBitmapCache.CreateImageCache;
  if FControlBitmapCache.ImagesCached then
  begin
    FCacheTimer.OnTimer := nil;
    FCacheTimer.Enabled := False;
    Exit;
  end;
  FCacheTimer.Enabled := True;
end;

procedure TksListView.RedrawAllRows;
var
  ICount: integer;
  ARow: TKsListItemRow;
begin
  BeginUpdate;
  for ICount := 0 to Items.Count-1 do
  begin
    ARow := CachedRow[ICount];
    if ARow <> nil then
    begin
      ARow.Cached := False;
      ARow.CacheRow;
    end;
  end;
  EndUpdate;
end;


procedure TksListView.Resize;
begin
  inherited;
  RedrawAllRows;
end;

procedure TksListView.EndUpdate;
var
  ICount: integer;
  AItem: TListViewItem;
  ARow: TKsListItemRow;
  ARowObj: TKsListItemRow;
begin
  inherited EndUpdate;
  Dec(FUpdateCount);
  if FUpdateCount > 0 then
    Exit;
  for ICount := 0 to Items.Count - 1 do
  begin
    AItem := Items[ICount];
    ARow := CachedRow[AItem.Index];
    if ARow <> nil then
      ARow.CacheRow;
  end;
  Invalidate;
end;

function TksListView.GetCachedRow(index: integer): TKsListItemRow;
begin
  Result := Items[index].Objects.FindObject('ksRow') as TKsListItemRow;
end;

function TksListView.GetIsUpdating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

function TksListView.ItemsInView: TksVisibleItems;
var
  ICount: integer;
  ARect: TRectF;
  r: TRectF;
  cr: TRectF;
  ASearchHeight: integer;
  ASearchBox: TSearchBox;
begin
  cr := RectF(0, 0, Width, Height);;
  if SearchVisible then
  begin
    ASearchBox := TSearchBox.Create(nil);
    try
      ASearchHeight := Round(ASearchBox.Height);
    finally
      {$IFDEF IOS}
      ASearchBox.DisposeOf;
      {$ELSE}
      ASearchBox.Free;
      {$ENDIF}
    end;
    cr.Top := ASearchHeight;
  end;
  Result.IndexStart := -1;
  Result.IndexEnd := -1;
  Result.Count := 0;

  for ICount := 0 to Items.Count-1 do
  begin
    if IntersectRectF(r, GetItemRect(ICount), cr) then
    begin
      if Result.IndexStart = -1 then
        Result.IndexStart := ICount
      else
        Result.IndexEnd := ICount;
      Result.Count := Result.Count + 1;
    end;
  end;
end;

procedure TksListView.MouseDown(Button: TMouseButton; Shift: TShiftState;
  x, y: single);
var
  ICount: integer;
begin
  FMouseDownPos := PointF(x-ItemSpaces.Left, y);
  FClickedItem := nil;
  FClickedRowObj := nil;

  FCurrentMousepos := FMouseDownPos;
  FMouseDownDuration := 0;
  for Icount := 0 to Items.Count-1 do
  begin
    if PtInRect(GetItemRect(ICount), PointF(x,y)) then
    begin
      FClickedItem := Items[ICount];
      if (Button = TMouseButton.mbRight) and (FSelectOnRightClick) then
        ItemIndex := Icount;
    end;
  end;
  inherited;
  Application.ProcessMessages;
  FClickTimer.Interval := 100;
  FClickTimer.OnTimer := DoClickTimer;
  FClickTimer.Enabled := True;
end;

procedure TksListView.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
  FCurrentMousepos := PointF(x-ItemSpaces.Left, y);
end;

{ TksListItemRowSwitch }


function TksListItemRowSwitch.Render(ACanvas: TCanvas): Boolean;
var
  ABmp: TBitmap;
begin
  Result := inherited Render(ACanvas);
  if FControlImageCache.ImagesCached = False then
  begin
    Result := False;
    Exit;
  end;
  ABmp := TBitmap.Create;
  try
    ABmp.Assign(FControlImageCache.SwitchImage[FIsChecked]);
    ACanvas.DrawBitmap(ABmp, RectF(0,0,ABmp.Width,ABmp.Height), FRect, 1);
  finally
    {$IFDEF IOS}
    ABmp.DisposeOf;
    {$ELSE}
    ABmp.Free;
    {$ENDIF}
  end;
end;

procedure TksListItemRowSwitch.SetIsChecked(const Value: Boolean);
begin
  FIsChecked := Value;
  Changed;
end;

procedure TksListItemRowSwitch.Toggle;
begin
  IsChecked := not IsChecked;
end;

{ TKsListItemRowAccessory }

constructor TKsListItemRowAccessory.Create(ARow: TKsListItemRow);
begin
  inherited;
  FResources := FRow.GetStyleResources;
  FImage := FResources.AccessoryImages[FAccessoryType].Normal;
  FRect := RectF(0, 0, FImage.Width, FImage.Height);
  FAlign := TListItemAlign.Trailing;
  FVertAlignment := TListItemAlign.Center
end;

function TKsListItemRowAccessory.Render(ACanvas: TCanvas): Boolean;
begin
  Result := inherited Render(ACanvas);
  FImage := FResources.AccessoryImages[FAccessoryType].Normal;
  FImage.DrawToCanvas(ACanvas, FRect, 1);
end;

procedure TKsListItemRowAccessory.SetAccessoryType(const Value: TAccessoryType);
begin
  FAccessoryType := Value;
  Changed;
end;

{ TksListItemRowSegmentButtons }


procedure TksListItemRowSegmentButtons.Click(x, y: single);
var
  ABtnWidth: single;
begin
  inherited;
  ABtnWidth := FRect.Width / FCaptions.Count;
  ItemIndex := Trunc(x / ABtnWidth);
end;

constructor TksListItemRowSegmentButtons.Create(ARow: TKsListItemRow);
begin
  inherited;
  FCaptions := TStringList.Create;
  FItemIndex := -1;
end;

destructor TksListItemRowSegmentButtons.Destroy;
var
  ICount: integer;
begin
  {$IFDEF IOS}
  FCaptions.DisposeOf;
  {$ELSE}
  FCaptions.Free;
  {$ENDIF}
  inherited;
end;

function TksListItemRowSegmentButtons.Render(ACanvas: TCanvas): Boolean;
var
  ABmp: TBitmap;
  ABtnWidth: integer;
  ABtnRect: TRectF;
  ICount: integer;
  AHeight: single;
begin
  Result := inherited Render(ACanvas);
  Result := False;
  if FControlImageCache.ImagesCached = False then
    Exit;
  ABtnWidth := Trunc(FRect.Width / FCaptions.Count);
  ABtnRect := RectF(FRect.Left, FRect.Top, FRect.Left + ABtnWidth, FRect.Bottom);
  for ICount := 0 to FCaptions.Count-1 do
  begin
    if FItemIndex = -1 then
      FItemIndex := 0;
    AHeight := FRect.Height;

    ABmp := TBitmap.Create;
    try
      if ICount = 0 then ABmp.Assign(FControlImageCache.SegmentButtonImage[ksSegmentLeft, ABtnWidth, AHeight, FCaptions[ICount], FTintColor, ICount = FItemIndex])
      else
        if ICount = FCaptions.Count-1 then ABmp.Assign(FControlImageCache.SegmentButtonImage[ksSegmentRight, ABtnWidth, AHeight, FCaptions[ICount], FTintColor, ICount = FItemIndex])
      else
        ABmp.Assign(FControlImageCache.SegmentButtonImage[ksSegmentMiddle, ABtnWidth, AHeight, FCaptions[ICount], FTintColor, ICount = FItemIndex]);
    
      if ABmp <> nil then
      begin
        if IsBlankBitmap(ABmp) then
          Exit;
        ACanvas.DrawBitmap(ABmp, RectF(0,0,ABmp.Width,ABmp.Height), ABtnRect, 1, True);
        Result := True;
      end;
    finally
      {$IFDEF IOS}
      ABmp.DisposeOf;
      {$ELSE}
      ABmp.Free;
      {$ENDIF}
    end;
    OffsetRect(ABtnRect, ABtnWidth-1, 0);
  end;
end;

procedure TksListItemRowSegmentButtons.SetItemIndex(const Value: integer);
begin
  if FItemIndex = Value then
    Exit;
  if Value > FCaptions.Count-1 then
    FItemIndex := FCaptions.Count-1
  else
    FItemIndex := Value;
  Changed;
end;

procedure TksListItemRowSegmentButtons.SetTintColor(const Value: TAlphaColor);
begin
  FTintColor := Value;
  Changed;
end;

{ TksControlBitmapCache }

constructor TksControlBitmapCache.Create(Owner: TksListView);
begin
  inherited Create;
  FOwner := Owner;
  FImagesCached := False;
  FCreatingCache := False;
  FButton := TSpeedButton.Create(Owner.Parent);
  FButton.Height := C_SEGMENT_BUTTON_HEIGHT;
  FCachedButtons := TStringList.Create;
end;

destructor TksControlBitmapCache.Destroy;
var
  ICount: integer;
begin
  {$IFDEF IOS}
  FSwitchOn.DisposeOf;
  FSwitchOff.DisposeOf;
  for ICount := FCachedButtons.Count-1 downto 0 do
    FCachedButtons.Objects[ICount].DisposeOf;
  FCachedButtons.DisposeOf;
  {$ELSE}
  FSwitchOn.Free;
  FSwitchOff.Free;
  for ICount := FCachedButtons.Count-1 downto 0 do
    FCachedButtons.Objects[ICount].Free;
  FCachedButtons.Free;
  {$ENDIF}
  inherited;
end;

function TksControlBitmapCache.CreateImageCache: Boolean;
var
  ASwitch: TSwitch;
  AButton: TSpeedButton;
  AForm: TFmxObject;
  AGuid: string;
begin
  if (FImagesCached) or (FCreatingCache) then
    Exit;

  try
    FCreatingCache := True;
    Result := False;
    AForm := FOwner.Parent;
    while (AForm is TForm) = False do
        AForm := AForm.Parent;

    ASwitch := TSwitch.Create(AForm);
    try
      ASwitch.Name :=  CreateAlphaGuid;
      AForm.InsertObject(0, ASwitch);
      Application.ProcessMessages;
      ASwitch.IsChecked := True;
      FSwitchOn := ASwitch.MakeScreenshot;
      if IsBlankBitmap(FSwitchOn) then
      begin
        AForm.RemoveObject(ASwitch);
        Application.ProcessMessages;
        {$IFDEF IOS}
        ASwitch.DisposeOf;
        FSwitchOn.DisposeOf;
        {$ELSE}
        ASwitch.Free;
        FSwitchOn.Free;
        {$ENDIF};
        FSwitchOn := nil;
        ASwitch := nil;
        Exit;
      end;
         // application not ready to create images.
      ASwitch.IsChecked := False;
      FSwitchOff := ASwitch.MakeScreenshot;
    finally
      if ASwitch <> nil then
      begin
        AForm.RemoveObject(ASwitch);
        Application.ProcessMessages;
        {$IFDEF IOS}
        ASwitch.DisposeOf;
        {$ELSE}
        ASwitch.Free;
        {$ENDIF}
      end;
    end;

    FButton.Position := FOwner.Position;
    AForm.InsertObject(0, FButton);
    Application.ProcessMessages;

    FImagesCached := True;

  finally
    FCreatingCache := False;
  end;

  Application.ProcessMessages;
  FOwner.RedrawAllRows;
end;


function TksControlBitmapCache.GetSegmentButtonImage(APosition: TKsSegmentButtonPosition;
  AWidth, AHeight: single; AText: string; ATintColor: TAlphaColor; ASelected: Boolean): TBitmap;
var
  AId: string;
begin
  Result := nil;
  if FButton.Parent = nil then
    Exit;
  AId := IntToStr(Ord(APosition))+'_'+
         FloatToStr(AWidth)+'_'+
         FloatToStr(AWidth)+'_'+
         AText+' '+
         BoolToStr(ASelected)+'_'+
         IntToStr(ATintColor);
  if FCachedButtons.IndexOf(AId) > -1 then
  begin
    Result := TBitmap(FCachedButtons.Objects[FCachedButtons.IndexOf(AId)]);
    Exit;
  end;
  if FButton.Parent = nil then
  begin
    if FOwner.Parent = nil then
      Exit;
    FButton.Position := FOwner.Position;
    FOwner.Parent.InsertObject(0, FButton);
    Application.ProcessMessages;
  end;
  case APosition of
    ksSegmentLeft: FButton.StyleLookup := 'segmentedbuttonleft';
    ksSegmentMiddle: FButton.StyleLookup := 'segmentedbuttonmiddle';
    ksSegmentRight: FButton.StyleLookup := 'segmentedbuttonright';
  end;
  FButton.StaysPressed := True;
  FButton.GroupName := 'cacheButton';
  FButton.Width := AWidth;
  FButton.Height := AHeight;
  FButton.Text := AText;
  FButton.IsPressed := ASelected;
  FButton.TintColor := ATintColor;
  Result := FButton.MakeScreenshot;

  if IsBlankBitmap(Result) then
  begin
    {$IFDEF IOS}
    Result.DisposeOf;
    {$ELSE}
    Result.Free;
    {$ENDIF}
    Result := nil;
    Exit;
  end;

  FCachedButtons.AddObject(AId, Result);
end;

function TksControlBitmapCache.GetSwitchImage(AChecked: Boolean): TBitmap;
begin
  case AChecked of
    True: Result := FSwitchOn;
    False: Result := FSwitchOff;
  end;
end;

end.
