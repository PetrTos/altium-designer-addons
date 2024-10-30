{==============================================================================}
{ ------------------------- Renumber Pads tool --------------------------------}
{------------------------------------------------------------------------------}
{-                                                                            -}
{-  Simple tool for renumbering of placed pads of a footprint in PCB library  -}
{-  or PCB document.                                                          -}
{-  You can select number index of first pad in window which appears after    -}
{-  running of the script. All other pads will be renumbered by Increment.    -}
{-  Script is terminateed by right click or Esc key during pad selection.     -}
{-                                                                            -}
{------------------------------------------------------------------------------}
{==============================================================================}

Var
    Board       : IPCB_Board;
    PadObject   : IPCB_Pad;

{..............................................................................}


// OK button event.
procedure TRenumberPads.btnOKClick(Sender: TObject);
Var
    PadIndex     : Integer;
    PadIncrement : Integer;
    PadPrefix    : String;
    PadSuffix    : String;
    PadDesignator : String;

Begin

     // Get requested first index number.
    PadIndex := StrToInt(edFirstPadNumber.Text);
    PadIncrement := StrToInt(edPadIncrement.Text);

    // Get requested prefix and suffix, if enabled.
    if cbPrefix.Checked then PadPrefix := edPrefix.Text
    else PadPrefix := '';

    if cbSuffix.Checked then PadSuffix := edSuffix.Text
    else PadSuffix := '';

    // Hide window.
    RenumberPads.Visible := 0;

     // Ask user to select first pad object
    PadObject := Board.GetObjectAtCursor(MkSet(ePadObject), AllLayers,
                                      'Choose a pad');
    While PadObject <> 0 Do
    Begin
         // create undo for each pad index change
        PCBServer.PreProcess;
        PCBServer.SendMessageToRobots(PadObject.I_ObjectAddress, c_Broadcast,
                               PCBM_BeginModify , c_NoEventData);
         // change pad index
        PadObject.Name := format('%S%S%S',[PadPrefix, IntToStr(PadIndex), PadSuffix]);
        PCBServer.SendMessageToRobots(PadObject.I_ObjectAddress, c_Broadcast,
                               PCBM_EndModify , c_NoEventData);
        PCBServer.PostProcess;

        // Increment the current pad index for the next loop.
        PadIndex := PadIndex + PadIncrement;

        // Ask user to select next pad in infinite loop.
        PadObject := Board.GetObjectAtCursor(MkSet(ePadObject), AllLayers,
                                      'Choose a pad');
    End;

    Close;
End;


// Cancel button event.
procedure TRenumberPads.btnCancelClick(Sender: TObject);
begin
     Close;
end;

procedure TRenumberPads.RenumberPadsCreate(Sender: TObject);
begin

     // Load current board
    If PCBServer = Nil Then
       Begin
            ShowMessage('Not a PCB or Footprint editor activated.');
            Exit;
       End;
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then
       Begin
            ShowMessage('Not a PCB or Footprint loaded.');
            Exit;
       End;

end;


// Enable or disable the designator prefix option.
procedure TRenumberPads.cbPrefixClick(Sender: TObject);
begin
     if cbPrefix.Checked then edPrefix.Enabled := True
     else edPrefix.Enabled := False;
end;


// Enable or disable the designator suffix option.
procedure TRenumberPads.cbSuffixClick(Sender: TObject);
begin
     if cbSuffix.Checked then edSuffix.Enabled := True
     else edSuffix.Enabled := False;
end;


// Generate a preview of the designator format.
procedure TRenumberPads.btnPreviewClick(Sender: TObject);
Var
     PadIndex     : Integer;
     PadIncrement : Integer;
     PadPrefix    : String;
     PadSuffix    : String;
     PadDesignator : String;
     PadDesignatorNext      : String;

begin
     PadIndex := StrToInt(edFirstPadNumber.Text);
     PadIncrement := StrToInt(edPadIncrement.Text);

     if cbPrefix.Checked then PadPrefix := edPrefix.Text
     else PadPrefix := '';

     if cbSuffix.Checked then PadSuffix := edSuffix.Text
     else PadSuffix := '';

     lblPreview.Visible := True;

     PadDesignator := format('%S%S%S',[PadPrefix, IntToStr(PadIndex), PadSuffix]);
     PadDesignatorNext := format('%S%S%S',[PadPrefix, IntToStr(PadIndex + PadIncrement), PadSuffix]);
     lblPreview.Caption := format('%S, %S', [PadDesignator, PadDesignatorNext]);
end;
