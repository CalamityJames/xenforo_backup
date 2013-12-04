# XenForo backup script
Made because I hate doing this manually

## You will need
- SSH access
- Pigz or pbzip2 installed (if you want to use the faster, multi-core versions)
- An Amazon S3 account (and s3put installed) if you want to sync your SQL backups with AWS

## How to use
- Firstly, download the version of the script you require
- Save the backup script somewhere you'll remember. For example `/home/backups`
- You will need to fill out the config variables, such as the database username, password and name.
- Add a crontab entry to run every night at a time when your site is likely to be less busy. Something like this will do: `0       3       *       *       *       /home/backups/backup_script.sh` (this will run at 3am every night)
