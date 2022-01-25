#Set-StrictMode -Version Latest
#####################################################
# Expand-TokenString
#####################################################
<#PSScriptInfo

.VERSION 0.1

.GUID bfd55243-60dd-4394-a80e-835718187e1f

.AUTHOR David Walker, Sitecore Dave, Radical Dave

.COMPANYNAME David Walker, Sitecore Dave, Radical Dave

.COPYRIGHT David Walker, Sitecore Dave, Radical Dave

.TAGS powershell token regex

.LICENSEURI https://github.com/Radical-Dave/Expand-TokenString/blob/main/LICENSE

.PROJECTURI https://github.com/Radical-Dave/Expand-TokenString

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

#>

<#

.DESCRIPTION
 PowerShell Script to expand tokens in file/folder/strings using RegEx, EnvVar EnvironmentVariables, .env files and .with $(envVar)

.PARAMETER data
String to replace tokens in

.PARAMETER values
Tokens for replacements - default EnvironmentVariable

.PARAMETER regex
Regex pattern for finding tokens - default to powershell format: $(name)
#>
[OutputType('System.String')]
[CmdletBinding(SupportsShouldProcess)]
Param(
	[Parameter(Mandatory=$false)][string]$data,
	[Parameter(Mandatory=$false)][hashtable]$tokens,
	[Parameter(Mandatory=$false)][string]$regex = '(\$\()([a-zA-Z0-9\.\-_]*)(\))'
)
process {
	if (!$data) { return $data }
	if (!$tokens) { $tokens = @{} }
	#if ($data.GetType() -ne 'Array') {Write-Verbose "wow:$($data.GetType())"}
	$results = $data
	$hits = [regex]::Matches($results,$regex)
	if (!$hits) {	return $results }
	#$tokensfound = @{}
	$hits | Foreach-Object {
		$org = $_.groups[0].value
		$token = $org
		if ($token -like '$(*') {
			$token = $token.Remove(0,2)
			$token = $token.Substring(0, $token.Length - 1)
		}
		if ($tokens) {
			$value = $tokens[$token]
		}
		if (!$value) {$value = [System.Environment]::GetEnvironmentVariable($token)}
		#$tokensfound[$token] = $value
		$results = $results.Replace($org,"$value")
	}
	#Write-Verbose "Tokens updated:"
	#$tokensfound.keys.foreach({
		#Write-Verbose "$($_):$($tokensfound[$_])"
	#})
	return $results
}