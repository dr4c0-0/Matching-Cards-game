unit MemoryGame;

{

Coding a Game of Memory in Delphi – OOP Model
http://zarko-gajic.iz.hr/coding-a-game-of-memory-in-delphi-oop-model/

}


interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, System.Generics.Defaults, System.Generics.Collections;

type
  TPlayer = class
  private
    fName: string;
    fClaimedPairs: integer;
  public
    property Name : string read fName write fName;

    property ClaimedPairs : integer read fClaimedPairs;
  private
    constructor Create(const name : string);
  end;

  TMField = class
  private
    fValue: integer;
    fHost: TObject;
    fPlayer: TPlayer;
  public
    property Value : integer read fValue;
    property Host : TObject read fHost write fHost;
    property Player : TPlayer read fPlayer;
    constructor Create(const value : integer);
  end;

  TMemoryGameEvent = TNotifyEvent;
  TMemoryGamePlayerEvent = procedure(Sender : TObject; const player : TPlayer) of object;
  TMemoryGameFieldEvent = procedure(Sender : TObject; const mField : TMField) of object;
  TMemoryGameFieldPairEvent = procedure(Sender : TObject; const mField1, mField2 : TMField) of object;

  TMemoryGame = class
  private
    fPlayersCount: integer;
    fClaimedPairs : integer;
    fPairsCount: integer;
    fGameGridColumns : integer;
    fGameGridRows : integer;
    fFields: TObjectList<TMField>;
    fPlayers: TObjectList<TPlayer>;
    fOpenFirst: boolean;
    fOpenedField: TMField;
    fCurrentPlayer: TPlayer;
    fOnFieldsPaired: TMemoryGameFieldPairEvent;
    fOnFieldClaimed: TMemoryGameFieldEvent;
    fOnFieldOpened: TMemoryGameFieldEvent;
    fOnOpenField: TMemoryGameFieldEvent;
    fOnCloseField: TMemoryGameFieldEvent;
    fOnGameOver: TMemoryGamePlayerEvent;
    fOnNextPlayer: TMemoryGamePlayerEvent;
    fOnGameStart: TMemoryGamePlayerEvent;
    fOnPlayerCreated : TMemoryGamePlayerEvent;
    fOnGameCreated: TMemoryGameEvent;
  private
    property OpenFirst : boolean read fOpenFirst write fOpenFirst;
    property OpenedField : TMField read fOpenedField write fOpenedField;

    property ClaimedPairs : integer read fClaimedPairs;
    function AllPairsClaimed : boolean;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property GameGridColumns : integer read fGameGridColumns;
    property GameGridRows : integer read fGameGridRows;

    property PairsCount : integer read fPairsCount;
    property PlayersCount : integer read fPlayersCount;

    procedure NewGame(const numberOfPairs, numberOfPlayers: integer);

    procedure FieldHostAction(Sender : TObject);

    property Fields : TObjectList<TMField> read fFields;
    property Players : TObjectList<TPlayer> read fPlayers;
    property CurrentPlayer : TPlayer read fCurrentPlayer;

    property OnFieldClaimed : TMemoryGameFieldEvent read fOnFieldClaimed write fOnFieldClaimed;
    property OnFieldOpened : TMemoryGameFieldEvent read fOnFieldOpened write fOnFieldOpened;
    property OnOpenField : TMemoryGameFieldEvent read fOnOpenField write fOnOpenField;
    property OnCloseField : TMemoryGameFieldEvent read fOnCloseField write fOnCloseField;
    property OnFieldsPaired : TMemoryGameFieldPairEvent read fOnFieldsPaired write fOnFieldsPaired;
    property OnGameOver : TMemoryGamePlayerEvent read fOnGameOver write fOnGameOver;
    property OnNextPlayer : TMemoryGamePlayerEvent read fOnNextPlayer write fOnNextPlayer;
    property OnPlayerCreated : TMemoryGamePlayerEvent read fOnPlayerCreated write fOnPlayerCreated;
    property OnGameStart : TMemoryGamePlayerEvent read fOnGameStart write fOnGameStart;
    property OnGameCreated : TMemoryGameEvent read fOnGameCreated write fOnGameCreated;
  end;

implementation

{$region 'TMField' }
constructor TMField.Create(const value: integer);
begin
  fValue := value;
  fPlayer := nil;
end;
{$endregion 'TMField'}

{$region 'TMemoryGame' }
function TMemoryGame.AllPairsClaimed: boolean;
begin
  result := ClaimedPairs = PairsCount;
end;

constructor TMemoryGame.Create;
begin
  OpenFirst := true;

  fFields := TObjectList<TMField>.Create(true);
  fPlayers := TObjectList<TPlayer>.Create(true);
end;

destructor TMemoryGame.Destroy;
begin
  FreeAndNil(fFields);
  FreeAndNil(fPlayers);

  inherited;
end;

