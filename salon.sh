#!/bin/bash
# Script to manage salon database

## Definitions
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


MAIN_MENU() {
  ## display message passed to function
  echo -e "$1"

  ## services
  # present service options
  echo -e "\nPlease choose a service from the list:"
  echo "$($PSQL "SELECT * FROM services")" | while read S_ID BAR S_NAME
  do
    echo "$S_ID) $S_NAME"
  done
  # read choice
  read SERVICE_ID_SELECTED
  # if not number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # go to start
    MAIN_MENU "\nSorry, please enter a number."
    return
  fi
  # get service from table
  DESIRED_SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")"
  # if service not exist
  if [[ -z $DESIRED_SERVICE_NAME ]]
  then
    # go to start
    MAIN_MENU "\nSorry, that is not in the range of available services."
    return
  fi

  ## identify customer
  # get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # try to get customer id
  CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
  # if no id
  echo $CUSTOMER_ID
  if [[ -z $CUSTOMER_ID ]]
  then
    # register new customer
    echo -e "\nYou seem to be a new customer."
    echo "What's your name?"
    # get name
    read CUSTOMER_NAME
    # insert new customer
    RESPONSE="$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")"
    # get new customer id
    CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
  fi
  # get customer name
  CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")"

  ## make appointment
  # ask for appointment time
  TRIMMED_SERVICE="$(echo $DESIRED_SERVICE_NAME | sed 's/^ +| +$//g')"
  TRIMMED_CUSTOMER="$(echo $CUSTOMER_NAME | sed 's/^ +| +$//g')"
  echo -e "\nWhat time would you like your $TRIMMED_SERVICE, $TRIMMED_CUSTOMER?"
  read SERVICE_TIME
  # insert new appointment
  RESPONSE="$($PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")"
  # report to the customer
  echo -e "\nI have put you down for a $TRIMMED_SERVICE at $SERVICE_TIME, $TRIMMED_CUSTOMER."
}

## Start running the script
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU