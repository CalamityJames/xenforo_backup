#!/bin/sh

# XenForo backup script
# Made by James because I hate doing this manually
# Updated 16th July 2012 to replace gzip with pigz for multi-core support

#### CONFIG - YOU MUST EDIT THIS ####

# set database connection info
db_username="username"
db_password="password"
db_name="database"

# set path to backups and website directory without trailing slashes:

# your backup location
backup_path="/path/to/backup/directory"

# your web root location
web_dir="/path/to/website/directory"

# set amazon s3 bucket name
bucket_name="bucket/directory"

#### END CONFIG - YOU PROBABLY DONT NEED TO EDIT BELOW HERE ####


# set filenames
filename_sql="backup-db-"`eval date +%Y%m%d`".sql"
filename_sql_gz="backup-db-"`eval date +%Y%m%d`".gz"
filename_data="backup-data-folder.tar"
filename_data_gz="backup-data-folder.tar.gz"

# dump the database
mysqldump -u$db_username -p$db_password $db_name > $backup_path/$filename_sql

# gzip the database at max compression to save space
# update: using pigz as it is a crap-ton faster!
pigz -9 $backup_path/$filename_sql

# create a tarball of the web folder
tar -cf $backup_path/$filename_data $web_dir/*

# move the old one to _old
mv $backup_path/$filename_data_gz $backup_path/old_$filename_data_gz

# gzip the website directory
pigz -9 $backup_path/$filename_data

# upload to Amazon S3...
s3put $bucket_name $backup_path/$filename_sql_gz

# write to the backup log
echo "Backup for `eval date +%d`/`eval date +%m`/`eval date +%Y` complete" >> $backup_path/backup.log