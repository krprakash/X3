$ServiceName = "*mongo*"
Get-WmiObject win32_service | ?{$_.Name -like $ServiceName} | select Name, DisplayName, State, PathName
