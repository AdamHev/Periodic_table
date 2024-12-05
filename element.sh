#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

MAIN() {
  ELEMENT=$1
  # If not number go for the atomic_number else for the symbol and name
  if [[ $ELEMENT =~ ^[0-9]+$ ]]
  then
    QUERY="SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$ELEMENT"
  else
    QUERY="SELECT atomic_number, symbol, name FROM elements WHERE symbol ILIKE '$ELEMENT' OR name ILIKE '$ELEMENT'"
  fi
  # Elements id-s from elements table
  ELEMENTS=$($PSQL "$QUERY")

  if [[ -z $ELEMENTS ]]
  then
    echo "I could not find that element in the database."
  else
    # Parse the first query
    echo "$ELEMENTS" | while IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME
    do
      # Query for the details
      DETAILS=$($PSQL "SELECT types.type, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius
                 FROM properties
                 JOIN types ON properties.type_id = types.type_id
                 WHERE properties.atomic_number=$ATOMIC_NUMBER")
      # Parse the details getting the ones we need
      echo "$DETAILS" | while IFS="|" read -r TYPE MASS MELTING BOILING
      do
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
      done
    done
  fi
}

MAIN "$1"
