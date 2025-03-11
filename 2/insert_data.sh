#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate all tables before insertion
TRNCTE=$($PSQL "TRUNCATE TABLE games, teams")
echo $TRNCTE


cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # See if teams are present in the database already and insert them if not
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $WINNER_ID ]]
    then
      # Insert (Winner) Team
      INSERT_WINNER_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    fi
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert (Opponent) Team
      INSERT_OPPONENT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_TEAM == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    fi

    # Insert items into the games table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAME=$($PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals, round) VALUES($YEAR, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND')")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "Inserted into games $YEAR $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS $ROUND"
    fi
  fi
done