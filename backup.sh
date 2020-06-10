#!/bin/bash

# This script periodically runs a backup
# and uploads it to Amazon S3.
#
# Configuration is taken entirely from
# environment variables

#checking mandatory variables
[[ -z "$POSTGRES_HOST" ]] && { echo "Error: Please set POSTGRES_HOST env var"; exit 1; }
[[ -z "$POSTGRES_PORT" ]] && { echo "Error: Please set POSTGRES_PORT env var"; exit 1; }
[[ -z "$POSTGRES_DB" ]] && { echo "Error: Please set POSTGRES_DB env var"; exit 1; }
[[ -z "$POSTGRES_USER" ]] && { echo "Error: Please set POSTGRES_USER env var"; exit 1; }
[[ -z "$POSTGRES_PASSWORD" ]] && { echo "Error: Please set POSTGRES_PASSWORD env var"; exit 1; }
[[ -z "$S3_BUCKET" ]] && { echo "Error: Please set S3_BUCKET env var"; exit 1; }

# interval between backups in seconds
interval=${BACKUP_INTERVAL:=86400}

# pattern to create subdirectories from date elements,
# e. g. '%Y/%m/%d' or '%Y/%Y-%m-%d'
pathpattern=${PATH_DATEPATTERN:='%Y/%m'}

dbhost=$POSTGRES_HOST
dbport=$POSTGRES_PORT
dbname=$POSTGRES_DB
dbuser=$POSTGRES_USER
dbpass=$POSTGRES_PASSWORD
export PGPASSWORD=$dbpass
# Amazon S3 target bucket
bucket=$S3_BUCKET

if [ -z "$AWS_S3_ENDPOINT" ] ;then
    export AWS_S3_ENDPOINT=""
else
    export AWS_S3_ENDPOINT="--endpoint-url $AWS_S3_ENDPOINT"
fi

# initially wait a minute before first backup
sleep 60

count=1

while [ 1 ]
do
    # set date-dependent path element
    datepath=`date +"$pathpattern"`

    # determine file name
    datetime=`date +"%Y%m%d-%H%M"`
    filename_data="$dbname-$datetime.sql"

    echo "Writing backup No. $count for $dbhost:$dbport/$dbname to s3://$bucket/$datepath/$filename_data"
    pg_dump -Fc -h $dbhost -p $dbport -U $dbuser $dbname > $filename_data
    echo "Uploading to aws s3 $AWS_S3_ENDPOINT cp $filename_data s3://$bucket/$datepath/$filename_data"
    aws s3 $AWS_S3_ENDPOINT cp $filename_data s3://$bucket/$datepath/$filename_data

    echo "Backup No. $count finished"
    rm $filename_data

    # increment counter and for the time to pass by...
    count=`expr $count + 1`
    echo "Waiting $interval seconds for the next backup"
    sleep $interval
done

