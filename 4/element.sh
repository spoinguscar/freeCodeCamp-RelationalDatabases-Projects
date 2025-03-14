#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [[ $1 ]]; then
  # Try querying by atomic number first (it's a number)
  ATOMIC_NUMBER_IN=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$1" 2>&1 | sed 's/^[ \t]*//;s/[ \t]*$//')
  
  if [[ ! $ATOMIC_NUMBER_IN =~ ^ERROR && ! -z $ATOMIC_NUMBER_IN ]]; then
    # If the atomic number is valid, extract details
    IFS='|' read -r -a arr <<< "$ATOMIC_NUMBER_IN"
      ATOMIC_NUMBER=${arr[1]}
      ELEMENT_NAME=${arr[3]}
      ELEMENT_SYMBOL=${arr[2]}
      ELEMENT_TYPE=${arr[7]}
      ELEMENT_MASS=${arr[4]}
      ELEMENT_MELTING_POINT=${arr[5]}
      ELEMENT_BOILING_POINT=${arr[6]}
  else
    # Try querying by symbol
    SYMBOL_IN=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol='$1'" 2>&1 | sed 's/^[ \t]*//;s/[ \t]*$//')
    
    if [[ ! $SYMBOL_IN =~ ^ERROR && ! -z $SYMBOL_IN ]]; then
      # If the symbol is valid, extract details
      IFS='|' read -r -a arr <<< "$SYMBOL_IN"
      ATOMIC_NUMBER=${arr[1]}
      ELEMENT_NAME=${arr[3]}
      ELEMENT_SYMBOL=${arr[2]}
      ELEMENT_TYPE=${arr[7]}
      ELEMENT_MASS=${arr[4]}
      ELEMENT_MELTING_POINT=${arr[5]}
      ELEMENT_BOILING_POINT=${arr[6]}
    else
      # Try querying by name
      NAME_IN=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE name='$1'" 2>&1 | sed 's/^[ \t]*//;s/[ \t]*$//')
      
      if [[ ! $NAME_IN =~ ^ERROR && ! -z $NAME_IN ]]; then
        # If the name is valid, extract details
        IFS='|' read -r -a arr <<< "$NAME_IN"
        ATOMIC_NUMBER=${arr[1]}
        ELEMENT_NAME=${arr[3]}
        ELEMENT_SYMBOL=${arr[2]}
        ELEMENT_TYPE=${arr[7]}
        ELEMENT_MASS=${arr[4]}
        ELEMENT_MELTING_POINT=${arr[5]}
        ELEMENT_BOILING_POINT=${arr[6]}
      else
        echo "I could not find that element in the database."
        # Do not give arguments to exit
        exit
      fi
    fi
  fi
  
  # Format
  echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ELEMENT_MASS amu. $ELEMENT_NAME has a melting point of $ELEMENT_MELTING_POINT celsius and a boiling point of $ELEMENT_BOILING_POINT celsius."
else
  echo "Please provide an element as an argument."
fi
