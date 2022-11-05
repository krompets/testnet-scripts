# testnet-scripts
Helpful scripts for testnets

## This script is used to update sui automatically. Run this script in crone to check updates and update sui. This will only work if sui installed with official documentation
### CRON EXAMPLE:
```
cat /etc/cron.d/sui-updater
0 * * * *  root /root/up_sui.sh >> /var/log/sui_updater.log  2>&1
```
