Sub UpdatePivotTable()
    Dim pt As PivotTable

    ' Set the active PivotTable
    On Error Resume Next
    Set pt = ActiveSheet.PivotTables("PivotTable2") ' Assumes the PivotTable is on the active sheet
    On Error GoTo 0

    ' Check if PivotTable exists
    If Not pt Is Nothing Then
        ' Remove all existing fields from the Values area
        For Each pf In pt.DataFields
            pf.Orientation = xlHidden
        Next pf

        ' Add fields to the Values area with custom column names
        AddFieldToPivotTable pt, "hmd_response_yes", "Response_Yes"
        AddFieldToPivotTable pt, "hmd_response_no_adjusted", "Response_No_Adjusted"
        AddFieldToPivotTable pt, "hmd_response_yes_adjusted", "Response_Yes_Adjusted"
        AddFieldToPivotTable pt, "hmd_total_responses", "Total_Responses"

        ' Refresh the PivotTable
        pt.RefreshTable
    Else
        MsgBox "PivotTable not found.", vbExclamation
    End If
End Sub

Sub AddFieldToPivotTable(pt As PivotTable, fieldName As String, customColumnName As String)
    Dim pf As PivotField

    ' Add the field as a Sum in the Values area
    Set pf = pt.PivotFields(fieldName)
    If Not pf Is Nothing Then
        pf.Orientation = xlDataField
        pf.Function = xlSum
        pf.NumberFormat = "General" ' Set the number format to General to remove the "Sum of" prefix
        pf.Caption = customColumnName ' Set the custom column header
    Else
        MsgBox "Field '" & fieldName & "' not found.", vbExclamation
    End If
End Sub
