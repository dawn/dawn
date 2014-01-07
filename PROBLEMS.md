# PROBLEMS

Things that aren't working correctly

1. /home/git/.ssh permissions are too tight preventing dawn from writing/reading it
  * **Limitations:** we cannot change the permissions as this would break sshd
  * **Possible Solution:** we can modify the file using sudo, however this would require exposing the user password
    > EG. ```echo <password> | sudo -I -u git <command>```
  * **Affected:** dawn key:add, dawn key:delete, git push dawn