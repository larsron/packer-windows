# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<#
    .DESCRIPTION
    Clean and compact the VM.
#>

# Stops the windows update service.  
Stop-Service -Name wuauserv -Force -EA 0 
Get-Service -Name wuauserv

# Delete the contents of windows software distribution.
write-output "Delete the contents of windows software distribution" 
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 

# Delete the contents of localuser apps.
write-output "Delete the contents of localuser apps" 
Get-ChildItem "C:\users\localuser\AppData\Local\Packages\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 

# Delete the contents of user template desktop.
write-output "Delete the contents of user template desktop"
Get-ChildItem "C:\Users\Public\Desktop\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -recurse -ErrorAction SilentlyContinue 
 
# Starts the Windows Update Service 
Start-Service -Name wuauserv -EA 0

# use dism to cleanup windows sxs. This only works on 2012r2 and 8.1 and above. 
# bumped up to windows 10 only as was failing on 2012r2
if ([Environment]::OSVersion.Version -ge [Version]"10.0") {
  write-output "Cleaning up winSXS with dism"
  dism /online /cleanup-image /startcomponentcleanup /resetbase /quiet
}

# Defragment the virtual disk blocks
write-output "Starting to Defragment Disk"
Optimize-Volume -DriveLetter C -Verbose

# Zero free space
write-output "Starting to zero free disk space"
Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies
Install-Module -Repository PSGallery -Name Zero-Drive -force
Invoke-ZeroDrive -Drive C
Uninstall-Module -Name Zero-Drive

exit 0