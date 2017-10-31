#!/bin/bash

# ┌────────── minute (0 - 59)
# │ ┌──────── hour (0 - 23)
# │ │ ┌────── day of month (1 - 31)
# │ │ │ ┌──── month (1 - 12)
# │ │ │ │ ┌── day of week (0 - 6 => Sunday - Saturday, or
# │ │ │ │ │                1 - 7 => Monday - Sunday)
# ↓ ↓ ↓ ↓ ↓
# * * * * * command to be executed

# get current crontab
crontab -l > cron.tmp

# work hours
MORNING_TIME="0 06"
NIGHT_TIME="0 18"

# check if already registered
MAPIC_JOB=$(cat cron.tmp)

# add cronjobs
if [[ -z $MAPIC_JOB ]]; then

    echo "#"                                                                                                >> cron.tmp
    echo "# mapic schedule crontab"                                                                         >> cron.tmp
    echo "# monday"                                                                                         >> cron.tmp
    echo "$MORNING_TIME * * 1 sudo /usr/local/bin/mapic schedule day   >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "$NIGHT_TIME * * 1 sudo /usr/local/bin/mapic schedule night >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "#"                                                                                                >> cron.tmp
    echo "# tuesday"                                                                                        >> cron.tmp
    echo "$MORNING_TIME * * 2 sudo /usr/local/bin/mapic schedule day   >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "$NIGHT_TIME * * 2 sudo /usr/local/bin/mapic schedule night >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "#"                                                                                                >> cron.tmp
    echo "# wednesday"                                                                                      >> cron.tmp
    echo "$MORNING_TIME * * 3 sudo /usr/local/bin/mapic schedule day   >> /var/log/mapic/cronjob.schedule.log 2>&1 " >> cron.tmp
    echo "$NIGHT_TIME * * 3 sudo /usr/local/bin/mapic schedule night >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "#"                                                                                                >> cron.tmp
    echo "# thursday"                                                                                       >> cron.tmp
    echo "$MORNING_TIME * * 4 sudo /usr/local/bin/mapic schedule day   >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "$NIGHT_TIME * * 4 sudo /usr/local/bin/mapic schedule night >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "#"                                                                                                >> cron.tmp
    echo "# friday"                                                                                         >> cron.tmp
    echo "$MORNING_TIME * * 5 sudo /usr/local/bin/mapic schedule day   >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "$NIGHT_TIME * * 5 sudo /usr/local/bin/mapic schedule night >> /var/log/mapic/cronjob.schedule.log 2>&1"  >> cron.tmp
    echo "#"                                                                                                >> cron.tmp
    echo "# night mode until monday again"                                                                  >> cron.tmp

    # register cronjob
    crontab cron.tmp

    # cleanup
    rm cron.tmp

    echo "Mapic Scheduling Cron jobs added"

else
    echo "Mapic Scheduling Cron job already registered!"
    echo ""
    crontab -l
fi
