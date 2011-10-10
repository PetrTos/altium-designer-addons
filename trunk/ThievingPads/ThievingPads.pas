{..............................................................................}
{ Summary   This script creates Thieving Pads to a PCB Document.               }
{           Pads are added to dummy component, for easier manipulation.        }
{                                                                              }
{                                                                              }
{ Created by:    Petar Perisin                                                 }
{..............................................................................}

{..............................................................................}
var
   Board : IPCB_Board;



function IsStringANum(Tekst : String) : Boolean;
var
   i : Integer;
   dotCount : Integer;
begin
   Result := True;

   // Test weather we have number, dot or comma
   for i := 1 to Length(Tekst) do
      if not(((ord(Tekst[i]) > 47) and (ord(Tekst[i]) < 58)) or (ord(Tekst[i]) = 44) or (ord(Tekst[i]) = 46)) then
         Result := False;

   // Test if we have more than one dot or comma
   dotCount := 0;
   for i := 1 to Length(Tekst) do
      if ((ord(Tekst[i]) = 44) or (ord(Tekst[i]) = 46)) then
      begin
         Inc(dotCount);
         if (i = 1) or (i = Length(Tekst)) then Result := False;
      end;

   if dotCount > 1 then Result := False;
end;



procedure TThievingPads.EditOutlineChange(Sender: TObject);
begin
   if not IsStringANum(EditOutline.Text) then
   begin
      ButtonOK.Enabled := False;
      EditOutline.Font.Color := clRed;
   end
   else
   begin
      EditOutline.Font.Color := clWindowText;
      if (IsStringANum(EditBetween.Text) and (IsStringANum(EditElectrical.Text)) and (IsStringANum(EditSize.Text))) then
         ButtonOK.Enabled := True;
   end;
end;



procedure TThievingPads.EditBetweenChange(Sender: TObject);
begin
   if not IsStringANum(EditBetween.Text) then
   begin
      ButtonOK.Enabled := False;
      EditBetween.Font.Color := clRed;
   end
   else
   begin
      EditBetween.Font.Color := clWindowText;
      if (IsStringANum(EditBetween.Text) and (IsStringANum(EditOutline.Text)) and (IsStringANum(EditSize.Text))) then
         ButtonOK.Enabled := True;
   end;
end;



procedure TThievingPads.EditElectricalChange(Sender: TObject);
begin
   if not IsStringANum(EditElectrical.Text) then
   begin
      ButtonOK.Enabled := False;
      EditElectrical.Font.Color := clRed;
   end
   else
   begin
      EditElectrical.Font.Color := clWindowText;
      if (IsStringANum(EditOutline.Text) and (IsStringANum(EditElectrical.Text)) and (IsStringANum(EditSize.Text))) then
         ButtonOK.Enabled := True;
   end;
end;



procedure TThievingPads.EditSizeChange(Sender: TObject);
begin
   if not IsStringANum(EditSize.Text) then
   begin
      ButtonOK.Enabled := False;
      EditSize.Font.Color := clRed;
   end
   else
   begin
      EditSize.Font.Color := clWindowText;
      if (IsStringANum(EditOutline.Text) and (IsStringANum(EditElectrical.Text)) and (IsStringANum(EditBetween.Text))) then
         ButtonOK.Enabled := True;
   end;
end;



procedure TThievingPads.ButtonCancelClick(Sender: TObject);
begin
   close;
end;



procedure TThievingPads.CheckBoxObjectsInsideClick(Sender: TObject);
begin
   if CheckBoxObjectsInside.Checked then
   begin
      EditElectrical.Enabled  := True;
      CheckBoxElectrical.Enabled := True;
   end
   else
   begin
      EditElectrical.Enabled  := False;
      CheckBoxElectrical.Enabled := False;
   end;
end;



