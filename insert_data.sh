#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]] && [[ $OPPONENT != "opponent" ]]
  then

    #get winner team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER $OPPONENT'")

    #if not found
    if [[ -z $TEAM_ID ]] 
    then

      #insert name
      INSERT_WINNER_team_name=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      INSERT_OPPONENT_team_name=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      
      if [[ $INSERT_WINNER_team_name == "INSERT 0 1" ]] || [[ $INSERT_OPPONENT_team_name == "INSERT 0 1" ]]
      then

        echo Inserted into teams, $WINNER
        echo Inserted into teams, $OPPONENT
      
      fi

      # get new team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER $OPPONENT'") 
      
      #get winner_id
      GET_WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      
      #get opponent_id
      GET_OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      
      #Insert data
      INSERT_DATA=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES('$YEAR', '$ROUND', '$WINNER_GOALS', '$OPPONENT_GOALS', '$GET_WINNER_ID', '$GET_OPPONENT_ID')")
      
      if [[ $INSERT_DATA == "INSERT 0 1" ]]
      then

        echo Inserted into games, $YEAR $ROUND $WINNER_GOALS $OPPONENT_GOALS $GET_WINNER_ID $GET_OPPONENT_ID
      
      fi
    fi
  fi
done