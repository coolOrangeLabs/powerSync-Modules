#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2024 COOLORANGE S.r.l.                                         #
#==============================================================================#

# Autodesk Platform Services - Data Management Folders

# API documentation: https://aps.autodesk.com/en/docs/data/v2/reference/http/projects-project_id-folders-folder_id-contents-GET
function Get-ApsFolderContents($project, $folder) {
    Write-Verbose "Reading Folder Contents..."

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/data/v1/projects/$($project.id)/folders/$($folder.id)/contents"
        "Method" = "Get"
        "Headers" = $ApsConnection.Headers
    }
    #$response = Invoke-RestMethod @parameters
    #return $response.data

    $response = Invoke-WebRequest @parameters
    $ms = New-Object System.IO.MemoryStream
    $response.RawContentStream.CopyTo($ms)
    $json = [System.Text.Encoding]::UTF8.GetString($ms.ToArray())
    $data = $json | ConvertFrom-Json
    Write-Verbose "Successfully obtained folder contents!"
    return $data.data
}

# Function to create a new folder. Returns a folder object.
# API documentation: https://aps.autodesk.com/en/docs/data/v2/reference/http/projects-project_id-folders-POST
function Add-ApsFolder($project, $parentFolder, $folderName) {
    Write-Host "Creating Folder '$($folderName)'..."

    $body = ConvertTo-Json @{
        "jsonapi" = @{
            "version" = "1.0"
        }
        "data" = @{
            "type" = "folders"
            "attributes" = @{
                "name" = "$($folderName)"
                "extension" = @{
                    "type" = "folders:autodesk.bim360:Folder"
                    "version" = "1.0"
                }
            }
            "relationships" = @{
                "parent" = @{
                    "data" = @{
                        "type" = "folders"
                        "id" = "$($parentFolder.id)"
                    }
                }
            }
        }
    } -Depth 100 -Compress

    $parameters = @{
        "Uri" = "https://developer.api.autodesk.com/data/v1/projects/$($project.id)/folders"
        "Method" = "Post"
        "ContentType" = "application/vnd.api+json"
        "Headers" = $ApsConnection.Headers
        "Body" = (New-Object System.Text.UTF8Encoding($false)).GetBytes($body)
    }    
    $response = Invoke-RestMethod @parameters
    return $response.data
}

# Function to get all items and subfolders. Returns all items objects and folder objects from the given folder.
function Get-ApsFolderFromPath($hub, $project, $path){
    $folders = Get-ApsTopFolders -hub $hub -project $project
    [array] $pathFolders = $path.replace("/", "\").split("\")

    $depth = 0;
    $folder = $null
    while ($depth -lt $pathFolders.Count){
        $folder = $folders | Where-Object {$_.attributes.displayName -eq $pathFolders[$depth] -and $_.type -eq "folders"}
        if ($null -eq $folder){
            Write-Verbose "PATH `"$path`" does not exist in ACC Files Tool"
            return $null
        }       
        $folders = Get-ApsFolderContents -project $project -folder $folder
        $depth += 1
    }
    return $folder
}

# Function to get the 'Project Files' folder of a given project. Returns the folder object or $null.
function Get-ApsProjectFilesFolder($hub, $project) {
    Write-Verbose "Getting Project Files folder..."
    $folders = Get-ApsTopFolders $hub $project
    $projectFilesFolder = $folders | Where-Object { $_.attributes.name -eq "Project Files" } 
    if ($projectFilesFolder) {
        Write-Verbose "Obtained Project Files folder!"
        return $projectFilesFolder
    } else {
        return $null
    }
}

