#!/bin/bash

# XenForo backup script
# Made by James because I hate doing this manually

#### CONFIG - YOU MUST EDIT THIS ####

# set database connection info
db_username="username"
db_password="password"
db_name="database"

# set compression method (pigz, pbzip2 or standard gzip)
compression_method="pigz"

# set path to backups and website directory without trailing slashes:

# your backup location
backup_path="/path/to/backup/directory"

# your web root location
web_dir="/path/to/website/directory"

# set amazon S3 bucket and directory (leave blank to disable AWS uploading)
bucket_name=""

#### END CONFIG - YOU PROBABLY DONT NEED TO EDIT BELOW HERE ####


# set filenames
if [ "$compression_method" == "pbzip2" ]; then
	extension="bz2"
else
	extension="gz"
fi

filename_sql="backup-db-$(eval date +%Y%m%d).sql"
filename_sql_gz="backup-db-$(eval date +%Y%m%d).$extension"
filename_data="backup-data-folder.tar"
filename_data_gz="backup-data-folder.tar.$extension"

# dump the database
mysqldump -u$db_username -p$db_password $db_name > "$backup_path/$filename_sql"

# compress the database
$compression_method -9 -f "$backup_path/$filename_sql"

# create a tarball of the web folder
tar -cf "$backup_path/$filename_data" "$web_dir/"

# move the old one to _old
mv "$backup_path/$filename_data_gz" "$backup_path/old_$filename_data_gz"

# compress the website directory
$compression_method -9 -f "$backup_path/$filename_data"

# has user set a bucket name?
if [ -n "$bucket_name" ]; then
	# upload to Amazon S3...
	s3put $bucket_name "$backup_path/$filename_sql_gz"
fi

# write to the backup log
echo "Backup for $(eval date +%d)/$(eval date +%m)/$(eval date +%Y) complete" >> $backup_path/backup.log