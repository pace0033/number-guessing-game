#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

# check if username is in DB
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# add user if doesn't exist
if [[ -z $USER_ID ]]
then
  INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT guess_count FROM games WHERE user_id = $USER_ID ORDER BY guess_count LIMIT 1")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# prompt for the first guess
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))

# loop until guess is the same as random number
while [[ $GUESS != $SECRET_NUMBER ]]
do
  # check if guess is an integer
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    # increment guess count
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))

    # determine if number was higher or lower
    if [[ $SECRET_NUMBER -gt $GUESS ]]
    then
      echo -e "\nIt's higher than that, guess again:"
    else
      echo -e "\nIt's lower than that, guess again:"
    fi
    read GUESS
  else
    echo "That is not an integer, guess again:"
    read GUESS
  fi
done

# insert game stats into DB
GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guess_count) VALUES($USER_ID, $NUMBER_OF_GUESSES)")

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
