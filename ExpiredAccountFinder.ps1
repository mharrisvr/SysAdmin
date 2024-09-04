# Purpose is to find accounts with expired passwords who are still logging in with them
# Has issue with searching by other than -ne 'True' for some reason

Get-Aduser -Filter "PasswordExpired -ne 'True'" -properties Name, PasswordlastSet, PasswordExpired, lastlogondate | Select Name, PasswordLastSet, PasswordExpired, Lastlogondate | 
          Sort-Object -Property @{Expression = "PasswordExpired"; Descending = $true}, 
                                @{Expression = "LastLogonDate"; Descending = $true} | 
                                Export-CSV C:\users\username\expiredusers.csv -NoTypeInformation
