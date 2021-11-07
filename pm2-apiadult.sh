#!/bin/sh

npm run prestart

pm2 status | grep apiadult && pm2 delete apiadult
PORT=6023 pm2 start .  -i 0  --name "apiadult"  --output="/dev/null" --log-date-format="YYYY-MM-DD HH:mm Z"
pm2 save