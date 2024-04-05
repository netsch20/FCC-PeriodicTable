#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else 
  # check argument type to set search string
  if [[ $1 =~ [0-9]+ ]]
  then 
    ELEMENT_SEARCH="WHERE atomic_number=$1"
  elif [[ $1 =~ ^..?$ ]] # is one or two letters
  then
    ELEMENT_SEARCH="WHERE LOWER(symbol)=LOWER('$1')"
  elif [[ $1 =~ [a-z]{3,}$ ]] # is three or more letter word
  then
    ELEMENT_SEARCH="WHERE LOWER(name)=LOWER('$1')"
  fi

  # get atomic_number
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements $ELEMENT_SEARCH")

  # if not found, inform and finish
  if [[ -z $ATOMIC_NUMBER ]]
  then
   echo I could not find that element in the database.
  else
    # get symbol, name, type, atomic_mass, melting point, and boiling point
    ELEMENT_INFO=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) 
    INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")

    echo "$ELEMENT_INFO" | while IFS="|" read TYPEID ATOMNO SYMBOL NAME ATOMIC_MASS MELT_POINT BOIL_POINT TYPE
    do
      echo  "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
    done
  fi

fi