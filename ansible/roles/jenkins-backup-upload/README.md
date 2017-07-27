### Jenkins backup upload

This role uploads backup taken by [ThinBackup plugin](https://plugins.jenkins.io/thinBackup)


### PreRequisites

* Jenkins should have [ThinBackup plugin](https://plugins.jenkins.io/thinBackup) installed
* Configure [ThinBackup plugin settings](https://ci.server/jenkins/thinBackup/backupsettings)
	* Set the backup dir as `/jenkins-backup`
	* Ensure backup is minimal by excluding job artifacts etc
	* Ensure there is a periodic backup which runs before upload. Example if upload runs `@midnight`, schedule backup at 11PM using cron `0 23 * * *`