#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

PRINT() {
  #get username
  echo "Enter your username:"
  read USERNAME

  #get username from db
  USER=$($PSQL "select u_id from users where name = '$USERNAME'")

  #if user present
  if [[ $USER ]]; then
    #get games played
    GAMES_PLAYED=$($PSQL "select count(u_id) from games where u_id = '$USER'")

    #get best game (guess)
    BEST_GUESS=$($PSQL "select min(guesses) from games where u_id = '$USER'")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  else
    #if u_name not present in db
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

    #insert to users table
    INSERTED_TO_USERS=$($PSQL "insert into users(name) values('$USERNAME')")
    #get user_id
    USER=$($PSQL "select u_id from users where name = '$USERNAME'")
    # echo $USER
  fi

  GAME
}

GAME() {
  #secret number
  SECRET_NUM=$((1 + $RANDOM % 1000))

  #count guesses
  TRIES=0

  #guess number
  GUESSED=0
  echo -e "\nGuess the secret number between 1 and 1000:"

  while [[ $GUESSED = 0 ]]; do
    read GUESS

    #if not a number
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    #if correct guess
    elif [[ $SECRET_NUM = $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET_NUM. Nice job!"
      #insert into db
      INSERTED_TO_GAMES=$($PSQL "insert into games(u_id, guesses) values($USER, $TRIES)")
      GUESSED=1
    #if greater
    elif [[ $SECRET_NUM -gt $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's higher than that, guess again:"
    #if smaller
    else
      TRIES=$(($TRIES + 1))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done
}

PRINT
