#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME() {
  # Input argument legend
  # $1: NUMBER
  # $2: BEST_GAME
  # $3: USER_ID

  echo "Guess the secret number between 1 and 1000:"
  GUESS=-1
  GUESS_COUNT=0
  while [ true ]
  do
    read GUESS
    # Optionally start with a negative sign
    # Take in at least one digit
    if [[ ! "$GUESS" =~ ^-?[0-9]+$ ]]
    then
        echo "That is not an integer, guess again:"
    elif [[ $GUESS -lt $1 ]]
    then
      # Guess lesser than number
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $1 ]]
    then
      # Guess greater than number
      echo "It's lower than that, guess again:"
    else
      # Guess correct
      ((GUESS_COUNT++))
      break
    fi
    ((GUESS_COUNT++))
  done

  echo "You guessed it in $GUESS_COUNT tries. The secret number was $1. Nice job!"

  # Check for best game and update
  if [[ $2 == -1 || $2 > $GUESS_COUNT ]]
  then
    UPDATE_BEST=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT, games_played=games_played+1 WHERE user_id=$3")
  else
    UPDATE_BEST=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE user_id=$3")
  fi
}

NUMBER=$(( RANDOM % 1000 + 1 ))
echo $NUMBER

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
  IFS='|' read -r USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  BEST_GAME=-1
else
  IFS='|' read -r USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi



GAME $NUMBER $BEST_GAME $USER_ID

