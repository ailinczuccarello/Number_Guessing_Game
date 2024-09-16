#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
echo $SECRET_NUMBER
NUMBER_OF_GUESSES=0

GUESS_NUMBER(){
read GUESS
NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
then
  echo -e "That is not an integer, guess again:"
  GUESS_NUMBER
else 
  if [[ $GUESS -lt $SECRET_NUMBER ]] 
  then
    echo -e "It's higher than that, guess again:"
    GUESS_NUMBER
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo -e "It's lower than that, guess again:"
    GUESS_NUMBER
  fi
fi
}

echo Guess the secret number between 1 and 1000:
GUESS_NUMBER

if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi

if [[ -z $GAMES_PLAYED ]]
then
  INSERT_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played =1 WHERE username='$USERNAME'")
  INSERT_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
else
  INSERT_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED+1 WHERE username='$USERNAME'")
fi

echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
