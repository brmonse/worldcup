#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != "year" ]]
then

# insert unique TEAMS into teams table
WINNER_TEAM="$($PSQL "SELECT * from teams WHERE name='$WINNER'")"
OPPO_TEAM="$($PSQL "SELECT * from teams WHERE name='$OPPONENT'")"
# if winner not in the db...
  if [[ -z $WINNER_TEAM ]]
  then
  # put it in the db
  INSERT_WINNER_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
    # check
    if [[ $INSERT_WINNER_RESULT = "INSERT 0 1" ]]
    then
    echo Winning team $WINNER inserted successfully to teams table
    else
    echo Winning team $WINNER insert failed
    fi
  else
    echo Winning team $WINNER already inserted table
  fi
# get winner team_id
WINNER_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"

# if oppo not in db...
  if [[ -z $OPPO_TEAM ]]
  then
  # put it in the db
    INSERT_OPPONENT_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
  # check
    if [[ $INSERT_OPPONENT_RESULT="INSERT 0 1" ]]
    then
      echo Opponent team $OPPONENT inserted successfully to teams table
    else
      echo Opponent team $OPPONENT insert failed
    fi
  else
  echo Opponent team $OPPONENT already inserted table
  fi

OPPONENT_TEAM_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
# add games
INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES('$YEAR','$ROUND','$WINNER_TEAM_ID','$OPPONENT_TEAM_ID','$WINNER_GOALS','$OPPONENT_GOALS')")"
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
  then
    echo Game added: year:$YEAR round:$ROUND winner_id:$WINNER_TEAM_ID oppo_id:$OPPONENT_TEAM_ID winner_goals:$WINNER_GOALS opponent_goals:$OPPONENT_GOALS
  else
    echo Game insert failed: Game added: year:$YEAR round:$ROUND winner_id:$WINNER_TEAM_ID oppo_id:$OPPONENT_TEAM_ID winner_goals:$WINNER_GOALS opponent_goals:$OPPONENT_GOALS
  fi
fi
done