procedure TMemoryGame.NewGame(const numberOfPairs, numberOfPlayers: integer);
var
  i, rnd : integer;
  aField : TMField;
  newPlayer : TPlayer;

  procedure CalcGridSize;
  //look for ideal rectangle dimensions (square is ideal) to present fields
  var
    fieldCount : integer;
    i : integer;
  begin
    fieldCount := (2 * PairsCount);

    fGameGridColumns := 1;
    fGameGridRows := fieldCount;

    if Sqrt(fieldCount) = Trunc(Sqrt(fieldCount)) then
    begin
      fGameGridColumns := Trunc(Sqrt(fieldCount));
      fGameGridRows := Trunc(Sqrt(fieldCount));
      Exit;
    end;

    for i := Trunc(Sqrt(fieldCount)) downto 2 do
      if (fieldCount mod i) = 0 then
      begin
        fGameGridColumns := i;
        fGameGridRows := fieldCount div i;
        Exit;
      end;
  end; //GetGridSize

begin
  fPairsCount := numberOfPairs; if fPairsCount < 1 then fPairsCount := 1;
  fPlayersCount := numberOfPlayers; if fPlayersCount < 1 then fPlayersCount := 1;

  CalcGridSize();

  //players
  Players.Clear;
  for i := 1 to PlayersCount do
  begin
    newPlayer := TPlayer.Create('player ' + i.ToString());
    if Assigned(fOnPlayerCreated) then fOnPlayerCreated(self, newPlayer);
    Players.Add(newPlayer);
  end;
  fCurrentPlayer := Players.First;

  //fields
  Fields.Clear;
  for i := 0 to -1 + 2 * PairsCount do
  begin
    // value would be 1,1,2,2,3,3...
    aField := TMField.Create(1 + i DIV 2);

    Fields.Add(aField);
  end;

  //randomize field positions
  Randomize;
  Fields.Sort(TComparer<TMField>.Construct(
    function(const Left, Right : TMField) : integer
    begin
      result := -1 + Random(3);
    end
  ));

  fClaimedPairs := 0;
  OpenFirst := true;

  //let's start...
  if Assigned(fOnGameCreated) then fOnGameCreated(self);
  if Assigned(fOnGameStart) then fOnGameStart(self,CurrentPlayer);
end;

procedure TMemoryGame.FieldHostAction(Sender: TObject);
var
  actionOnField: TMField;
  winner, aPlayer : TPlayer;

  function FieldByHost(const host : TObject) : TMField;
  var
    mf : TMField;
  begin
    result := nil;
    for mf in Fields do
      if mf.Host = host then Exit(mf);
  end;
begin
  actionOnField := FieldByHost(sender);
  if actionOnField = nil then Exit;

  if actionOnField.Player = nil then //not claimed
  begin
    if OpenFirst then
    begin
      OpenedField := actionOnField;

      if Assigned(fOnOpenField) then fOnOpenField(self, actionOnField);

      OpenFirst := false;
    end
    else //open second
    begin
      if actionOnField = OpenedField then //cannot double open
      begin
        if Assigned(fOnFieldOpened) then fOnFieldOpened(self, actionOnField)
      end
      else
      begin
        if Assigned(fOnOpenField) then fOnOpenField(self, actionOnField);

        if OpenedField.Value = actionOnField.Value then //we have a match
        begin
          OpenedField.fPlayer := CurrentPlayer;
          actionOnField.fPlayer := CurrentPlayer;

          Inc(fClaimedPairs);
          CurrentPlayer.fClaimedPairs := 1 + CurrentPlayer.ClaimedPairs;

          if Assigned(fOnFieldsPaired) then fOnFieldsPaired(self, OpenedField, actionOnField);

          if AllPairsClaimed then
          begin
            winner := CurrentPlayer; //even if there are other players with the same number of claimed pairs
            for aPlayer in Players do
              if aPlayer.ClaimedPairs > winner.ClaimedPairs then winner := aPlayer;

            if Assigned(fOnGameOver) then fOnGameOver(self, winner);
          end;
        end
        else //no mach pair
        begin
          Sleep(500); //todo: promote interval to property
          if Assigned(fOnCloseField) then fOnCloseField(self, OpenedField);
          if Assigned(fOnCloseField) then fOnCloseField(self, actionOnField);

          if CurrentPlayer = Players.Last then
            fCurrentPlayer := Players.First
          else
            fCurrentPlayer := Players[1 + Players.IndexOf(CurrentPlayer)];

          if Assigned(fOnNextPlayer) then fOnNextPlayer(self, CurrentPlayer);
        end;

        OpenFirst := true;
      end;
    end;
  end
  else //already claimed
  begin
    if Assigned(fOnFieldClaimed) then fOnFieldClaimed(self, actionOnField);
  end;
end;

{$endregion}

{$region 'TPlayer' }

constructor TPlayer.Create(const name : string);
begin
  fName := name;
end;

{$endregion}

end.

