unit Main;                       //Jonathan Masengana

// Matching cards game instructions:
//1. Players should input their usernames and age (players need to be older than 5 yrs of age).
//2.If player need to reset they have to click the restart button and re-enter information.
//3.After input being put users should click on enter details and click the next button.
//4.Users must select the player number and it will automatically take you to the game.
//5. Once you in the game the timer starts and the users should input their player numbers.
//6.Users must input number of pairs needed.
//7. Click on new game and BEGIN!
//Jonathan Masengana Phase 2

interface

uses
  MemoryGame,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Mask, Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.Samples.Spin,
  Vcl.Imaging.jpeg;

type
  TMainForm = class(TForm)
    pgcGame: TPageControl;
    tbsWelcome: TTabSheet;
    tbsSelection: TTabSheet;
    tbsGame: TTabSheet;
    pnlGame: TPanel;
    pnlNewGame: TPanel;
    btnNewGame: TButton;
    ledPairs: TLabeledEdit;
    ledPlayers: TLabeledEdit;
    pnlCurrentGame: TPanel;
    lblCurrentPlayerName: TLabel;
    lblCurrentPlayerPairs: TLabel;
    txtCurrentPlayer: TStaticText;
    txtStatistics: TStaticText;
    lbPlayerStatistics: TListBox;
    pnlGameField: TPanel;
    gameGrid: TGridPanel;
    imgLogin: TImage;
    lblHeading: TLabel;
    lblUsername: TLabel;
    lblAge: TLabel;
    edtUsername: TEdit;
    sedAge: TSpinEdit;
    btnEnterDetails: TButton;
    BitBtn2: TBitBtn;
    btnNext: TButton;
    tmr1: TTimer;
    BitBtn1: TBitBtn;
    imgSelect: TImage;
    RadioGroup1: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Image2: TImage;
    memInfo: TMemo;
    lblTime1: TLabel;
    BitBtn3: TBitBtn;
    btnCloseHelp: TButton;
    pnlHelp: TPanel;
    memHelp: TMemo;
    procedure btnNewGameClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnEnterDetailsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure btnCloseHelpClick(Sender: TObject);
  private
    fMGame : TMemoryGame;
    function GetMGame: TMemoryGame;
    property MGame : TMemoryGame read GetMGame;

    procedure FieldClaimed(Sender : TObject; const mField : TMField);
    procedure OpenField(Sender : TObject; const mField : TMField);
    procedure CloseField(Sender : TObject; const mField : TMField);
    procedure FieldsPaired(Sender : TObject; const mField1, mField2 : TMField);
    procedure NextPlayer(Sender : TObject; const player : TPlayer);
    procedure GameOver(Sender : TObject; const player : TPlayer);
    procedure GameCreated(Sender : TObject);

    procedure UpdatePlayerStatistics;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
edtUsername.Clear;
sedAge.Clear;
memInfo.Clear;  //once reset button gets clicked it clears up inputs
end;

procedure TMainForm.BitBtn3Click(Sender: TObject);
begin
pnlHelp.Visible:=true;
memHelp.Visible:=true;
btnCloseHelp.visible:=true;
end;

procedure TMainForm.btnCloseHelpClick(Sender: TObject);
begin
pnlHelp.Visible:=false;
memHelp.Visible:=false;
btnCloseHelp.visible:=false;
end;

procedure TMainForm.btnEnterDetailsClick(Sender: TObject);
var sName : string ;
    iAge : integer ;
begin
 sName := edtUsername.Text ;
 iAge := sedAge.Value ;
 if edtUsername.Text='' then
 showmessage('Please enter username');

 if iAge = 0 then
 showmessage('Please enter age');
 if iAge <= 5 then
showmessage('You are not eligible to play')
 else
 btnNext.Enabled := true ;
  memInfo.lines.Add('Currently logged in:'+(sName));
  memInfo.Visible:=true;
  memInfo.Enabled:=false;   //displays users name and takes user to next tabsheet
end;

