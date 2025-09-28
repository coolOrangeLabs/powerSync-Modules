#==============================================================================#
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER    #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES  #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.   #
#                                                                              #
# Copyright (C) 2025 COOLORANGE S.r.l.                                         #
#==============================================================================#

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-item-types-GET/
function Get-ApsItemTypes($project){
    Write-Verbose "Getting submittal types..."
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/item-types"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully obtained submittal types!"
    return $response
}

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-specs-GET/ 
function Get-AccSpecs($project){
    
    Write-Verbose "Getting spec sections..."

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/specs"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully obtained spec sections!"
    return $response
}

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-GET/ 
function Get-ApsAccItems($project){
    Write-Verbose "Getting submittal items..."

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/items"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully obtained submittal items!"
    return $response
}

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-metadata-GET/
function Get-Metadata($project){
    Write-Verbose "Getting submittal metadata in project..."
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/metadata"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully obtained metadata!"
    return $response
}


# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-specs-id-GET/
function Get-AccSpec($project, $specID){
    Write-Verbose "Getting spec section with ID $specID"

    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/specs/$specID"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained spec section!"
    return $response
}
# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-GET/
function Get-ApsAccItem($project, $itemID){
    Write-Verbose "Attempting to obtain submittal with ID $itemID..."
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/items/$itemID"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully obtained submittal item!"
    return $response
}

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-POST/
function Add-ApsAccSubmittalItem($project, $type, $spec, $title, $stateID, $optionalParameters) {
    Write-Verbose "Adding submittal item '$title'"
    $bodyFull = @{
        "typeId" = $type.ID
        "specId" = $spec.ID
        "title" = $title
        "description" = "This submittal item was created by the Job Processor from a review"
        "stateId" = $stateID
    }

    if ($optionalParameters){
        $optionalParameters.keys | ForEach-Object{
            $bodyFull[$_] = $optionalParameters[$_]
        }
    }

    $body = $bodyFull | ConvertTo-Json -Depth 100 -Compress

    #Write-Host $body.replace(",", "`n")
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/items"
        "Method"  = "Post"
        "Headers" = $ApsConnection.Headers
        "ContentType" = "application/json"
        "Body" = $body
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Submittal item successfully added!"
    return $response
}

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-PATCH/
function Update-ApsSubmittalItem($project, $itemID, $body){
    Write-Verbose ""

    $jsonBody = $body | ConvertTo-Json -depth 100 -Compress

    $parameters = @{
        "Uri"     = " https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/items/$itemId"
        "Method"  = "Patch"
        "ContentType" = "application/json"
        "Headers" = $ApsConnection.Headers
        "Body" = $jsonBody
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}
# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-attachments-GET/
function Get-ApsItemAttachments($project, $item){
    Write-Verbose "Attempting to obtain submittal attachments of item with ID $($item.ID)"
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/items/$($item.ID)/attachments"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully obtained submittal attachments!"
    return $response
}

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-attachments-POST/ 
# For Local Files
function Add-ApsAccItemAttachment($project, $item, $filename){
    Write-Verbose "Adding local item attachment..."
    $bodyFull = @{"name" = $fileName; "urnTypeID" = 2}
    $body = $bodyFull |ConvertTo-Json -Depth 100 -Compress
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/items/$($item.ID)/attachments"
        "Method"  = "Post"
        "Headers" = $ApsConnection.Headers
        "Body"    = $body
        "ContentType" = "application/json"
    }    

    $response = Invoke-RestMethod @parameters
    return $response
}

# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-attachments-POST/ 
# For ACC "Files"
function Add-ApsAccItemAttachments($project, $item, $urn, $name){ 
    Write-Verbose "Attempting to add attachment to item..."
    $bodyFull = @{"name" = $name; "isFileUploaded" = $true; "urnTypeID" = 2; categoryID = 1; "urn" = $urn}
    $body = $bodyFull |ConvertTo-Json
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/items/$($item.ID)/attachments"
        "Method"  = "Post"
        "Headers" = $ApsConnection.Headers
        "Body"    = $body
    }    

    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully added attachment!"
    return $response
}

# Updates the upload status of an attachment associated with a submittal item. Use this endpoint after completing the file upload to update the attachment status.
# Note, this endpoint applies to the local files workflow only and is not used for Files tool attachments.
# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-attachments-attachmentId-PATCH/ 
function Update-ApsAccItemAttachment($project, $item, $attachmentID){
    Write-Verbose "Attempting to update attachment to item..."
    $bodyFull = @{"isFileUploaded" = $true}
    $body = $bodyFull |ConvertTo-Json -Depth 100 -Compress
    $parameters = @{
        "Uri"     = " https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/items/$($item.Id)/attachments/$attachmentId"
        "Method"  = "Patch"
        "Headers" = $ApsConnection.Headers
        "Body"    = $body
        "ContentType" = "application/json"
    }    
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Successfully updated attachment!"
    return $response
}

# Obtains list of users, roles, and companies assigned submittal managers in a given project
# https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-mappings-GET/
function Get-SubmittalRoleMappings ($project){
    Write-Verbose "Getting submittal role mappings..."
    $parameters = @{
        "Uri"     = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$(($project.id -replace '^b\.', ''))/settings/mappings"
        "Method"  = "Get"
        "Headers" = $ApsConnection.Headers
    }    
    $response = Invoke-RestMethod @parameters
    Write-Verbose "Obtained submittal role mappings!"
    return $response
}

# Adds a local file as an attachment to a submittal item
function Add-ApsAccItemLocalAttachment($project, $item, $localPath, $fileName){
    Write-Verbose "Attempting to add local file as attachment"
    $projectID = ($project.id -replace '^b\.', '')
    $itemID = $item.ID
    $attachment = Add-ApsAccItemAttachment -projectID $projectID -itemID $itemID -fileName $fileName

    $keys = $attachment.uploadUrn.substring(27).Split('/')
    $bucketKey = $keys[0]
    $objectKey = $keys[1]

    $signedUrl = Get-SignedURL -bucketKey $bucketKey -objectKey $objectKey
    $url = $signedUrl.urls[0]
    $uploadKey = $signedUrl.uploadKey

    Publish-ToUrl -url $url -filePath $localPath | Out-Null 
    Get-UploadBucket -bucketKey $bucketKey -objectKey $objectKey -uploadKey $uploadKey | Out-Null
    $response = Update-ApsAccItemAttachment -projectID $projectId -itemID $itemID -attachmentID $attachment.Id
    return $response;   
}

# Downloads attachments of the given submittal to $exportPath
function Save-ItemAttachments ($project, $item, $exportPath){
    Write-Verbose "Attempting to download attachments to item with ID $($item.ID) to $exportPath"
    $projectID = $(($project.id -replace '^b\.', ''))
    $pathRet = [Array]@()
    $attachments = (Get-ApsItemAttachments -projectID $projectID -itemID $item.id).results
    $attachments | ForEach-Object {
        $keys = $_.uploadUrn.substring(27).Split('/')
        $bucketKey = $keys[0]
        $objectKey = $keys[1]
        $signedUrl = Get-SignedURLDownload -bucketKey $bucketKey -objectKey $objectKey
        $fullPath = "$exportPath\$($_.Name)"
        Invoke-RestMethod -Uri $signedUrl.url -OutFile $fullPath
        $pathRet += $fullPath
    }
    Write-Verbose "$pathRet attachments successfully downloaded"
    return $pathRet
}