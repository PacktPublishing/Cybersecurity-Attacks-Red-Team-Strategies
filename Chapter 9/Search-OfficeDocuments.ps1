function Search-OfficeDocuments()
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$Name,
        [Parameter(Mandatory = $false)] [string]$SearchFilter = "password"
    )
    
    process 
    {
        foreach ($file in $Name)
        {  
          ### add a quick check for the filename itself
          $fullPath = Convert-Path $file
          if ($fullPath -match $SearchFilter)
          {
               $finding = [PSCustomObject]@{
                        FullPath    = $fullPath
                        Document    = Split-Path $fullPath -leaf
                        FindingType = "Filename"
                        Notes       = "Filename matches search pattern." 
                    }
                    
               $finding
          }

          ### word documents
          if ($file.EndsWith(".doc") -or $file.EndsWith(".docx"))
          {
             Search-Word $file $SearchFilter
          }

          ### excel documents
          if ($file.EndsWith(".xls") -or $file.EndsWith(".xlsx") -or $file.EndsWith(".csv"))
          {
              Search-Excel $file $SearchFilter
           }
        } 
    }

}


function Search-Word()
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$Name,
        [Parameter(Mandatory = $false)] [string]$SearchFilter = "password"
    )

    begin
    {
        $word = New-Object -com Word.Application
        #$word.Visible = $true

        Add-Type -AssemblyName Microsoft.Office.Interop.Word
    }

    process
    {

        foreach ($file in $Name)
        {
           $fullPath = Convert-Path $file        
           Write-Host -ForegroundColor Yellow "Processing $fullPath"   
           $document = $word.Documents.Open($fullPath)

           $range = $document.Range(); 
           while ( $range.Find.Execute($SearchFilter)) 
           { 
                $result = $range.Expand([int][Microsoft.Office.Interop.Word.WdUnits]::wdSentence); 
                
                $page = $range.Information([int][Microsoft.Office.Interop.Word.WdInformation]::wdActiveEndPageNumber)
                $line = $range.Information([int][Microsoft.Office.Interop.Word.WdInformation]::wdFirstCharacterLineNumber)
                $location = "Page:$page (Line:$line)"

                $finding = [PSCustomObject]@{
                    FullPath    = $fullPath
                    Document    = $document.Name
                    FindingType = "Word Document"
                    Location    = $location
                    Notes       = $range.Text 
                }
                
                $finding
                $range.Collapse(0) 
           }

           $document.Close()
        }
    }

    end
    {
        $word.Quit()
    }
}


function Search-Excel()
{
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string]$Name,
        [Parameter(Mandatory = $false)] [string]$SearchFilter = "password"
    )

    begin
    {
        Add-Type -AssemblyName Microsoft.Office.Interop.Excel
        $excel = New-Object -com Excel.Application

        $LookInOptions = @(
            [int][Microsoft.Office.Interop.Excel.XlFindLookIn]::xlValues,
            [int][Microsoft.Office.Interop.Excel.XlFindLookIn]::xlComments,
            [int][Microsoft.Office.Interop.Excel.XlFindLookIn]::xlFormulas
        )
    }

    process
    {
        foreach ($file in $Name)
        {
            $fullPath = Convert-Path $file      
            Write-Host -ForegroundColor Yellow "Processing $file"     
            $workbook = $excel.Workbooks.Open($fullPath)

            foreach ($sheet in $workbook.Sheets)
            {
                # check if the name the worksheet itselfs matches search pattern
                if ($sheet.Name -Match $SearchFilter)
                { 
                    $finding = [PSCustomObject]@{
                        FullPath    = $fullPath
                        Document    = $sheet.Name
                        FindingType = "Excel Worksheet Name"
                        Notes       = "Worksheet Name matches search pattern." 
                    }
                    
                    $finding
                } 

                $current = $sheet.Cells; 

                foreach ($lookIn in $LookInOptions)
                {
                    $first = $current.Find($SearchFilter, $sheet.Range("A1"), $lookIn)
                    if ($first -ne $null)
                    {
                        $last = $first

                        do
                        {
                           $finding = [PSCustomObject]@{
                              FullPath    = $fullPath
                              Document    = $sheet.Name
                              FindingType = "Excel Worksheet"
                              Location    = $last.Address()
                              Value       = $last.Value()
                              Notes       = ""
                              NeighborRow = $last.Item($last.Row + 1, $last.Column).Value()
                              NeighborColumn = $last.Item($last.Row, $last.Column + 1).Value()
                           }
                           if ($last.Comment -ne $null)         { $finding.Notes += $last.Comment.Text() }
                           if ($last.CommentThreaded -ne $null) { $finding.Notes += $last.CommentThreaded.Text() }
                    
                           $finding

                           $last = $current.FindNext($last)
                        }   
                        while ($last.Address() -ne $first.Address())
                    }
                }
            }   

            $workbook.Close()
        }
    }

    end
    {
        $excel.Quit()
    }
}