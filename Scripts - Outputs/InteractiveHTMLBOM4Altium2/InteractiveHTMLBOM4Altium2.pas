const
  constKindPcb                  = 'PCB';

// GLOBAL VARIABLES SECTION
Var
  CurrWorkSpace: IWorkSpace; // An Interface handle to the current workspace
  CurrProject: IProject; // An Interface handle to the current Project
  ProjectVariant: IProjectVariant; // An Interface handle to the current Variant
  FlattenedDoc: IDocument; // An Interface handle to the "flattened" document
  CurrComponent: IComponent; // An Interface handle to the current Component
  TargetFileName: String;
  // System parameter supplied by OutJob : desired output file name, if any
  TargetFolder: String;
  // System parameter supplied by OutJob : desired output folder
  TargetPrefix: String;
  // System parameter supplied by OutJob : desired output file name prefix, if any
  LayerFilterIndex: Integer;
  FieldSeparatorIndex: Integer;
  PluginExecutable: String;

Function GetOutputFileNameWithExtension(Ext: String): String;
Begin
  If TargetFolder = '' Then
    TargetFolder := CurrProject.DM_GetOutputPath;
  If TargetFileName = '' Then
    TargetFileName := CurrProject.DM_ProjectFileName;
  Result := AddSlash(TargetFolder) + TargetPrefix +
    ChangeFileExt(TargetFileName, Ext);
  // CurrString := StringReplace( CurrString, '<DATE>',    DateStr,    MkSet( rfReplaceAll, rfIgnoreCase ) );
End;

{***************************************************************************
 * function FindProjectPcbDocFile()
 *  Find the PcbDoc file associated with this project.
 *  Panic if we find any number not equal to 1 (eg 0 or 2).
 *
 *  Returns full path to this project's PcbDoc file in var parm pcbDocPath.
 *  Returns:  0 on success, 1 if not successful.
 ***************************************************************************}
function FindProjectPcbDocFile(    Project               : IProject;
                                   flagRequirePcbDocFile : Boolean;
                               var pcbDocPath            : TDynamicString;
                               )                         : Integer;
var
   Document   : IDocument;
   k          : Integer;
   numPcbDocs : Integer;

