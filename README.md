# AWS Lambda PowerShell Example

A simple Lambda function written in PowerShell to validate if `New-PSSession` can be leveraged from an AWS Lambda.

The objective of this repository was to determine if it was possible to use `New-PSSession` from an AWS Lambda. This would allow for modification of services like Office365 using remote sessions from AWS without requiring an ECS/EC2 container. Without a custom lambda runtime (or some way of enabling WSMan), it would be difficult to do this with a vanilla lambda execution environment. The error encountered during runtime is included below:

```bash
This parameter set requires WSMan, and no supported WSMan client library was found. WSMan is either not installed or unavailable for this system
```

These errors lead to the following github issues for PowerShell: [PowerShell/5561](https://github.com/PowerShell/PowerShell/issues/5561) & [PowerShell/11159](https://github.com/PowerShell/PowerShell/issues/11159).

The lambda function can be published by `Publish-AWSPowerShellLambda -ScriptPath .\RemoteSession.ps1 -Name RemoteSession -Region us-east-1`.
