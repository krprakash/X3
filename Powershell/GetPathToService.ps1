Get-WmiObject win32_service | ?{$_.Name -like '*mongo*'} | Select Name, DisplayName, State, PathName