begin

   { For now, assume/hope/pray that we will succeed. }
   result := 0;

   { Flag that we haven't yet found the PcbDoc file. }
   pcbDocPath := '';

   { Init number of PcbDoc files found to be 0. }
   numPcbDocs := 0;

   {*** Find name of this project's .PcbDoc file. ***}
   { Loop over all logical documents in the project.... }
   for k := 0 to Project.DM_LogicalDocumentCount - 1 do
   begin
      Document := Project.DM_LogicalDocuments(k);

      { See if this document is a PcbDoc file. }
      if (Document.DM_DocumentKind = constKindPcb) then
      begin

         { Increment number of PcbDoc files that we've found. }
         numPcbDocs := numPcbDocs + 1;

         { Record name of this PcbDoc file to return to caller. }
         pcbDocPath := Document.DM_FullPath;
//       ShowMessage('Found PCB document with full path ' + pcbDocPath);
      end;

   end; { endfor loop over all logical documents in project }


   { Make sure there is at least one PcbDoc file. }
   if (numPcbDocs < 1) then
   begin

      { See if the user has requested operations that require a PcbDoc file. }
      if (flagRequirePcbDocFile) then
      begin
         MyAbort('Found ' + IntToStr(numPcbDocs) + ' PcbDoc files in your project.  This number should have been exactly 1!');
      end

      { Else just issue a warning. }
      else
      begin
         { Issue warning modal dialog box with specified warning message,
          no reply after clicking Ok, and specified reply after clicking Cancel. }
         IssueWarningWithOkOrCancel('Unable to find a PcbDoc file within this project.' + constLineBreak +
                                    'However, since you have not requested operations that require a PcbDoc file, I will proceed to generate other OutJob outputs if you click OK.',
                                    '',
                                    'Aborting script at user request due to missing PcbDoc file ' + constPcbVersionParm + '.');
      end; { endelse }

   end; { endif }

   { Make sure there is no more than 1 PcbDoc file. }
   if (numPcbDocs > 1) then
   begin
      MyAbort('Found ' + IntToStr(numPcbDocs) + ' PcbDoc files in your project.  This script currently only supports having 1 PcbDoc file per project!');
   end;

//   ShowMessage('About to leave FindProjectPcbDocFile(), pcbDocPath is ' + pcbDocPath);

end; {end FindProjectPcbDocFile() }

Function UseItEx(_CurrComponent,_CurrPart: TString;
  _ProjectVariant: IProjectVariant): Boolean;
var
  //_CurrPart: IPart;
  ComponentVariation: IComponentVariation;
begin
  // [!!!] UGLY
  //_CurrPart := _CurrComponent.DM_SubParts[0];
  if _ProjectVariant = nil then
  begin
    if pos('@', _CurrComponent) <> 0 then
    begin
      Result := False;
    end
    else
    begin
      Result := True;
    end;
  end;

  if _ProjectVariant <> nil then
  begin
    ComponentVariation := _ProjectVariant.DM_FindComponentVariationByDesignator
      (_CurrPart);
    if ComponentVariation <> nil then
    begin
      if _CurrComponent <> ComponentVariation.DM_UniqueId + '@' +
        _ProjectVariant.DM_Description then
      begin
        Result := False;
      end
      else
      begin
        Result := True;
      end;
      // [!!!] Never
      if ComponentVariation.DM_VariationKind = eVariation_NotFitted then
      begin
        Result := False;
      end;
    end
    else
    begin
      if pos('@', _CurrComponent) <> 0 then
      begin
        Result := False;
      end
      else
      begin
        Result := True;
      end;
    end;
  end;
end;

function GetSeparator:String;
var
  Separator: TString;
begin
  case FieldSeparatorIndex of
    0: Separator := ',';
    1: Separator := ';';
    2: Separator := ' ';
    3: Separator := #9;
    //else
  end;

  Result := Separator;
end;

function Preprocess(Value:String):String;
var
  Separator: TString;
begin
  //Separator := GetSeparator();

  //Result := StringReplace(Value, Separator, '', MkSet(rfReplaceAll,rfIgnoreCase));
  Result := Value;
end;

Function LALALALA(Ext: String): String;
Begin
  If TargetFolder = '' Then
    TargetFolder := CurrProject.DM_GetOutputPath;
  If TargetFileName = '' Then
    TargetFileName := CurrProject.DM_ProjectFileName;
  Result := AddSlash(TargetFolder) + TargetPrefix + 'pcbdata.js';
  // CurrString := StringReplace( CurrString, '<DATE>',    DateStr,    MkSet( rfReplaceAll, rfIgnoreCase ) );
End;

function PickAndPlaceOutputEx:String;
var
    Board                          : IPCB_Board; // document board object
    Component                      : IPCB_Component; // component object
    Iterator                       : IPCB_BoardIterator;
    ComponentIterator              : IPCB_GroupIterator;
    Pad                            : IPCB_Pad;
    SMDcomponent                   : Boolean;
    BoardUnits                     : String;
                                     // Current unit string mm/mils
    PnPout                         : TStringList;
    Count                          : Integer;
    FileName                       : TString;
    Document                       : IServerDocument;
    X, Y, Rotation, Layer          : TString;
    pcbDocPath: TString;
    flagRequirePcbDocFile : Boolean;
    Separator: TString;
    Iter, Prim: TObject;
    PadsCount: Integer;
    PadLayer,PadType:String;
    PadX, PadY, PadAngle : TString;
    X1,Y1,X2,Y2: Single;
    Width, Height :String;
    PadWidth, PadHeight, PadPin1 :String;
    PadShape,PadDrillShape:String;
    EdgeType:String;
    EdgeWidth,EdgeX1,EdgeY1,EdgeX2,EdgeY2,EdgeRadius: String;
Begin
   // Make sure the current Workspace opens or else quit this script
  CurrWorkSpace := GetWorkSpace;
  If (CurrWorkSpace = Nil) Then
    Exit;

  // Make sure the currently focussed Project in this Workspace opens or else
  // quit this script
  CurrProject := CurrWorkSpace.DM_FocusedProject;
  If CurrProject = Nil Then
    Exit;

   flagRequirePcbDocFile := true;

   FindProjectPcbDocFile(CurrProject,
                         flagRequirePcbDocFile,
                         {var} pcbDocPath);

   ResetParameters;
   AddStringParameter('ObjectKind', 'Document');
   AddStringParameter('FileName', pcbDocPath);
   RunProcess('WorkspaceManager:OpenObject');
   Board := PCBServer.GetCurrentPCBBoard;
// Board := PCBServer.GetPCBBoardByPath('d:\home\gandalf\src\alt\ya-regul\main');
 //Board := PCBServer.GetPCBBoardByPath('d:\home\gandalf\src\alt\ya-regul\main.PcbDoc');

    If Not Assigned(Board) Then  // check of active document
       Begin
          ShowMessage('The Current Document is not a PCB Document.');
       Exit;
    End;


    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
    Iterator.AddFilter_IPCB_LayerSet(LayerSet.AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    Separator := GetSeparator();
    Count := 0;
    PnPout   := TStringList.Create;
    Component := Iterator.FirstPCBObject;

    //PnPout.Add('Designator'  + #9 + 'Footprint' + #9 + 'Xref' + #9 + 'Yref'  + #9 + 'Rotation' + #9 + 'Layer' + #9 + 'Description');
    //PnPout.Add('Designator'  + Separator + 'Comment'  + Separator + 'Layer'  + Separator + 'Part Number'  + Separator + 'Footprint'  + Separator + 'Center-X(mm)'  + Separator + 'Center-Y(mm)'  + Separator + 'Rotation'  + Separator + 'Description'  + Separator + 'Mounting_Type');
    //PnPout.Add('Designator'  + #9 + 'Footprint' + #9 + 'Xref' + #9 + 'Yref'  + #9 + 'Rotation' + #9 + 'Layer' + #9 + 'Description');

    PnPout.Add('var altiumbom = {');
    PnPout.Add('"Data":[');


    While (Component <> Nil) Do
    Begin
        // Test if the component is SMD (all pads without hole)
        ComponentIterator := Component.GroupIterator_Create;
        ComponentIterator.AddFilter_ObjectSet(MkSet(ePadObject));
        Pad := ComponentIterator.FirstPCBObject;
        While (Pad <> Nil) Do
        Begin
          //
            SMDcomponent := True;
            If Pad.Layer = eMultiLayer Then
               Begin
                    SMDcomponent := False;
                    Break;
               End;
            Pad := ComponentIterator.NextPCBObject;
        End;
        // Print Pick&Place data of SMD components to file
        if UseItEx(Component.SourceUniqueId, Component.SourceDesignator, ProjectVariant) then
        //if (LayerFilterIndex=0) or ((LayerFilterCb=1) and (Component.Layer = eTopLayer)) or ((LayerFilterCb=2) and (Component.Layer = eBottomLayer)) then
        //If (SMDcomponent = True) Then
           Begin
                Inc(Count);
                If (Count>1) Then
                  PnPout.Add(',');
                If (Component.Layer = eTopLayer) Then
                    Layer := 'TopLayer'
                Else
                    Layer := 'BottomLayer';
                X := FloatToStr(CoordToMMs(Component.X - Board.XOrigin));
                Y := FloatToStr(-CoordToMMs(Component.Y - Board.YOrigin));
                Rotation := IntToStr(Component.Rotation);
                    //Component.Component.
                    //Designator,Comment,Layer,Part Number,Center-X(mm),Center-Y(mm),Rotation,Description,Mounting_Type
                //PnPout.Add(Component.SourceDesignator  + #9 + Component.SourceLibReference + #9 + X + #9 + Y  + #9 + Rotation + #9 + Layer + #9 + Component.FootprintDescription+#9+Component.SourceUniqueId+#9+Component.Pattern+#9+Component.SourceFootprintLibrary+#9+Component.SourceLibReference);
                //PnPout.Add(Preprocess(Component.SourceDesignator)  + Separator + Preprocess('Comment') + Separator + Preprocess(Layer) + Separator + Preprocess(Component.SourceLibReference)  + Separator + Preprocess(Component.Pattern) + Separator + Preprocess(X) + Separator + Preprocess(Y) + Separator + Preprocess(Rotation) + Separator + Preprocess('Description') + Separator + Preprocess('SMD'));

                X := StringReplace(X, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
                Y := StringReplace(Y, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

                //TODO: Is it correct? X1,Y1 vs X,Y
                X1 :=CoordToMMs(Component.BoundingRectangleNoNameCommentForSignals.Left- Board.XOrigin);
                Y1 :=CoordToMMs(Component.BoundingRectangleNoNameCommentForSignals.Bottom- Board.YOrigin);
                X2 :=CoordToMMs(Component.BoundingRectangleNoNameCommentForSignals.Right- Board.XOrigin);
                Y2 :=CoordToMMs(Component.BoundingRectangleNoNameCommentForSignals.Top- Board.YOrigin);

                Width := FloatToStr(X2-X1);
                Height := FloatToStr(Y2-Y1);

                Width := StringReplace(Width, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
                Height := StringReplace(Height, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

                X := StringReplace(FloatToStr(X1), ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
                Y := StringReplace(FloatToStr(-Y2), ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));


                {
        bbox['pos'] :=[x0.round(), -y1.round()]; //
        bbox['relpos'] :=[0, 0];
        bbox['angle'] :=0;
        bbox['size'] :=[(x1 - x0).round(), (y1 - y0).round()];
        bbox['center'] :=[(x0 + bbox.size[0] / 2).round(), -(y0 + bbox.size[1] / 2).round()];
        }

                PnPout.Add('{');

                PnPout.Add('"Designator":'+'"'+Preprocess(Component.SourceDesignator)+'"'+',');
                PnPout.Add('"Layer":'+'"'+Preprocess(Layer)+'"'+',');
                PnPout.Add('"Footprint":'+'"'+Preprocess(Component.Pattern)+'"'+',');
                PnPout.Add('"PartNumber":'+'"'+Preprocess(Component.SourceLibReference)+'"'+',');
                PnPout.Add('"X":'+'"'+Preprocess(X)+'"'+',');
                PnPout.Add('"Y":'+'"'+Preprocess(Y)+'"'+',');
                PnPout.Add('"Width":'+'"'+Preprocess(Width)+'"'+',');
                PnPout.Add('"Height":'+'"'+Preprocess(Height)+'"'+',');

                PnPout.Add('"Pads":'+'[');

                PadsCount := 0;
                Iter :=Component.GroupIterator_Create;
                Iter.AddFilter_ObjectSet(MkSet(ePadObject));
                Iter.AddFilter_LayerSet(AllLayers);
                Prim :=Iter.FirstPCBObject;
                while (Prim <> nil) do begin
                Pad := Prim;
                Inc(PadsCount);
                If (PadsCount>1) Then
                  PnPout.Add(',');
                PnPout.Add('{');

                //TODO: Not sure
                PadType := Pad.Layer;
                if (Pad.Layer = eTopLayer) then
                begin
                  PadLayer := 'TopLayer';
                  PadType := 'smd';
                  PadWidth := FloatToStr(CoordToMMs(Pad.TopXSize));
                  PadHeight := FloatToStr(CoordToMMs(Pad.TopYSize));

                  PadShape :='circle';
                  case (Pad.TopShape) of
                    1:PadShape :='circle';//(res['size'][0] == res['size'][1]) ? 'circle' : 'oval';
                    2:PadShape :='rect';
                    //3:PadShape :='chamfrect';
                    9:PadShape :='roundrect';
//                default:
                    //res['shape'] :='custom';
                  end;
                end
                else
                if (Pad.Layer = eBottomLayer) then
                begin
                  PadLayer := 'BottomLayer';
                  PadType := 'smd';
                  PadWidth := FloatToStr(CoordToMMs(Prim.BotXSize));
                  PadHeight := FloatToStr(CoordToMMs(Prim.BotYSize));
                  PadShape :='circle';
                  case (Pad.BotShape) of
                    1:PadShape :='circle';//(res['size'][0] == res['size'][1]) ? 'circle' : 'oval';
                    2:PadShape :='rect';
                    //3:PadShape :='chamfrect';
                    9:PadShape :='roundrect';
//                default:
                    //res['shape'] :='custom';
                  end;
                end
                else
                begin
                  PadLayer := 'MultiLayer';
                  PadType := 'th';
                  PadWidth := FloatToStr(CoordToMMs(Prim.TopXSize));
                  PadHeight := FloatToStr(CoordToMMs(Prim.TopYSize));
                  //TODO: Is it norm?
                  PadShape :='circle';
                  case (Pad.TopShape) of
                    1:PadShape :='circle';//(res['size'][0] == res['size'][1]) ? 'circle' : 'oval';
                    2:PadShape :='rect';
                    //3:PadShape :='chamfrect';
                    9:PadShape :='roundrect';
//                default:
                    //res['shape'] :='custom';
                  end;
                  case (Pad.BotShape) of
                    1:PadShape :='circle';//(res['size'][0] == res['size'][1]) ? 'circle' : 'oval';
                    2:PadShape :='rect';
                    //3:PadShape :='chamfrect';
                    9:PadShape :='roundrect';
//                default:
                    //res['shape'] :='custom';
                  end;

                  case (Pad.HoleType) of
                0: // circle
                begin
                    //res["drillsize"] = [CoordToMMs(Prim.HoleSize).round(), CoordToMMs(Prim.HoleSize).round()];
                    PadDrillShape := 'circle';
                    end;
                1: // square, but not supported in kicad, so do as circle
                begin
                    //res["drillsize"] = [CoordToMMs(Prim.HoleSize).round(), CoordToMMs(Prim.HoleSize).round()];
                    PadDrillShape := 'circle';
                    end;
                2: // slot
                begin
                    //res["drillsize"] = [CoordToMMs(Prim.HoleWidth).round(), CoordToMMs(Prim.HoleSize).round()];
                    PadDrillShape := 'oblong';
                    end;
                //default:  //
                end;

                end;

                PadPin1 := '0';
                if (Pad.Name = '1') then
                //if ("A1".indexOf(Pad.Name) != -1) then
                begin
                  PadPin1 := '1';
                end;

                PadWidth := StringReplace(PadWidth, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
                PadHeight := StringReplace(PadHeight, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

                PadX := FloatToStr(CoordToMMs(Pad.X - Board.XOrigin));
                PadY := FloatToStr(-CoordToMMs(Pad.Y - Board.YOrigin));

                PadX := StringReplace(PadX, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
                PadY := StringReplace(PadY, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

                PadAngle := FloatToStr(Pad.Rotation);
                PadAngle := StringReplace(PadAngle, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

                PnPout.Add('"Layer":'+'"'+Preprocess(PadLayer)+'"'+',');
                PnPout.Add('"Type":'+'"'+Preprocess(PadType)+'"'+',');
                PnPout.Add('"Shape":'+'"'+Preprocess(PadShape)+'"'+',');
                if PadType='th' then
                begin
                PnPout.Add('"DrillShape":'+'"'+Preprocess(PadDrillShape)+'"'+',');
                end;
               // PnPout.Add('"Debug":'+'"'+Preprocess(Prim.Layer)+'"'+',');
                PnPout.Add('"X":'+'"'+Preprocess(PadX)+'"'+',');
                PnPout.Add('"Y":'+'"'+Preprocess(PadY)+'"'+',');
                PnPout.Add('"Width":'+'"'+Preprocess(PadWidth)+'"'+',');
                PnPout.Add('"Height":'+'"'+Preprocess(PadHeight)+'"'+',');
                PnPout.Add('"Angle":'+'"'+Preprocess(PadAngle)+'"'+',');
                PnPout.Add('"Pin1":'+'"'+Preprocess(PadPin1)+'"');

                PnPout.Add('}');
                //pads :=pads.concat(parsePad(Prim));
                //if (isSMD and (Prim.Layer = eMultiLayer)) then begin
                //isSMD :=false;
                //end;
                Prim :=Iter.NextPCBObject;
                end;
                Component.GroupIterator_Destroy(Iter);

                PnPout.Add(']');

                PnPout.Add('}');
           End;
        Component := Iterator.NextPCBObject;
    End;
    Board.BoardIterator_Destroy(Iterator);

    PnPout.Add('],');
    PnPout.Add('"Board":[');

    Count := 0;

    Iter :=Board.BoardIterator_Create;
    //Iter.AddFilter_ObjectSet(eTrackObject);
    Iter.AddFilter_LayerSet(MkSet(eKeepOutLayer));
    Iter.AddFilter_ObjectSet(MkSet(eArcObject, eTrackObject));
    //Iter.AddFilter_ObjectSet(MkSet(eTrackObject));
    {Iter.AddFilter_LayerSet(MkSet(pcb.Layers.OUTLINE_LAYER));}
    Iter.AddFilter_Method(eProcessAll);
    Prim :=Iter.FirstPCBObject;
    while (Prim <> nil) do
    begin
      Inc(Count);
      If (Count>1) Then
        PnPout.Add(',');

      case (Prim.ObjectId) of
         eArcObject:
         begin
                 //   ;{edges.push(parseArc(Prim));}
          EdgeWidth := FloatToStr(CoordToMMs(Prim.LineWidth));
          EdgeX1 := FloatToStr(CoordToMMs(Prim.XCenter - Board.XOrigin));
          EdgeY1 := FloatToStr(-CoordToMMs(Prim.YCenter - Board.YOrigin));
          EdgeX2 := FloatToStr(-Prim.EndAngle);
          EdgeY2 := FloatToStr(-Prim.StartAngle);
          EdgeRadius := FloatToStr(CoordToMMs(Prim.Radius));

          EdgeWidth := StringReplace(EdgeWidth, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeX1 := StringReplace(EdgeX1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeY1 := StringReplace(EdgeY1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeX2 := StringReplace(EdgeX2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeY2 := StringReplace(EdgeY2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeRadius := StringReplace(EdgeRadius, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

           EdgeType := 'arc';
           PnPout.Add('{');
           PnPout.Add('"Type":'+'"'+Preprocess(EdgeType)+'"'+',');
           PnPout.Add('"Width":'+'"'+Preprocess(EdgeWidth)+'"'+',');
           PnPout.Add('"X":'+'"'+Preprocess(EdgeX1)+'"'+',');
           PnPout.Add('"Y":'+'"'+Preprocess(EdgeY1)+'"'+',');
           PnPout.Add('"Angle1":'+'"'+Preprocess(EdgeX2)+'"'+',');
           PnPout.Add('"Angle2":'+'"'+Preprocess(EdgeY2)+'"'+',');
           PnPout.Add('"Radius":'+'"'+Preprocess(EdgeRadius)+'"');
           PnPout.Add('}');
         end;
         eTrackObject:
         begin
                 //  JSONPush(edges,parseTrack(Prim));
                         {
var start = [CoordToMMs(Prim.x1).round(), -CoordToMMs(Prim.y1).round()];
        var end = [CoordToMMs(Prim.x2).round(), -CoordToMMs(Prim.y2).round()];
        res["layer"] = Prim.Layer;
        if (Prim.InPolygon)
            res["type"] = "polygon";
            res["svgpath"] = ["M", start, "L", end].join(" ");
     else             res["type"] = "segment";
            res["start"] = start;
            res["end"] = end;
            res["width"] = CoordToMMs(Prim.Width).round();
                        }

          EdgeWidth := FloatToStr(CoordToMMs(Prim.Width));
          EdgeX1 := FloatToStr(CoordToMMs(Prim.X1 - Board.XOrigin));
          EdgeY1 := FloatToStr(-CoordToMMs(Prim.Y1 - Board.YOrigin));
          EdgeX2 := FloatToStr(CoordToMMs(Prim.X2 - Board.XOrigin));
          EdgeY2 := FloatToStr(-CoordToMMs(Prim.Y2 - Board.YOrigin));

          EdgeWidth := StringReplace(EdgeWidth, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeX1 := StringReplace(EdgeX1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeY1 := StringReplace(EdgeY1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeX2 := StringReplace(EdgeX2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeY2 := StringReplace(EdgeY2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

           EdgeType := 'segment';
           PnPout.Add('{');
           PnPout.Add('"Type":'+'"'+Preprocess(EdgeType)+'"'+',');
           PnPout.Add('"Width":'+'"'+Preprocess(EdgeWidth)+'"'+',');
           PnPout.Add('"X1":'+'"'+Preprocess(EdgeX1)+'"'+',');
           PnPout.Add('"Y1":'+'"'+Preprocess(EdgeY1)+'"'+',');
           PnPout.Add('"X2":'+'"'+Preprocess(EdgeX2)+'"'+',');
           PnPout.Add('"Y2":'+'"'+Preprocess(EdgeY2)+'"');

           PnPout.Add('}');
         end;
      end;

      Prim :=Iter.NextPCBObject;
    end;
    Board.BoardIterator_Destroy(Iter);

    PnPout.Add('],');
    PnPout.Add('"BB":{');

//            var bbox = {};
//        bbox["minx"] = CoordToMMs(Board.BoardOutline.BoundingRectangle.Left).round();
//        bbox["miny"] = -CoordToMMs(pcb.board.BoardOutline.BoundingRectangle.Top).round();
//        bbox["maxx"] = CoordToMMs(pcb.board.BoardOutline.BoundingRectangle.Right).round();
//        bbox["maxy"] = -CoordToMMs(pcb.board.BoardOutline.BoundingRectangle.Bottom).round();

    EdgeX1 := FloatToStr(CoordToMMs(Board.BoardOutline.BoundingRectangle.Left- Board.XOrigin));
    EdgeY1 := FloatToStr(-CoordToMMs(Board.BoardOutline.BoundingRectangle.Top- Board.YOrigin));
    EdgeX2 := FloatToStr(CoordToMMs(Board.BoardOutline.BoundingRectangle.Right- Board.XOrigin));
    EdgeY2 := FloatToStr(-CoordToMMs(Board.BoardOutline.BoundingRectangle.Bottom- Board.YOrigin));

    EdgeX1 := StringReplace(EdgeX1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
    EdgeY1 := StringReplace(EdgeY1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
    EdgeX2 := StringReplace(EdgeX2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
    EdgeY2 := StringReplace(EdgeY2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

    PnPout.Add('"X1":'+'"'+Preprocess(EdgeX1)+'"'+',');
    PnPout.Add('"Y1":'+'"'+Preprocess(EdgeY1)+'"'+',');
    PnPout.Add('"X2":'+'"'+Preprocess(EdgeX2)+'"'+',');
    PnPout.Add('"Y2":'+'"'+Preprocess(EdgeY2)+'"');

    PnPout.Add('},');
    PnPout.Add('"Extra":[');

    Count := 0;

    Iter :=Board.BoardIterator_Create;
    //Iter.AddFilter_ObjectSet(eTrackObject);
    Iter.AddFilter_LayerSet(MkSet(eTopOverlay,eBottomOverlay));
    Iter.AddFilter_ObjectSet(MkSet(eArcObject, eTrackObject));
    //Iter.AddFilter_ObjectSet(MkSet(eTrackObject));
    {Iter.AddFilter_LayerSet(MkSet(pcb.Layers.OUTLINE_LAYER));}
    Iter.AddFilter_Method(eProcessAll);
    Prim :=Iter.FirstPCBObject;
    while (Prim <> nil) do
    begin
      Inc(Count);
      If (Count>1) Then
        PnPout.Add(',');

      case (Prim.ObjectId) of
         eArcObject:
        begin
                 //   ;{edges.push(parseArc(Prim));}

              //               res["type"] = "arc";
            //res["width"] = width;
            //res["startangle"] = -Prim.EndAngle.round();
            //res["endangle"] = -Prim.StartAngle.round();
            //res["start"] = [CoordToMMs(Prim.XCenter).round(), -CoordToMMs(Prim.YCenter).round()];


          EdgeWidth := FloatToStr(CoordToMMs(Prim.LineWidth));
          EdgeX1 := FloatToStr(CoordToMMs(Prim.XCenter - Board.XOrigin));
          EdgeY1 := FloatToStr(-CoordToMMs(Prim.YCenter - Board.YOrigin));
          EdgeX2 := FloatToStr(-Prim.EndAngle);
          EdgeY2 := FloatToStr(-Prim.StartAngle);
          EdgeRadius := FloatToStr(CoordToMMs(Prim.Radius));

          EdgeWidth := StringReplace(EdgeWidth, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeX1 := StringReplace(EdgeX1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeY1 := StringReplace(EdgeY1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeX2 := StringReplace(EdgeX2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeY2 := StringReplace(EdgeY2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeRadius := StringReplace(EdgeRadius, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

          If (Prim.Layer = eTopOverlay) Then
            Layer := 'TopOverlay'
          Else If (Prim.Layer = eBottomOverlay) Then
            Layer := 'BottomOverlay';

           EdgeType := 'arc';
           PnPout.Add('{');
           PnPout.Add('"Layer":'+'"'+Preprocess(Layer)+'"'+',');
           PnPout.Add('"Type":'+'"'+Preprocess(EdgeType)+'"'+',');
           PnPout.Add('"Width":'+'"'+Preprocess(EdgeWidth)+'"'+',');
           PnPout.Add('"X":'+'"'+Preprocess(EdgeX1)+'"'+',');
           PnPout.Add('"Y":'+'"'+Preprocess(EdgeY1)+'"'+',');
           PnPout.Add('"Angle1":'+'"'+Preprocess(EdgeX2)+'"'+',');
           PnPout.Add('"Angle2":'+'"'+Preprocess(EdgeY2)+'"'+',');
           PnPout.Add('"Radius":'+'"'+Preprocess(EdgeRadius)+'"');
           PnPout.Add('}');
         end;
         eTrackObject:
         begin
                 //  JSONPush(edges,parseTrack(Prim));
                         {
var start = [CoordToMMs(Prim.x1).round(), -CoordToMMs(Prim.y1).round()];
        var end = [CoordToMMs(Prim.x2).round(), -CoordToMMs(Prim.y2).round()];
        res["layer"] = Prim.Layer;
        if (Prim.InPolygon)
            res["type"] = "polygon";
            res["svgpath"] = ["M", start, "L", end].join(" ");
     else             res["type"] = "segment";
            res["start"] = start;
            res["end"] = end;
            res["width"] = CoordToMMs(Prim.Width).round();
                        }

          EdgeWidth := FloatToStr(CoordToMMs(Prim.Width));
          EdgeX1 := FloatToStr(CoordToMMs(Prim.X1 - Board.XOrigin));
          EdgeY1 := FloatToStr(-CoordToMMs(Prim.Y1 - Board.YOrigin));
          EdgeX2 := FloatToStr(CoordToMMs(Prim.X2 - Board.XOrigin));
          EdgeY2 := FloatToStr(-CoordToMMs(Prim.Y2 - Board.YOrigin));

          EdgeWidth := StringReplace(EdgeWidth, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeX1 := StringReplace(EdgeX1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeY1 := StringReplace(EdgeY1, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeX2 := StringReplace(EdgeX2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));
          EdgeY2 := StringReplace(EdgeY2, ',', '.', MkSet(rfReplaceAll,rfIgnoreCase));

          If (Prim.Layer = eTopOverlay) Then
            Layer := 'TopOverlay'
          Else If (Prim.Layer = eBottomOverlay) Then
            Layer := 'BottomOverlay';

           EdgeType := 'segment';
           PnPout.Add('{');
           PnPout.Add('"Layer":'+'"'+Preprocess(Layer)+'"'+',');
           PnPout.Add('"Type":'+'"'+Preprocess(EdgeType)+'"'+',');
           PnPout.Add('"Width":'+'"'+Preprocess(EdgeWidth)+'"'+',');
           PnPout.Add('"X1":'+'"'+Preprocess(EdgeX1)+'"'+',');
           PnPout.Add('"Y1":'+'"'+Preprocess(EdgeY1)+'"'+',');
           PnPout.Add('"X2":'+'"'+Preprocess(EdgeX2)+'"'+',');
           PnPout.Add('"Y2":'+'"'+Preprocess(EdgeY2)+'"');
           PnPout.Add('}');
         end;
      end;

      Prim :=Iter.NextPCBObject;
    end;
    Board.BoardIterator_Destroy(Iter);

    PnPout.Add('],');
    PnPout.Add('"Metadata":{');

    PnPout.Add('"Company":'+'"'+Preprocess('todo1')+'"'+',');
    PnPout.Add('"Date":'+'"'+Preprocess('todo2')+'"'+',');
    PnPout.Add('"Revision":'+'"'+Preprocess('todo3')+'"'+',');
    PnPout.Add('"Title":'+'"'+Preprocess('todo4')+'"'+',');

    PnPout.Add('}');
    PnPout.Add('};');

    // Display the Pick&Place report
    //FileName := ChangeFileExt(Board.FileName,'.pic');
    //PnPout.SaveToFile(GetOutputFileNameWithExtension('.js'));
    //PnPout.SaveToFile(LALALALA('pcbdata.js'));
    //PnPout.SaveToFile(Filename);
    Result := PnPout.Text;

    PnPout.Free;



    {
    Document  := Client.OpenDocument('Text', FileName);
    If Document <> Nil Then
        Client.ShowDocument(Document);

    ShowMessage(IntToStr(Count) + ' were exported to Pick and Place file:' + #13 + Board.FileName + '.pic');
    }
End;

function GetWDFileName(FF:String): String;
var
  i: Integer;
  Path: String;
  CurrentDir: String;
  Document: IDocument;
begin
  Result := FF;
  if not IsPathRelative(FF) then
    Exit;

  Result := ExpandFileName(FF);

  for i := 0 to CurrProject.DM_LogicalDocumentCount - 1 do
  begin
    Document := CurrProject.DM_LogicalDocuments(i);
    if Document.DM_FileName <> 'InteractiveHTMLBOM4Altium2.pas' then
      continue;

    Path := ExtractFilePath(Document.DM_FullPath);
    if not DirectoryExists(Path) then
      continue;

    CurrentDir := GetCurrentDir;
    if not SetCurrentDir(Path) then
      continue;

    Result := ExpandFileName(FF);
    SetCurrentDir(CurrentDir);
  end;
end;

function StringLoadFromFile(Filename:String):String;
var
  S: TStringList;
begin
  S := TStringList.Create;
  S.LoadFromFile(Filename);
  Result := S.Text;
  S.Free;
end;

function ReplaceEx(a,c,Filename:String):String;
var
  S: TStringList;
  e: String;
  i:Integer;
begin
  S := TStringList.Create;
  S.LoadFromFile(Filename);
  e := S.Text;
  S.Free;

  Result := StringReplace(a, '///'+c+'///', e, MkSet(rfReplaceAll,rfIgnoreCase));
   //Result := StringReplace(a, '///'+'SPLITJS', e, MkSet(rfReplaceAll,rfIgnoreCase));
end;

function ReplaceEx2(a,c,e:String):String;
begin

  Result := StringReplace(a, '///'+c+'///', e, MkSet(rfReplaceAll,rfIgnoreCase));
   //Result := StringReplace(a, '///'+'SPLITJS', e, MkSet(rfReplaceAll,rfIgnoreCase));
end;

procedure Gener(pcbdata:String);
var
  S: TStringList;
  Data: String;
begin
  S := TStringList.Create;
  S.LoadFromFile(GetWDFileName('web\ibom.html'));
  Data := S.Text;
  S.Free;

  Data := ReplaceEx(Data,'CSS',GetWDFileName('web\ibom.css'));
  Data := ReplaceEx(Data,'USERCSS',GetWDFileName('web\user-file-examples\user.css'));
  Data := ReplaceEx(Data,'SPLITJS',GetWDFileName('web\split.js'));
  Data := ReplaceEx(Data,'LZ-STRING',GetWDFileName('web\lz-string.js'));
  Data := ReplaceEx(Data,'POINTER_EVENTS_POLYFILL',GetWDFileName('web\pep.js'));
  //Data := ReplaceEx(Data,'CONFIG',AddSlash(TargetFolder) + TargetPrefix+'config.js');
  Data := ReplaceEx(Data,'CONFIG',GetWDFileName('config.js'));
  Data := ReplaceEx2(Data,'PCBDATA',pcbdata+#13#10+#13#10+StringLoadFromFile(GetWDFileName('helper.js')));
  Data := ReplaceEx(Data,'UTILJS',GetWDFileName('web\util.js'));
  Data := ReplaceEx(Data,'RENDERJS',GetWDFileName('web\render.js'));
  Data := ReplaceEx(Data,'TABLEUTILJS',GetWDFileName('web\table-util.js'));
  Data := ReplaceEx(Data,'IBOMJS',GetWDFileName('web\ibom.js'));
  Data := ReplaceEx(Data,'USERJS',GetWDFileName('web\user-file-examples\user.js'));
  Data := ReplaceEx(Data,'USERHEADER',GetWDFileName('web\user-file-examples\userheader.html'));
  Data := ReplaceEx(Data,'USERFOOTER',GetWDFileName('web\user-file-examples\userfooter.html'));

  S := TStringList.Create;
  S.Text := Data;
  S.SaveToFile(GetOutputFileNameWithExtension('.html'));
  S.Free;
end;

procedure SetupProjectVariant(Dummy: Integer);
Var
  ProjVarIndex: Integer; // Index for iterating through variants
  TempVariant: IProjectVariant; // A temporary Handle for a ProjectVariant
Begin
  ProjectVariant := CurrProject.DM_CurrentProjectVariant;
  {
    // Determine how many ProjectVariants are defined within this focussed Project
    ProjectVariantCount := CurrProject.DM_ProjectVariantCount;
    ProjectVariant := Nil;

    // Find the Project Variant matching the Variants Combo-Box
    For ProjVarIndex := 0 To ProjectVariantCount - 1 Do
    Begin
    // Fetch the currently indexed project Assembly Variant
    TempVariant := CurrProject.DM_ProjectVariants[ ProjVarIndex ];

    // See if the Description matches that in the Variants Combo-Box
    If (VariantName = TempVariant.DM_Description)
    Then ProjectVariant := CurrProject.DM_ProjectVariants[ ProjVarIndex ];
    End;
  }
End;

Function UseIt(_CurrComponent: IComponent;
  _ProjectVariant: IProjectVariant): Boolean;
var
  _CurrPart: IPart;
  ComponentVariation: IComponentVariation;
begin
  // [!!!] UGLY
  _CurrPart := _CurrComponent.DM_SubParts[0];
  if _ProjectVariant = nil then
  begin
    if pos('@', _CurrComponent.DM_UniqueId) <> 0 then
    begin
      Result := False;
    end
    else
    begin
      Result := True;
    end;
  end;

  if _ProjectVariant <> nil then
  begin
    ComponentVariation := _ProjectVariant.DM_FindComponentVariationByDesignator
      (_CurrPart.DM_PhysicalDesignator);
    if ComponentVariation <> nil then
    begin
      if _CurrComponent.DM_UniqueId <> ComponentVariation.DM_UniqueId + '@' +
        _ProjectVariant.DM_Description then
      begin
        Result := False;
      end
      else
      begin
        Result := True;
      end;
      // [!!!] Never
      if ComponentVariation.DM_VariationKind = eVariation_NotFitted then
      begin
        Result := False;
      end;
    end
    else
    begin
      if pos('@', _CurrComponent.DM_UniqueId) <> 0 then
      begin
        Result := False;
      end
      else
      begin
        Result := True;
      end;
    end;
  end;
end;

procedure FetchComponents(Dummy: Integer);
Var
  CompIndex: Integer; // An Index for pullin out components
  PhysCompCount: Integer; // A count of the number of components in document
  PhysComponent: IComponent; // An Interface handle to the current Component
  PhysCompIndex: Integer; // An index for pulling out Physical Parts
  CurrPart: IPart; // An Interface handle to the current Part of a Component
  CurrSortStr: String; // A String to hold the sorting field
  CurrPhysDesStr: String; // A String to hold the current Physical Designator
  CurrFootprintStr: String; // A String to hold the current Footprint
  CurrDescrStr: String; // A String to hold the current Description
  CurrLibRefStr: String; // A String to hold the current Library Reference
  CurrStuffedStr: String;
  // A String to hold the Stuffed flag for the currrent component
  FormatStr: String; // A String into which one part's data can be formatted
  TempStrg: String; // A temporary string for formatting
  TempChar: String; // A temporary string for one Char when formatting
  SortLetters: String; // A string for letters of the designator prefix
  SortNumbers: String; // A string for numbers of the designator
  SortRest: String; // A string for the rest of the designator
  SortLetrWid: Integer; // Width of the sort letters column
  SortNumbWid: Integer; // Width of the sort Numbers column
  SortRestWid: Integer; // Width of the sort Rest column
  SortWid: Integer; // Width of the entire sort field
  SortStart: Integer; // Start of the entire sort field
  SortCount: Integer; // Number of characters in the Physical Designator
  SortEnd: Integer; // End of the entire sort field
  LetrDone: Boolean; // Flag for processing designator prefix letters
  NumbDone: Boolean; // Flag for processing designator prefix numbers
  RestDone: Boolean;
  // Flag for processing the rest of the designator characters
  SortIndex: Integer; // Temporary Index for chars in the Designator
  CompCount: Integer; // The Number of Components Flattened Document
  CompListIndex: Integer; // An index for strings in CompList
  i: Integer;
  _n: IParameter;
  _nn: string;
  _vv: string;
  _ss: TStringList;
  _pp: TStringList;
  ParmIndex: Integer;
  ParmCount: Integer; // The Number of Parameters in Component
  CurrParm: IParameter; // An interface handle to a Parameter
  iii: Integer;
  Line: String;
  ComponentVariation: IComponentVariation;

Begin
  // Establish fields in Component List
  SortLetrWid := 10;
  SortNumbWid := 10;
  SortRestWid := 50;
  SortWid := SortLetrWid + SortNumbWid + SortRestWid;
  // LibRefWid := 30;
  // DescriptionWid := 50;
  // FootprintWid := 50;
  // PhysicalDesWid := 30;
  // StuffedWid := 1;
  // LibRefStart := 1;
  // SortStart := LibRefStart + LibRefWid;
  // DescriptionStart := SortStart + SortWid;
  // FootprintStart := DescriptionStart + DescriptionWid;
  // PhysicalDesStart := FootprintStart + FootprintWid;
  // S/tuffedStart := PhysicalDesStart + PhysicalDesWid;
  // L/ibRefEnd := SortStart - 1;
  // SortEnd := DescriptionStart - 1;
  // DescriptionEnd := FootprintStart - 1;
  // FootprintEnd := PhysicalDesStart - 1;
  // PhysicalDesEnd := StuffedStart - 1;
  // StuffedEnd := StuffedStart + StuffedWid - 1;

  // Fetch the Flattened schematic sheet document.  This is a fictitious document
  // generated when the project is compiled containing all components from all
  // sheets.  This is much more useful for making lists of everything than rummaging
  // through all the sheets one at a time.  This sheet is not graphical in that
  // it cannot be viewed like a schematic, but you can view what's in it by using
  // the Navigator panel.
  FlattenedDoc := CurrProject.DM_DocumentFlattened;

  // If we couldn't get the flattened sheet, then most likely the project has
  // not been compiled recently
  If (FlattenedDoc = Nil) Then
  Begin
    // First try compiling the project
    AddStringParameter('Action', 'Compile');
    AddStringParameter('ObjectKind', 'Project');
    RunProcess('WorkspaceManager:Compile');

    // Try Again to open the flattened document
    FlattenedDoc := CurrProject.DM_DocumentFlattened;
    If (FlattenedDoc = Nil) Then
    Begin
      ShowMessage('NOTICE: Compile the Project before Running this report.');
      Close;
      Exit;
    End; // If (FlattenedDoc = Nil) Then
  End; // If (FlattenedDoc = Nil) Then

  // Now that we have the flattened document, check how many components are in it
  CompCount := FlattenedDoc.DM_ComponentCount;

  // Set Up Progress Bar
  {
    ProgressBar.Min      := 0;
    ProgressBar.Max      := CompCount - 1;
    ProgressBar.Step     := 1;
    ProgressBar.Position := 0;
    ProgressBar.Visible  := True;
  }
  _pp := TStringList.Create;
  _pp.Sorted := True;
  _pp.Duplicates := dupIgnore;
  For CompIndex := 0 To CompCount - 1 Do
  Begin
    CurrComponent := FlattenedDoc.DM_Components[CompIndex];
    ParmCount := CurrComponent.DM_ParameterCount;
    For ParmIndex := 0 To ParmCount - 1 Do
    Begin
      CurrParm := CurrComponent.DM_Parameters(ParmIndex);
      _pp.Add(CurrParm.DM_Name);
    End;
  end;

  _ss := TStringList.Create;

  Line := 'Designator' + ',' + 'Quantity' + ',';
  For iii := 0 To _pp.Count - 1 Do
  begin
    Line := Line + _pp[iii];
    if iii <> _pp.Count - 1 then
      Line := Line + ',';
  end;
  _ss.Add(Line);

  // Walk through every component one-by-one pulling out needed information and
  // writing it into the component string list
  For CompIndex := 0 To CompCount - 1 Do
  Begin
    CurrComponent := FlattenedDoc.DM_Components[CompIndex];

    // Update Progress Bar
    // ProgressBar.Position := CompIndex;

    // Much information about the component can only be retrieved by examining
    // one the its sub-parts (Strange, but true.)
    CurrPart := CurrComponent.DM_SubParts[0];

    // Create the Sort String
    // Initialize the sort strings and flags
    SortLetters := '';
    SortNumbers := '';
    SortRest := '';
    LetrDone := False;
    NumbDone := False;
    RestDone := False;

    // Fetch the physical designator string so we can parse it
    TempStrg := Trim(CurrPart.DM_PhysicalDesignator);
    SortCount := Length(TempStrg);

    // Determine how many parameters it has
    ParmCount := CurrComponent.DM_ParameterCount;
    // CurrComponent.DM_GetParameterByName();

    CurrParm := CurrComponent.DM_GetParameterByName('Component Kind');
    if (CurrParm <> nil) and (CurrParm.DM_Value = 'Standard (No BOM)') then
    begin
      continue;
    end;
    // [!!!] UGLY
    CurrParm := CurrComponent.DM_GetParameterByName('Cat_Name');
    if (CurrParm <> nil) and (CurrParm.DM_Value = 'Реперная метка') then
    begin
      continue;
    end;
    if not UseIt(CurrComponent, ProjectVariant) then
      continue;
    Line := '"' + CurrPart.DM_PhysicalDesignator + '"' + ',' + '"' + '1' +
      '"' + ',';
    // Begin walking through parameters to find the specified one
    For iii := 0 To _pp.Count - 1 Do
    begin
      CurrParm := CurrComponent.DM_GetParameterByName(_pp[iii]);
      if CurrParm <> nil then
      begin
        Line := Line + '"' + CurrParm.DM_Value + '"';
        // _nn := CurrParm.DM_Name;
        // _vv := CurrParm.DM_Value;
        // _ss.Add(TempStrg+'.'+_nn+'='+_vv);
      end
      else
      begin
        Line := Line + '"' + '"';
        // _nn := _pp[iii];
        // _vv := 'null';
        // _ss.Add(TempStrg+'.'+_nn+'='+_vv);
      end;
      if iii <> _pp.Count - 1 then
        Line := Line + ',';
    end;
    _ss.Add(Line);
    {
      For ParmIndex := 0 To ParmCount - 1 Do
      Begin
      // Fetch one of the component's Parameters
      CurrParm := CurrComponent.DM_Parameters( ParmIndex );
      _nn := CurrParm.DM_Name;
      _vv := CurrParm.DM_Value;
      _ss.Add(TempStrg+'.'+_nn+'='+_vv);
      End; }

    {
      // Now iterate through its characters
      For SortIndex := 1 To SortCount Do
      Begin
      // Fetch the next character
      TempChar := Copy( TempStrg, SortIndex, 1 );

      // If processing prefix letters:
      If (LetrDone = False)
      Then
      Begin
      // See if it is a letter and will fit
      If ( ( ((TempChar >= 'A') And (TempChar <= 'Z'))
      Or ((TempChar >= 'a') And (TempChar <= 'z')) )
      And (Length( SortLetters ) < SortLetrWid) )
      Then SortLetters := SortLetters + TempChar
      Else LetrDone := True;
      End; // If (LetrDone = False)

      // If processing the prefix numbers:
      If ((LetrDone = True) And (NumbDone = False))
      Then
      Begin
      // See if it is a number and will fit
      If ( ((TempChar >= '0') And (TempChar <= '9'))
      And (Length( SortNumbers ) < SortNumbWid) )
      Then SortNumbers := SortNumbers + TempChar
      Else NumbDone := True;
      End; // If ((LetrDone = True) And (NumbDone = False))

      // If processing the rest of the physical designator:
      If ((LetrDone = True) And (NumbDone = True) And (RestDone = False))
      Then
      Begin
      // See if there is room for the rest of it
      If (Length( SortRest ) < SortRestWid)
      Then SortRest := SortRest + TempChar
      Else RestDone := True;
      End; // If ((LetrDone = True) And (NumbDone = True) And (RestDone = False))
      End; // For (SortIndex := 1 To SortWid Do

      // Now create the sort formatted string
      TempStrg :=
      SortLetters
      + StringOfChar( ' ', SortLetrWid - Length( SortLetters ) )
      + StringOfChar( '0', SortNumbWid - Length( SortNumbers ) )
      + SortNumbers
      + SortRest
      + StringOfChar( ' ', SortRestWid - Length( SortRest    ) );
    }
    {
      // Exactly fill the Sorting field
      If ( Length( TempStrg ) > SortWid) // If too long
      Then TempStrg := Copy( TempStrg, 1, SortWid );
      CurrSortStr := TempStrg + StringOfChar( ' ', SortWid - Length( TempStrg ) ); // Pad if needed

      // Exactly fill the Library Reference field
      TempStrg := Trim( CurrPart.DM_LibraryReference );
      If ( Length( TempStrg ) > LibRefWid) // If too long
      Then TempStrg := Copy( TempStrg, 1, LibRefWid );
      CurrLibRefStr := TempStrg + StringOfChar( ' ', LibRefWid - Length( TempStrg ) ); // Pad if needed

      // Exactly fill the Description field
      TempStrg := Trim( CurrPart.DM_Description );
      If ( Length( TempStrg ) > DescriptionWid) // If too long
      Then TempStrg :=  Copy( TempStrg, 1, DescriptionWid );
      CurrDescrStr := TempStrg + StringOfChar( ' ', DescriptionWid - Length( TempStrg ) ); // Pad if needed

      // Exactly fill the Footprint field
      TempStrg := Trim( CurrPart.DM_Footprint );
      If ( Length( TempStrg ) > FootprintWid) // If too long
      Then TempStrg :=  Copy( TempStrg, 1, FootprintWid );
      CurrFootprintStr := TempStrg + StringOfChar( ' ', FootprintWid - Length( TempStrg ) ); // Pad if needed

      // Exactly fill the Physical Designator field
      TempStrg := Trim( CurrPart.DM_PhysicalDesignator );
      If ( Length( TempStrg ) > PhysicalDesWid) // If too long
      Then TempStrg :=  Copy( TempStrg, 1, PhysicalDesWid );
      CurrPhysDesStr := TempStrg + StringOfChar( ' ', PhysicalDesWid - Length( TempStrg ) ); // Pad if needed

      // Exactly fill the Stuffed flag field
      If Stuffed( CurrPart.DM_PhysicalDesignator )
      Then CurrStuffedStr   := 'Y'
      Else CurrStuffedStr   := 'N';

      // Format the collected data
      FormatStr :=
      CurrLibRefStr
      + CurrSortStr
      + CurrDescrStr
      + CurrFootprintStr
      + CurrPhysDesStr
      + CurrStuffedStr; }

    // Add it to the string list
    // CompList.Add := FormatStr;
  End; // For CompIndex := 0 To CompCount - 1 Do

  // Sort the string list (ASCII Ordered left to right)
  // CompList.Sort;

  // Record how many records ar in the list for later processing control
  // CompListCount := CompList.Count;

  // Hide Progress Bar
  // ProgressBar.Visible  := False;

  //_ss.SaveToFile(GetOutputFileNameWithExtension('.csv.txt'));
  _ss.Free;

End; // procedure FetchComponents( Dummy: Integer );

Procedure InitializeProject(Dummy: Integer);
Var
  ProjVarIndex: Integer; // Index for iterating through variants
Begin
  // Make sure the current Workspace opens or else quit this script
  CurrWorkSpace := GetWorkSpace;
  If (CurrWorkSpace = Nil) Then
    Exit;

  // Make sure the currently focussed Project in this Workspace opens or else
  // quit this script
  CurrProject := CurrWorkSpace.DM_FocusedProject;
  If CurrProject = Nil Then
    Exit;

  // [!!!]
  SetupProjectVariant(0);
  {
    // Determine how many Assembly Variants are defined within this focussed Project
    ProjectVariantCount := CurrProject.DM_ProjectVariantCount;

    // Process each Project Assembly Variant sequentially
    For ProjVarIndex := 0 To ProjectVariantCount - 1 Do
    Begin
    // Fetch the currently indexed project Assembly Variant
    ProjectVariant := CurrProject.DM_ProjectVariants[ ProjVarIndex ];
    VariantsComboBox.Items.Add( ProjectVariant.DM_Description );
    End;

    // Choose first variant to start with
    VariantsComboBox.ItemIndex := 0;
    ProjectVariant := CurrProject.DM_ProjectVariants[ 0 ];

    // Based on current settings on the form, re-write the description of what
    // action will be done when the OK button is pressed
    ReWriteActionLabel( 0 ); }
End;

procedure SetState_Controls;
Begin
  LayerFilterCb.ItemIndex := LayerFilterIndex;
  FieldSeparatorCb.ItemIndex := FieldSeparatorIndex;
  //PluginExecutableEdt.Text := PluginExecutable;
  /////////////////////////////////////////////////////////////
  {
    ParametersComboBox          .ItemIndex := ParametersComboBox.Items.IndexOf(ParameterName);
    VariantsComboBox            .ItemIndex := VariantsComboBox  .Items.IndexOf(VariantName);
    UseParametersRadioButton    .Checked   := UseParameters;
    UseVariantsRadioButton      .Checked   := UseVariants;
    FullyPopulatedRadioButton   .Checked   := FullyPopulated;
    CreateAgileBOMCheckBox      .Checked   := CreateAgileBOM;
    CreateEngineeringBOMCheckBox.Checked   := CreateEngineeringBOM;
  }
End;

Procedure SetState_FromParameters(AParametersList: String);
Var
  s: String;
Begin
  InitializeProject(0);
  {
    ParameterName        := '';
    VariantName          := '';
    UseParameters        := False;
    UseVariants          := False;
    FullyPopulated       := False;
    CreateAgileBOM       := False;
    CreateEngineeringBOM := False;
    OpenOutputs          := True;
    AddToProject         := True; }
  TargetFolder := '';
  TargetFileName := '';
  TargetPrefix := '';
  LayerFilterIndex := 0;
  FieldSeparatorIndex := 0;
  PluginExecutable := 'gostbomkompas.exe';
  {
    If GetState_Parameter(AParametersList, 'ParameterName'       , S) Then ParameterName        := S;
    If GetState_Parameter(AParametersList, 'VariantName'         , S) Then VariantName          := S;
    If GetState_Parameter(AParametersList, 'UseParameters'       , S) Then UseParameters        := StringsEqual(S, 'True');
    If GetState_Parameter(AParametersList, 'UseVariants'         , S) Then UseVariants          := StringsEqual(S, 'True');
    If GetState_Parameter(AParametersList, 'FullyPopulated'      , S) Then FullyPopulated       := StringsEqual(S, 'True');
    If GetState_Parameter(AParametersList, 'CreateAgileBOM'      , S) Then CreateAgileBOM       := StringsEqual(S, 'True');
    If GetState_Parameter(AParametersList, 'CreateEngineeringBOM', S) Then CreateEngineeringBOM := StringsEqual(S, 'True');
    If GetState_Parameter(AParametersList, 'OpenOutputs'         , S) Then OpenOutputs          := StringsEqual(S, 'True');
    If GetState_Parameter(AParametersList, 'AddToProject'        , S) Then AddToProject         := StringsEqual(S, 'True'); }
  If GetState_Parameter(AParametersList, 'TargetFileName', s) Then
    TargetFileName := s + '.PrjPcb';
  If GetState_Parameter(AParametersList, 'TargetFolder', s) Then
    TargetFolder := s;
  If GetState_Parameter(AParametersList, 'TargetPrefix', s) Then
    TargetPrefix := s;
  If GetState_Parameter(AParametersList, 'LayerFilterIndex', s) Then
    LayerFilterIndex := StrToInt(s);
  If GetState_Parameter(AParametersList, 'FieldSeparatorIndex', s) Then
    FieldSeparatorIndex := StrToInt(s);
  If GetState_Parameter(AParametersList, 'PluginExecutable', s) Then
    PluginExecutable := s;

  SetState_Controls;
End;

procedure GetState_Controls;
Begin
  {
    ParameterName         := ParametersComboBox.Items[ ParametersComboBox.ItemIndex ];
    VariantName           := VariantsComboBox  .Items[VariantsComboBox.ItemIndex];
    UseParameters         := UseParametersRadioButton    .Checked;
    UseVariants           := UseVariantsRadioButton      .Checked;
    FullyPopulated        := FullyPopulatedRadioButton   .Checked;
    CreateAgileBOM        := CreateAgileBOMCheckBox      .Checked;
  }
  LayerFilterIndex := LayerFilterCb.ItemIndex;
  FieldSeparatorIndex := FieldSeparatorCb.ItemIndex;
  //PluginExecutable := PluginExecutableEdt.Text;
  ///////////////////////////////////////////////
End;

Function GetState_FromParameters: String;
Begin
  GetState_Controls;

  Result := '';
  { Result := Result +       'ParameterName='        + ParameterName;
    Result := Result + '|' + 'VariantName='          + VariantName;
    Result := Result + '|' + 'UseParameters='        + BoolToStr(UseParameters       , True);
    Result := Result + '|' + 'UseVariants='          + BoolToStr(UseVariants         , True);
    Result := Result + '|' + 'FullyPopulated='       + BoolToStr(FullyPopulated      , True);
    Result := Result + '|' + 'CreateAgileBOM='       + BoolToStr(CreateAgileBOM      , True);
    Result := Result + '|' + 'CreateEngineeringBOM=' + BoolToStr(CreateEngineeringBOM, True);
  }
  Result := Result + '|' + 'LayerFilterIndex=' + IntToStr(LayerFilterIndex);
  Result := Result + '|' + 'FieldSeparatorIndex=' + IntToStr(FieldSeparatorIndex);
  Result := Result + '|' + 'PluginExecutable=' + PluginExecutable;
End;

procedure CreateFile(F: string);
var
  s: TStringList;
begin
  s := TStringList.Create;
  s.SaveToFile(F);
  s.Free;
end;

function GetPluginExecutableFileName: String;
var
  i: Integer;
  Path: String;
  CurrentDir: String;
  Document: IDocument;
begin
  Result := PluginExecutable;
  if not IsPathRelative(PluginExecutable) then
    Exit;

  Result := ExpandFileName(PluginExecutable);

  for i := 0 to CurrProject.DM_LogicalDocumentCount - 1 do
  begin
    Document := CurrProject.DM_LogicalDocuments(i);
    if Document.DM_FileName <> 'GOSTBOMAltium.pas' then
      continue;

    Path := ExtractFilePath(Document.DM_FullPath);
    if not DirectoryExists(Path) then
      continue;

    CurrentDir := GetCurrentDir;
    if not SetCurrentDir(Path) then
      continue;

    Result := ExpandFileName(PluginExecutable);
    SetCurrentDir(CurrentDir);
  end;
end;

procedure Generate(Parameters: String);
var
  f2, f5, tmp: String;
begin
  SetState_FromParameters(Parameters);
  FetchComponents(0);
  tmp := PickAndPlaceOutputEx;
  Gener(tmp);
  f2 := GetOutputFileNameWithExtension('.csv');
  f5 := GetPluginExecutableFileName();
end;

Function PredictOutputFileNames(Parameters: String): String;
Var
  OutputFileNames: TStringList;
  f1, f2, f3: string;
Begin
  SetState_FromParameters(Parameters);
  OutputFileNames := TStringList.Create;
  OutputFileNames.Delimiter := '|';
  OutputFileNames.StrictDelimiter := True;
  OutputFileNames.Add(GetOutputFileNameWithExtension('.pdf'));
  Result := OutputFileNames.DelimitedText;
  OutputFileNames.Free;
End;

procedure LoadParameterNames(Dummy: Integer);
Var
  CompCount: Integer; // The Number of Components in the Flattened Document
  CompIndex: Integer; // An Index for pulling out components
  ParmCount: Integer; // The Number of Parameters in a Component
  ParmIndex: Integer; // An Index for pulling out parameters
  CurrParm: IParameter; // An interface handle to the current parameter
  NameCount: Integer; // The Number of parameter Names found
  NameIndex: Integer; // An Index for pulling out parameter Names
  DNIIndex: Integer; // The Index for the parameter named "DNI"
  NameList: TStringList; // Exapndable parameter Name list
Begin
  LayerFilterCb.Items.Add('Both');
  LayerFilterCb.Items.Add('Top');
  LayerFilterCb.Items.Add('Bottom');

  FieldSeparatorCb.Items.Add(',');
  FieldSeparatorCb.Items.Add(';');
  FieldSeparatorCb.Items.Add('Space');
  FieldSeparatorCb.Items.Add('Tab');


////////////////////////////////////////////////////
  {
    // Fetch the Flattened schematic sheet document.  This is a fictitious document
    // generated when the project is compiled containing all components from all
    // sheets.  This is much more useful for making lists of everything than rummaging
    // through all the sheets one at a time.  This sheet is not graphical in that
    // it cannot be viewed like a schematic, but you can view what's in it by using
    // the Navigator panel.
    FlattenedDoc := CurrProject.DM_DocumentFlattened;

    // If we couldn't get the flattened sheet, then most likely the project has
    // not been compiled recently
    If (FlattenedDoc = Nil) Then
    Begin
    // First try compiling the project
    AddStringParameter( 'Action', 'Compile' );
    AddStringParameter( 'ObjectKind', 'Project' );
    RunProcess( 'WorkspaceManager:Compile' );

    // Try Again to open the flattened document
    FlattenedDoc := CurrProject.DM_DocumentFlattened;
    If (FlattenedDoc = Nil) Then
    Begin
    ShowMessage('NOTICE: Compile the Project before Running this report.');
    Close;
    Exit;
    End; // If (FlattenedDoc = Nil) Then
    End; // If (FlattenedDoc = Nil) Then

    // Create an expandable string list to hold parameter Names
    NameList := TStringList.Create;

    // Let the TStringList automatically sort itself and remove duplicates as it is created
    NameList.Sorted := True;
    NameList.Duplicates := dupIgnore;

    // Now that we have the flattened document, check how many components are in it
    CompCount := FlattenedDoc.DM_ComponentCount;

    // Walk through every component one-by-one so we can look at it's parameter names
    For CompIndex := 0 To CompCount - 1 Do
    Begin
    // Fetch a Component
    CurrComponent := FlattenedDoc.DM_Components[ CompIndex ];

    // Determine how many parameters it has
    ParmCount := CurrComponent.DM_ParameterCount;

    // Walk through every parameter of this component one-by-one
    For ParmIndex := 0 To ParmCount - 1 Do
    Begin
    // Fetch one of the component's Parameters
    CurrParm := CurrComponent.DM_Parameters( ParmIndex );

    // Add it's name to the string list
    NameList.Add := CurrParm.DM_Name;
    End; // For ParmIndex := 0 To ParmCount - 1 Do

    End; // CompIndex := 0 To CompCount - 1 Do

    // Determine how many records are in the parameter list
    NameCount := NameList.Count;

    // Add all parameter names in this list to the Parameters Combo-Box
    // and also default to the parameter named DNI if it exists
    DNIIndex := 0;
    For NameIndex := 0 To NameCount - 1 Do
    Begin
    If (NameList.Strings[ NameIndex ] = 'DNI') Then DNIIndex := NameIndex;
    ParametersComboBox.Items.Add( NameList.Strings[ NameIndex ] );
    End;

    // Choose the entry to start with
    ParametersComboBox.ItemIndex := DNIIndex;

    // Free up the Parameter Name List as we no longer need it
    NameList.Free; }
End;

procedure Initialize;
begin
  // Open Workspace, Project, Get Variants, etc.
  InitializeProject(0);

  // Add Parameters to Parameters ComboBox
  LoadParameterNames(0);

  // Based on current settings on the form, re-write the description of what
  // action will be done when the OK button is pressed
  // ReWriteActionLabel( 0 );
end;

Function Configure(Parameters: String): String;
Begin
  Result := '';
  Initialize;
  SetState_FromParameters(Parameters);
  If MainFrm.ShowModal = mrOK Then
  Begin
    Result := GetState_FromParameters;
    Close;
  End;
End;

procedure TMainFrm.OKBtnClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;


procedure TMainFrm.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