procedure TMainForm.btnNewGameClick(Sender: TObject);
var
  newGamePairs, newGamePlayers : integer;
begin
  newGamePairs := StrToInt(ledPairs.Text);
  newGamePlayers := StrToInt(ledPlayers.Text);;

  MGame.NewGame(newGamePairs, newGamePlayers);                   //inputs button under pairs and players alteres with the game ui
end;

procedure TMainForm.btnNextClick(Sender: TObject);
var
iAge:integer;
begin
pgcGame.ActivePageIndex := 1 ;
tbsWelcome.tabVisible := false ;
tbsSelection.tabVisible := true ; //after validation it takes user to next tabsheet

end;

procedure TMainForm.CloseField(Sender: TObject; const mField: TMField);
begin
  TButton(mField.Host).Caption := '0_0';  //displays question mark when cards dont match
end;

procedure TMainForm.FieldClaimed(Sender: TObject; const mField: TMField);
begin
  TButton(mField.Host).AlignWithMargins := false;
  TButton(mField.Host).Refresh;
  Sleep(200);
  TButton(mField.Host).AlignWithMargins := true;
  TButton(mField.Host).Refresh;
end;


procedure TMainForm.FieldsPaired(Sender: TObject; const mField1, mField2: TMField);
begin
  TButton(mField1.Host).Font.Size := 8;
  TButton(mField1.Host).Caption := Format('- %s -', [mField1.Player.Name]);
  TButton(mField2.Host).Font.Size := 8;
  TButton(mField2.Host).Caption := Format('- %s -', [mField2.Player.Name]);

  TButton(mField1.Host).Margins.SetBounds(8,8,8,8);
  TButton(mField2.Host).Margins.SetBounds(8,8,8,8);

  TButton(mField1.Host).Font.Style := [];
  TButton(mField2.Host).Font.Style := [];

  lblCurrentPlayerPairs.Caption := 'Pairs: ' + mGame.CurrentPlayer.ClaimedPairs.ToString;

  UpdatePlayerStatistics;  //replaces question mark on all cards with the player number and display on the listbox
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
tbsSelection.tabVisible := false ;
tbsGame.tabVisible := false ;  //hides other tabsheets on the game once application is run
edtUsername.ShowHint:=true;
sedAge.ShowHint:=true;
sedAge.Hint:='Please enter your age *YOU MUST BE OLDER THAN 5!';
edtUsername.Hint:='Please enter your username';
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  gameGrid.Caption := '';


  btnNewGame.Click; //once the application is run the grid is empty or set to default
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  fMGame.Free;
end;

procedure TMainForm.GameCreated(Sender: TObject);
var
  i : integer;
  aButton : TButton;
begin
  UpdatePlayerStatistics;

  begin //prepares GridPanel UI
    gameGrid.RowCollection.BeginUpdate;
    gameGrid.ColumnCollection.BeginUpdate;

    for i := 0 to -1 + gameGrid.ControlCount do
      gameGrid.Controls[0].Free;

    gameGrid.RowCollection.Clear;
    gameGrid.ColumnCollection.Clear;

    for i := 1 to MGame.GameGridColumns do
      with gameGrid.RowCollection.Add do
      begin
        SizeStyle := ssPercent;
        Value := 100 / MGame.GameGridColumns;
      end;

    for i := 1 to MGame.GameGridRows do
      with gameGrid.ColumnCollection.Add do
      begin
        SizeStyle := ssPercent;
        Value := 100 / MGame.GameGridRows;
      end;

    //create playable hosts for fields
    for i := 0 to -1 + MGame.Fields.Count do
    begin
      aButton := TButton.Create(self);
      aButton.Parent := gameGrid;
      aButton.Visible := true;
      aButton.Font.Style := [fsBold];
      aButton.Font.Size := 20;
      aButton.Caption := '0_0'; //IntToStr(MGame.Fields[i].Value);
      aButton.Align := alClient;
      aButton.AlignWithMargins := true;
       aButton.Brush.color:=(clSkyblue);


      MGame.Fields[i].Host := aButton;

      aButton.OnClick := MGame.FieldHostAction;
    end;

    gameGrid.RowCollection.EndUpdate;
    gameGrid.ColumnCollection.EndUpdate;
  end; //prepares the grid panel once the application is run