procedure TThievingPads.ButtonOKClick(Sender: TObject);
var

   BoardShapeRect : TCoordRect;
   NewPad         : IPCB_Pad2;
   PosX, PosY     : Integer;
   TheLayerStack  : IPCB_LayerStack;
   LayerObj       : IPCB_LayerObject;
   LayerNum       : integer;
   Comp           : IPCB_Component;
   Distance       : Float;

   Iterator       : IPCB_BoardIterator;
   Rule           : IPCB_Rule;
   RuleOutline    : IPCB_ClearanceConstraint;
   RuleElectrical : IPCB_ClearanceConstraint;
   RuleBetween    : IPCB_ClearanceConstraint;

   MaxGap         : Integer;
   PadRect        : TCoordRect;
   Spatial        : IPCB_SpatialIterator;
   Primitive      : IPCB_Primitive;
   Violation      : IPCB_Violation;
   ViolationFlag  : Integer;
   SetOfLayers    : IPCB_LayerSet;

begin

   // Distance
   Distance := StrToFloat(EditSize.Text) + StrToFloat(EditBetween.Text);

   if RadioButtonMM.Checked then Distance := MMsToCoord(Distance)
   else                          Distance := MilsToCoord(Distance);

   // First I neeed to get Board shape bounding rectangel - we start from this
   BoardShapeRect := Board.BoardOutline.BoundingRectangle;
   TheLayerStack := Board.LayerStack;

   // now we will create new component because we will add all this objects to
   // dummy component
   PCBServer.PreProcess;
   Comp := PCBServer.PCBObjectFactory(eComponentObject, eNoDimension, eCreate_Default);
   If Comp = Nil Then Exit;

   // Set the reference point of the Component
   if (Board.XOrigin <> 0) and (Board.YOrigin <> 0) then
   begin
      Comp.X := Board.XOrigin;
      Comp.Y := Board.YOrigin;
   end
   else
   begin
      Comp.X := BoardShapeRect.Left;
      Comp.Y := BoardShapeRect.Bottom;
   end;

   Comp.Layer := eTopLayer;

   // Make the designator text visible;
   Comp.NameOn       := False;
   Comp.Name.Text    := 'Venting';

   // Make the comment text visible;
   Comp.CommentOn    := False;
   Comp.Comment.Text := 'Component That Holds Thieving Pads';

   Comp.ComponentKind := eComponentKind_Graphical;

   PCBServer.SendMessageToRobots(Board.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,Comp.I_ObjectAddress);
   Board.AddPCBObject(Comp);
   PCBServer.PostProcess;

   // Now we need to set up rules for this objects.
   // We need to check if they exist

   Iterator        := Board.BoardIterator_Create;
   Iterator.AddFilter_ObjectSet(MkSet(eRuleObject));
   Iterator.AddFilter_LayerSet(AllLayers);
   Iterator.AddFilter_Method(eProcessAll);

   // Search for Rules and mark if they are found
   // If not, create them
   Rule := Iterator.FirstPCBObject;

   RuleOutline    := Nil;
   RuleElectrical := Nil;
   RuleBetween    := Nil;

   While (Rule <> Nil) Do
   Begin
       if Rule.RuleKind = eRule_Clearance then
       begin

          if (Rule.Scope1Expression = 'InComponent(''Venting'')') and (Rule.Scope2Expression = 'OnLayer(''Keep-Out Layer'')') then
             RuleOutline := Rule
          else if (Rule.Scope1Expression = 'InComponent(''Venting'')') and (Rule.Scope2Expression = 'OnSignal') then
             RuleElectrical := Rule
          else if (Rule.Scope1Expression = 'InComponent(''Venting'')') and (Rule.Scope1Expression = 'InComponent(''Venting'')') then
             RuleBetween := Rule;

       end;

       Rule :=  Iterator.NextPCBObject;
   End;
   Board.BoardIterator_Destroy(Iterator);

   if RuleBetween = Nil then
   begin
      RuleBetween := PCBServer.PCBRuleFactory(eRule_Clearance);

      // Set values
      RuleBetween.Scope1Expression := 'InComponent(''Venting'')';
      RuleBetween.Scope2Expression := 'InComponent(''Venting'')';

      RuleBetween.NetScope  := eNetScope_AnyNet;

      if RadioButtonMM.Checked then RuleBetween.Gap := MMsToCoord(StrToFloat(EditBetween.Text))
      else                          RuleBetween.Gap := MilsToCoord(StrToFloat(EditBetween.Text));

      RuleBetween.Name    := 'Venting';
      RuleBetween.Comment := 'Clearance between Venting Pads';

      // Add the rule into the Board
      Board.AddPCBObject(RuleBetween);

   end
   else
   begin
      if RadioButtonMM.Checked then RuleBetween.Gap := MMsToCoord(StrToFloat(EditBetween.Text))
      else                          RuleBetween.Gap := MilsToCoord(StrToFloat(EditBetween.Text));
   end;

   if RuleOutline = Nil then
   begin
      RuleOutline := PCBServer.PCBRuleFactory(eRule_Clearance);

      // Set values
      RuleOutline.Scope1Expression := 'InComponent(''Venting'')';
      RuleOutline.Scope2Expression := 'OnLayer(''Keep-Out Layer'')';

      RuleOutline.NetScope  := eNetScope_AnyNet;

      if RadioButtonMM.Checked then RuleOutline.Gap := MMsToCoord(StrToFloat(EditOutline.Text))
      else                          RuleOutline.Gap := MilsToCoord(StrToFloat(EditOutline.Text));

      RuleOutline.Name    := 'Venting-Board';
      RuleOutline.Comment := 'Clearance between Venting Pads and Board Outline';

      // Add the rule into the Board
      Board.AddPCBObject(RuleOutline);

   end
   else
   begin
      if RadioButtonMM.Checked then RuleOutline.Gap := MMsToCoord(StrToFloat(EditOutline.Text))
      else                          RuleOutline.Gap := MilsToCoord(StrToFloat(EditOutline.Text));
   end;

   if RuleElectrical = Nil then
   begin
      RuleElectrical := PCBServer.PCBRuleFactory(eRule_Clearance);

      // Set values
      RuleElectrical.Scope1Expression := 'InComponent(''Venting'')';
      RuleElectrical.Scope2Expression := 'OnSignal';

      RuleElectrical.NetScope  := eNetScope_AnyNet;

      if RadioButtonMM.Checked then RuleElectrical.Gap := MMsToCoord(StrToFloat(EditElectrical.Text))
      else                          RuleElectrical.Gap := MilsToCoord(StrToFloat(EditElectrical.Text));

      RuleElectrical.Name    := 'Venting-Electrical';
      RuleElectrical.Comment := 'Clearance between Venting Pads and Electrical Objects';

      // Add the rule into the Board
      Board.AddPCBObject(RuleElectrical);

   end
   else
   begin
      if RadioButtonMM.Checked then RuleElectrical.Gap := MMsToCoord(StrToFloat(EditElectrical.Text))
      else                          RuleElectrical.Gap := MilsToCoord(StrToFloat(EditElectrical.Text));
   end;

   // We will save MaxGap value for further testing
   if RuleElectrical.Gap > RuleOutline.Gap then MaxGap := RuleElectrical.Gap
   else                                         MaxGap := RuleOutline.Gap;

   If TheLayerStack = Nil Then Exit;

   LayerNum := 1;

   LayerObj := TheLayerStack.FirstLayer;
   Repeat
      // we check if this is a signal layer
      if ILayer.IsSignalLayer(LayerObj.V7_LayerID) then
      begin
         if (((LayerNum = 1) and (CheckBoxTop.Checked)) or ((CheckBoxMid.Checked) and (LayerNum <> 1) and (LayerNum <> TheLayerStack.SignalLayerCount))
         or ((LayerNum = TheLayerStack.SignalLayerCount) and (CheckBoxBottom.Checked))) then
         Begin
            // We start from top left
            PosX := BoardShapeRect.Left;
            PosY := BoardShapeRect.Top;

            while ((PosY > BoardShapeRect.Bottom)) do
            begin

               if ((Board.BoardOutline.PointInPolygon(PosX, PosY) and (CheckBoxObjectsInside.Checked)) or
                  ((not(Board.BoardOutline.PointInPolygon(PosX, PosY))) and (CheckBoxObjectsOutside.Checked))) then
                  Begin
                     Try
                        PCBServer.PreProcess;
                        NewPad := PcbServer.PCBObjectFactory(ePadObject,eNoDimension,eCreate_Default);
                        If NewPad = Nil Then Exit;

                        NewPad.BeginModify;
                        NewPad.Mode := ePadMode_Simple;
                        NewPad.X    := PosX;
                        NewPad.Y    := PosY;

                        if RadioButtonMM.Checked then NewPad.TopXSize := MMsToCoord(EditSize.Text)
                        else                          NewPad.TopXSize := MilsToCoord(EditSize.Text);

                        if RadioButtonMM.Checked then NewPad.TopYSize := MMsToCoord(EditSize.Text)
                        else                          NewPad.TopYSize := MilsToCoord(EditSize.Text);

                        NewPad.TopShape  := eRounded;
                        NewPad.HoleSize  := 0;
                        NewPad.Layer     := LayerObj.V7_LayerID;
                        NewPad.Name      := 'TP';
                        NewPad.IsTenting := True;

                     Finally
                        PCBServer.PostProcess;
                     End;

                     NewPad.EndModify;
                     Board.AddPCBObject(NewPad);
                     Comp.AddPCBObject(NewPad);
                     PCBServer.SendMessageToRobots(Comp.I_ObjectAddress,c_Broadcast,PCBM_BoardRegisteration,NewPad.I_ObjectAddress);

                     // here we need to set up spatial iterator that will
                     // Check if we have clearence issues on pads
                     PadRect := NewPad.BoundingRectangle;

                     SetOfLayers := LayerSet.CreateLayerSet;
                     SetOfLayers.Include(LayerObj.V7_LayerID);
                     SetOfLayers.Include(String2Layer('Multi Layer'));
                     SetOfLayers.Include(String2Layer('Keep Out Layer'));

                     Spatial := Board.SpatialIterator_Create;
                     Spatial.AddFilter_ObjectSet(AllObjects);
                     Spatial.AddFilter_IPCB_LayerSet(SetOfLayers);
                     Spatial.AddFilter_Area(PadRect.Left - MaxGap, PadRect.Bottom - MaxGap, PadRect.Right + MaxGap, PadRect.Top + MaxGap);

                     ViolationFlag := 0;
                     Primitive := Spatial.FirstPCBObject;

                     while (Primitive <> nil) do
                     begin
                        Violation := RuleElectrical.ActualCheck(Primitive, NewPad);
                        if Violation <> nil then ViolationFlag := 1;

                        Violation := RuleOutline.ActualCheck(Primitive, NewPad);
                        if Violation <> nil then ViolationFlag := 1;

                        Primitive := Spatial.NextPCBObject;
                     end;
                     Board.SpatialIterator_Destroy(Spatial);

                     SetOfLayers := nil;

                     If ViolationFlag = 1 then
                        Board.RemovePCBObject(NewPad);

                  end;

               // finally we need to move one point right
               PosX := PosX + Distance;

               if PosX > BoardShapeRect.Right then
               begin
                  PosX := BoardShapeRect.Left;

                  PosY := PosY - Distance;
               end;
            end;
         end;
         Inc(LayerNum);
      end;

      LayerObj := TheLayerStack.NextLayer(LayerObj);
   Until LayerObj = Nil;

   if not CheckBoxBetween.Checked    then Board.RemovePCBObject(RuleBetween);
   if not CheckBoxElectrical.Checked then Board.RemovePCBObject(RuleElectrical);
   if not CheckBoxOutline.Checked    then Board.RemovePCBObject(RuleOutline);

   Board.ViewManager_GraphicallyInvalidatePrimitive(Comp);

   close;
end;



Procedure Start;
begin
   Board := PCBServer.GetCurrentPCBBoard;

   if Board = nil then exit;

   ThievingPads.ShowModal;
end;


