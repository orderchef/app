#!/bin/sh

# To be placed under /root/repair_mongodb
# mongodb directory must be /var/lib/mongodb

echo Started db repair at $(date +%s) >> /var/orderchef/server/server/app.log

rm -f /var/lib/mongodb/mongod.lock
sudo -u mongodb -H sh -c "mongod --dbpath /var/lib/mongodb --repair" >> /var/orderchef/server/server/app.log
rm -f /var/lib/mongodb/mongod.lock

echo Starting mongodb >> /var/orderchef/server/server/app.log

/etc/init.d/mongod start