end;

procedure TMainForm.GameOver(Sender: TObject; const player: TPlayer);
begin
  MessageDlg(Format('We have a winner: %s', [player.Name]), mtInformation, [mbOK], -1); //displays the players number and shows the winner if player wins the game
end;

function TMainForm.GetMGame: TMemoryGame;
begin
  if fMGame = nil then
  begin
    fMGame := TMemoryGame.Create;

    fMGame.OnOpenField := OpenField;
    fMGame.OnFieldClaimed := FieldClaimed;
    fMGame.OnFieldOpened := FieldClaimed;
    fMGame.OnCloseField := CloseField;
    fMGame.OnFieldsPaired := FieldsPaired;
    fMGame.OnNextPlayer := NextPlayer;
    fMGame.OnGameStart := NextPlayer;
    fMGame.OnGameOver := GameOver;
    fMGame.OnGameCreated := GameCreated; //functions oncreate of the form creates all the components

  end;
  result := fMGame;
end;

procedure TMainForm.Label1Click(Sender: TObject);
begin
showmessage('Good Luck!!!!');
pgcGame.ActivePageIndex := 2 ;
tbsWelcome.tabVisible := false ;
tbsSelection.tabVisible := false ;
tbsGame.TabVisible:=true;        //displays a goodluck message and takes the user to the game
end;

procedure TMainForm.Label2Click(Sender: TObject);
begin
showmessage('Good Luck!!!!');
pgcGame.ActivePageIndex := 2 ;
tbsWelcome.tabVisible := false ;
tbsSelection.tabVisible := false ;
tbsGame.TabVisible:=true;  //displays a goodluck message and takes the user to the game
end;

procedure TMainForm.NextPlayer(Sender: TObject; const player: TPlayer);
begin
  txtCurrentPlayer.Font.Style := [fsBold];
  txtCurrentPlayer.Refresh;
  Sleep(100);
  txtCurrentPlayer.Font.Style := [fsBold];
  txtCurrentPlayer.Refresh;                  //changes the properties of the cards name of the player


  lblCurrentPlayerName.Caption := player.Name;
  lblCurrentPlayerPairs.Caption := 'Pairs: ' + player.ClaimedPairs.ToString;

  Caption := Format('Matching cards game. Current player: %s', [player.Name]); //shows the players number and the number of pairs the player has matched
end;

procedure TMainForm.OpenField(Sender: TObject; const mField: TMField);
begin
  TButton(mField.Host).Caption := mField.Value.ToString();  //displays the players number on the caption of the form once the new game button is pressed
end;

procedure TMainForm.RadioGroup1Click(Sender: TObject);
begin
showmessage('Good Luck!!!!');
pgcGame.ActivePageIndex := 2 ;
tbsWelcome.tabVisible := false ;
tbsSelection.tabVisible := false ;
tbsGame.TabVisible:=true;
tmr1.Enabled:=true;         //displays a message and takes the player to the next tabsheet to the game
end;

procedure TMainForm.tmr1Timer(Sender: TObject);
begin
lblTime1.Caption:=inttostr(strtoint(lblTime1.caption)+1);//timer to count till infinity
  if lblTime1.Caption='360' then
begin
 lblTime1.Caption:='0';
 showmessage('Time is up click new game');      //shows a message once the timer reaches its limit
end ;


end;

procedure TMainForm.UpdatePlayerStatistics;
var
  player : TPlayer;
begin
  lbPlayerStatistics.Items.BeginUpdate;
  try
    lbPlayerStatistics.Clear;

    for player in MGame.Players do
      lbPlayerStatistics.Items.Add(Format('%s: %d', [player.Name, player.ClaimedPairs]));
  finally
    lbPlayerStatistics.Items.EndUpdate;  //adds the players name and number of pairs on the listbox once the player has matched the cards
  end;
end;

end.
