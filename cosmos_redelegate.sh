#!/bin/bash
source /root/.bash_profile

# HOW TO USE:
#    1. Fill out variables
#    2. Create cron or run script manually
#    3. Script should have +x access (chmod +x cosmos_redelegate.sh)
# CRON EXAMPLE: */5 * * * *  root /root/cosmos_redelegate.sh >> /var/log/redelegate.log  2>&1


# FILL OUT VARIABLES BELOW ACCORDING TO YOUR DATA
WALLET_NAME=""                      # "wallet"
WALLET_ADDRESS=""                   # "cosmosxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
VALOPER=""                          # "cosmosvaloperxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
KEYRING_PHRASE=""                   # "password"
EXECUTABLE=""                       # "/usr/local/bin/cosmos"
CURRENCY="uknow"                    # "uknow"
FEES=""                             # "1000"
CHAIN_ID=""                         # "testnet-chain"
MIN_DELEGATION=500000

# Get all rewards
echo "WITHDRAW REWARDS"
echo ${KEYRING_PHRASE} | ${EXECUTABLE} tx distribution withdraw-all-rewards \
                         --from ${WALLET_NAME} \
                         --chain-id ${CHAIN_ID} \
                         --fees ${FEES}${CURRENCY} \
                         --yes
sleep 5
echo ${KEYRING_PHRASE} | ${EXECUTABLE} tx distribution withdraw-rewards ${VALOPER} \
                         --chain-id ${CHAIN_ID} \
                         --from ${WALLET_NAME}  \
                         --commission \
                         --fees ${FEES}${CURRENCY} \
                         --yes
sleep 5

# Check balance
BALANCE=$(${EXECUTABLE} q bank balances ${WALLET_ADDRESS} | grep amount|grep -oP '"\K[^"\047]+(?=["\047])')
echo "BALANCE=${BALANCE}"
AMOUNT=$( expr $BALANCE - 100 )
echo $AMOUNT

if [ "$AMOUNT" -gt "$MIN_DELEGATION" ]; then
    echo "DELEGATE FROM ${WALLET_NAME}"
    echo ${KEYRING_PHRASE} | ${EXECUTABLE} tx staking delegate ${VALOPER} ${AMOUNT}${CURRENCY} \
                             --from ${WALLET_NAME} \
                             --chain-id ${CHAIN_ID} \
                             --fees ${FEES}${CURRENCY} \
                             --yes
fi
