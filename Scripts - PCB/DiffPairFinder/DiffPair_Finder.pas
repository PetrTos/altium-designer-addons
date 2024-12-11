// References: Altium Examples CreateAVia.pas
//                             PCB_Class_Generator_Form.pas
// ChatGPT 4o

var
    Board          : IPCB_Board;
    GlbDiffPairs   : TStringList;

Function DiffPolarity(txt: String): Integer;
var
   polarity : Integer;
   t : String;
   isIn : Boolean;
Begin
     result := 0;

     t := LowerCase(txt);

     // If Else to Force priority ordering
     If      AnsiEndsStr('_dp', t) Then
     Begin
         result := 1;
     End
     Else If AnsiEndsStr('_dn', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('_dm', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('-dp', t) Then
     Begin
         result := 1;
     End
     Else If AnsiEndsStr('-dn', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('-dm', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('_p', t) Then
     Begin
         result := 1;
     End
     Else If AnsiEndsStr('_n', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('-p', t) Then
     Begin
         result := 1;
     End
     Else If AnsiEndsStr('-n', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('dp', t) Then
     Begin
         result := 1;
     End
     Else If AnsiEndsStr('dn', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('dm', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('_h', t) Then
     Begin
         result := 1;
     End
     Else If AnsiEndsStr('_l', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('-h', t) Then
     Begin
         result := 1;
     End
     Else If AnsiEndsStr('-l', t) Then
     Begin
         result := -1;
     End
     Else If AnsiEndsStr('+', t) Then
     Begin
         result := 1;
     End
     Else If AnsiEndsStr('-', t) Then
     Begin
         result := -1;
     End
     Else If ContainsText(t, '_dp') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, '_dn') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, '_dm') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, '-dp') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, '-dn') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, '-dm') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, '_p') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, '_n') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, '-p') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, '-n') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, '+') And Not(AnsiStartsStr('+', t)) Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, 'dp') And Not(AnsiStartsStr('dp', t)) Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, 'dn') And Not(AnsiStartsStr('dn', t)) Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, 'dm') And Not(AnsiStartsStr('dm', t)) Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, 'p_') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, 'n_') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, '_h') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, '_l') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, '-h') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, '-l') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, 'h_') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, 'l_') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, 'p-') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, 'n-') Then
     Begin
       result := -1;
     End
     Else If ContainsText(t, 'h-') Then
     Begin
       result := 1;
     End
     Else If ContainsText(t, 'l-') Then
     Begin
       result := -1;
     End;
End;

Function IsPotentialDiffPair(txt: String): Boolean;
var
   polarity : Integer;
   t : String;
   isIn : Boolean;
Begin
     result := False;

     t := LowerCase(txt);

     if Not(AnsiStartsStr('net', t)) and (txt <> 'gnd') then
     Begin
         polarity := DiffPolarity(txt);
         if (polarity = -1) or (polarity = 1) then
         begin
             result := True;
         end;
     End;
End;

Function GetAllPinsSortedByComponent(Dummy): TStringList; // Dummy hides visibility. Use Nil in call.
Var
    Iterator       : IPCB_BoardIterator;
    GrpIter : IPCB_GroupIterator;
    Cmp            : IPCB_Component;
    Pad : IPCB_Pad;
    cmps : TStringList;
    CmpDes, NetName, PinDes, Value, FirstEntry : String;
Begin
    cmps := TStringList.Create;
    cmps.NameValueSeparator := '=';

    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
    Iterator.AddFilter_IPCB_LayerSet(LayerSet.AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    Cmp := Iterator.FirstPCBObject;
    While (Cmp <> Nil) Do
    Begin
        CmpDes := Cmp.Name.Text;

        FirstEntry := '';

        GrpIter := Cmp.GroupIterator_Create;
        GrpIter.SetState_FilterAll;
        GrpIter.AddFilter_ObjectSet(MkSet(ePadObject));

        Pad := GrpIter.FirstPCBObject;
        While Pad <> Nil Do
        Begin
            If Pad.InComponent Then
            Begin
                If Pad.Net <> Nil Then
                Begin
                    NetName := Pad.Net.Name;
                    Value := cmps.Values[CmpDes];

                    // If NetName not already in list and is a potential DiffPair
                    If Not(ContainsText(FirstEntry+Value, NetName)) And IsPotentialDiffPair(NetName) Then
                    Begin

                        // If CmpDes Key already exists
                        If cmps.IndexOfName(CmpDes) >= 0 Then
                        Begin
                            cmps.Values[CmpDes] := Value + ';' + NetName;
                        End
                        // If Key doesn't exist, but this is the first entry, don't add because we don't want single net entries
                        Else If FirstEntry = '' Then
                        Begin
                            //cmps.Add(CmpDes + '=' + NetName);
                            FirstEntry := CmpDes + '=' + NetName;
                        End
                        // Once we have at least 2 nets ready to add then add first entry at CmpDes Key
                        // After this, the key will exist so only the first if should be valid
                        Else
                        Begin
                            cmps.Add(FirstEntry + ';' + NetName);
                        End;

                    End;
                End;
            End;

            Pad := GrpIter.NextPCBObject;
        End;
        Cmp.GroupIterator_Destroy(GrpIter);

        Cmp := Iterator.NextPCBObject;
    End;

    Board.BoardIterator_Destroy(Iterator);

    result := cmps;
End;

function AlphaOnly(const InputStr: String): String;
var
  I: Integer;
begin
  Result := '';
  // Iterate through each character in the input string
  for I := 1 to Length(InputStr) do
  begin
    // Check if the character is alphabetic (A-Z, a-z)
    if ((InputStr[I] >= 'A') and (InputStr[I] <= 'Z')) or
       ((InputStr[I] >= 'a') and (InputStr[I] <= 'z')) then
    begin
      Result := Result + InputStr[I]; // Add the character to the result
    end;
  end;
end;

function IsNonAlphaNumeric(const Ch: Char): Boolean;
begin
  // Check if the character is not alphanumeric
  Result := not ((Ch >= '0') and (Ch <= '9') or
                 (Ch >= 'A') and (Ch <= 'Z') or
                 (Ch >= 'a') and (Ch <= 'z'));
end;

function TrimNonAlphaNumeric(const InputStr: String): String;
var
  Len: Integer;
begin
  Result := InputStr;
  Len := Length(Result);

  // Loop to remove non-alphanumeric characters from the end
  while (Len > 0) and IsNonAlphaNumeric(Result[Len]) do
  begin
    Delete(Result, Len, 1); // Remove the last character
    Len := Len - 1; // Update the length
  end;
end;

Function IsOffByNChar(txt1: String, txt2: String, n: Integer, var diffName : String): Boolean;
Var
    i, matchCnt, digCnt : Integer;
    ch1, ch2, prev : Char;
    ch1Valid, ch2Valid: Boolean;
Begin
    result := False;
    ch1Valid := False;
    ch2Valid := False;
    diffName := '';

    matchCnt := 0;
    digCnt := 0;
    For i := 1 to Length(txt1) Do
    Begin
        ch1 := LowerCase(txt1[i]);
        ch2 := LowerCase(txt2[i]);

        If ch1 = ch2 Then
        Begin
           Inc(matchCnt);
           If Not(IsNonAlphaNumeric(ch1) And IsNonAlphaNumeric(prev)) Then
           Begin
               diffName := diffName+ch1;
               prev := ch1;
           End;
        End
        Else
        Begin
           If (ch1 = 'p') or (ch1 = 'n') or (ch1 = 'm') or (ch1 = '+') or (ch1 = '-') or (ch1 = 'h') or (ch1 = 'l') Then ch1Valid := True;
           If (ch2 = 'p') or (ch2 = 'n') or (ch2 = 'm') or (ch2 = '+') or (ch2 = '-') or (ch2 = 'h') or (ch2 = 'l') Then ch2Valid := True;
        End;

    End;



    if (matchCnt >= Length(txt1)-n) and ch1Valid and ch2Valid Then
    Begin
       result := True;
    End;

    diffName := UpperCase(TrimNonAlphaNumeric(diffName));
End;

Function CompareSameLenNets(matches: TStringList, cnts: TStringList): TStringList;
Var
    cnt, viewed : TStringList;
    i, j, cntIdx, cntsLen, cntLen, polarity: Integer;
    net1, net2, diffName : String;
    IsMatch : Boolean;
Begin
    cnt := TStringList.Create;
    cnt.Delimiter := ';';
    cnt.StrictDelimiter := True;

    viewed := TStringList.Create;
    viewed.Sorted := True;
    viewed.Duplicates := dupIgnore;

    cntsLen := cnts.Count;

    for cntIdx := 0 to cnts.Count-1 do
    begin
        cnt.DelimitedText := cnts.ValueFromIndex[cntIdx];

        if cnt.Count <= 1 then continue;

        for i := 0 to cnt.Count - 1 do
        begin
            net1 := cnt[i];

            for j := 0 to cnt.Count - 1 do
            begin

                // Don't compare the same net against itself
                if i <> j then
                begin
                    net2 := cnt[j];

                    // previously viewed can be skipped
                    if viewed.IndexOf(net1 + net2) = -1 then
                    begin
                        IsMatch := IsOffByNChar(net1, net2, 1, diffName);

                        If IsMatch Then
                        Begin
                            polarity := DiffPolarity(net1);
                            if polarity = 1 then
                            begin
                                matches.Add(diffName+'='+net1+';'+net2);
                            end
                            else
                            begin
                                matches.Add(diffName+'='+net2+';'+net1);
                            end;
                        End;

                        viewed.Add(net1+net2);
                        viewed.Add(net2+net1);
                    end;
                end;
            end;
        end;
        viewed.Clear;
    end;

    cnt.Free;
    viewed.Free;
End;

Function FindDiffPairCandidates(cmps: TStringList): TStringList;
Const
    pIdx = 0;
    nIdx = 1;
Var
    pinStr, netStr, cmpDes: String;
    cmpIdx, netIdx, pinsCnt, pinCnt, len: Integer;
    nets, cnts, tmp, matches: TStringList;
    doCompare : Boolean;
Begin
    nets := TStringList.Create;
    nets.Delimiter := ';';
    nets.StrictDelimiter := True;

    tmp := TStringList.Create;
    tmp.Delimiter := ';';
    tmp.StrictDelimiter := True;

    cnts := TStringList.Create;
    cnts.NameValueSeparator := '=';

    matches := TStringList.Create;
    matches.Sorted := True;
    matches.Duplicates := dupIgnore;
    matches.NameValueSeparator := '=';

    // Build a dictionary of dict[StringLength] = DelimitedNetList
    // For each component, build a cnts dictionary that holds the length of
    // each string as a key
    for cmpIdx := 0 to cmps.Count-1 do
    begin
        nets.DelimitedText := cmps.ValueFromIndex[cmpIdx];

        doCompare := False; // Reset for each component

        for netIdx := 0 to nets.Count - 1 do
        begin
            netStr := nets[netIdx];

            // Filter out all other nets for speed
            If IsPotentialDiffPair(netStr) Then
            Begin
                len := IntToStr(Length(netStr));

                If cnts.IndexOfName(len) >= 0 Then
                Begin
                    tmp.DelimitedText := cnts.Values[len];
                    If tmp.IndexOf(netStr) = -1 Then
                    Begin
                        cnts.Values[len] := cnts.Values[len] + ';' + netStr;
                        doCompare := True; // There is at least one set of matching lengths worth checking
                    End;
                End
                Else
                Begin
                    cnts.Add(len + '=' + netStr);
                End;

            End;

        end;

        If doCompare Then CompareSameLenNets(matches, cnts); // Iterate Same Length Strings and compare
        cnts.Clear;
    end;

    nets.Free;
    cnts.Free;
    tmp.Free;

    result := matches;
End;

Function GetNetObject(NetName: String): IPCB_Net;
Var
    Iterator    : IPCB_BoardIterator;
    Net         : IPCB_Net;
Begin
    result := Nil;

    Iterator        := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eNetObject));
    Iterator.AddFilter_LayerSet(AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    Net := Iterator.FirstPCBObject;
    While (Net <> Nil) Do
    Begin
        If Net.Name = NetName Then
        Begin
            result := Net;
            Break;
        End;

        Net := Iterator.NextPCBObject;
    End;
    Board.BoardIterator_Destroy(Iterator);
End;

Function GetExistingDiffPairs(Dummy): TStringList;
Var
    Iterator    : IPCB_BoardIterator;
    Existing : TStringList;
    Diff : IPCB_DifferentialPair;
Begin
    Existing := TStringList.Create;

    Iterator        := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eDifferentialPairObject));
    Iterator.AddFilter_LayerSet(AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    Diff := Iterator.FirstPCBObject;
    While (Diff <> Nil) Do
    Begin
        If (Diff.PositiveNet <> Nil) And (Diff.NegativeNet <> Nil) Then
        Begin
            Existing.Add(LowerCase(Diff.PositiveNet.Name));
            Existing.Add(LowerCase(Diff.NegativeNet.Name));
        End;

        Diff := Iterator.NextPCBObject;
    End;
    Board.BoardIterator_Destroy(Iterator);

    result := Existing;
End;

Function AddDiffPairClass(ClassName: String): IPCB_ObjectClass;
Var
    DiffClass      :  IPCB_ObjectClass;
Begin
    PCBServer.PreProcess; // Initialize the systems in the PCB Editor.

    DiffClass := PCBServer.PCBClassFactoryByClassMember(eClassMemberKind_DifferentialPair);
    DiffClass.SuperClass := False;
    DiffClass.Name := ClassName;

    Board.AddPCBObject(DiffClass);

    // Update the Undo System in DXP that a new object has been added to the board
    PCBServer.SendMessageToRobots(Board  .I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, DiffClass.I_ObjectAddress);

    PCBServer.PostProcess; // Finalize the systems in the PCB Editor.

    result := DiffClass;
End;

Function AddDiffPair(DiffClass: IPCB_ObjectClass, ExistingPairs: TStringList, DiffPairName: String, PositiveNet: String, NegativeNet: String);
Var
    DiffPair : IPCB_DifferentialPair;
    pLow, nLow : String;
    pGood, nGood : Boolean;
Begin

    // Check if Diff pair positive or negative net name already exists
    If (ExistingPairs.IndexOf(LowerCase(PositiveNet)) <> -1) Or (ExistingPairs.IndexOf(LowerCase(NegativeNet)) <> -1) Then Exit;

    PCBServer.PreProcess; // Initialize the systems in the PCB Editor.

    DiffPair := PCBServer.PCBObjectFactory(eDifferentialPairObject, eNoDimension, eCreate_Default);

    DiffPair.PositiveNet := GetNetObject(PositiveNet);
    DiffPair.NegativeNet := GetNetObject(NegativeNet);

    DiffPair.Name := DiffPairName;

    Board.AddPCBObject(DiffPair);

    // Update the Undo System in DXP that a new object has been added to the board
    PCBServer.SendMessageToRobots(Board  .I_ObjectAddress, c_Broadcast, PCBM_BoardRegisteration, DiffPair.I_ObjectAddress);

    // Class was specified, add to specific class.
    If DiffClass <> Nil Then
    Begin
         DiffClass.AddMemberByName(DiffPair.Name);
    End;

    PCBServer.PostProcess; // Finalize the systems in the PCB Editor.
End;

Function AddDiffPairs(DiffClass: IPCB_ObjectClass, diffs: TStringList);
Const
    pIdx = 0;
    nIdx = 1;
Var
    i, pairCnt : Integer;
    pair, existingPairs : TStringList;
    diffName, pStr, nStr, pairStr : String;
Begin
     pair := TStringList.Create;
     pair.Delimiter := ';';
     pair.StrictDelimiter := True;

     existingPairs := GetExistingDiffPairs(Nil); // Get existing differential pairs

     For i := 0 to diffs.Count - 1 do
     Begin
         diffName := diffs.Names[i];
         pairStr := diffs.ValueFromIndex[i];
         pair.DelimitedText := pairStr;

         pairCnt := pair.Count;

         if pairCnt = 2 Then
         Begin
              pStr := pair[pIdx];
              nStr := pair[nIdx];

              AddDiffPair(DiffClass, existingPairs, diffName, pStr, nStr);

              existingPairs.Add(LowerCase(pStr));
              existingPairs.Add(LowerCase(nStr));
         End;
     End;

     existingPairs.Free;
End;

Function ValidComponent(Cmp: IPCB_Component, NetName: String): Boolean;
Var
    GrpIter : IPCB_GroupIterator;
    Pad : IPCB_Pad;
    Cnt : Integer;
    HasNet : Boolean;
Begin
    result := False;
    HasNet := False;

    GrpIter := Cmp.GroupIterator_Create;
    GrpIter.SetState_FilterAll;
    GrpIter.AddFilter_ObjectSet(MkSet(ePadObject));

    Cnt := 0;

    Pad := GrpIter.FirstPCBObject;
    While Pad <> Nil Do
    Begin
        If (Pad.InComponent) And (Pad.Net <> Nil) Then
        Begin
            Inc(Cnt);

            If LowerCase(Pad.Net.Name) = LowerCase(NetName) Then HasNet := True;

            If Cnt > 2 Then Break;
        End;

        Pad := GrpIter.NextPCBObject;
    End;
    Cmp.GroupIterator_Destroy(GrpIter);

    If (Cnt = 2) And (HasNet) Then result := True;
End;

Function GetConnectedNetName(Cmp: IPCB_Component, NetName: String): String;
Var
    GrpIter : IPCB_GroupIterator;
    Pad : IPCB_Pad;
    conName, CmpDes : String;
Begin
     result := '';

     CmpDes := Cmp.Name.Text;

     GrpIter := Cmp.GroupIterator_Create;
     GrpIter.SetState_FilterAll;
     GrpIter.AddFilter_ObjectSet(MkSet(ePadObject));

     Pad := GrpIter.FirstPCBObject;
     While Pad <> Nil Do
     Begin
         If Pad.InComponent Then
         Begin
             If Pad.Net <> Nil Then
             Begin
                 conName := Pad.Net.Name;
                 If (LowerCase(conName) <> LowerCase(NetName)) And Not(ContainsText(LowerCase(conName), 'gnd')) Then
                 Begin
                     result := conName;
                     Exit;
                 End;
             End;
         End;

         Pad := GrpIter.NextPCBObject;
     End;
     Cmp.GroupIterator_Destroy(GrpIter);
End;

Function IsConnectedDiffPair(cwn: TStringList, pStr: String, nStr: String, var pCon: String, var nCon: String): Boolean;
Var
    Iterator : IPCB_BoardIterator;
    Cmp : IPCB_Component;
    inCmps : TStringList;
    CmpDes, test : String;
    i : Integer;
Begin
    inCmps := TStringList.Create;

    result := False;
    pCon := '';
    nCon := '';

    If (cwn.IndexOfName(pStr) = -1) or (cwn.IndexOfName(nStr) = -1) Then Exit;

    inCmps.DelimitedText := cwn.Values[pStr];
    // TODO: How to handle if net has multiple connected R's or C's?
    if inCmps.Count > 1 then
    begin
        ShowMessage(pStr + ' is connected to ' + IntToStr(inCmps.Count) + '2-pin components. Skipping...');
        Exit;
    end;

    for i:=0 to inCmps.Count - 1 do
    begin
        CmpDes := inCmps[i];
        Cmp := Board.GetPcbComponentByRefDes(CmpDes);

        pCon := GetConnectedNetName(Cmp, pStr);
        If pCon <> '' Then Break;
    end;

    inCmps.DelimitedText := cwn.Values[nStr];
    for i:=0 to inCmps.Count - 1 do
    begin
        CmpDes := inCmps[i];
        Cmp := Board.GetPcbComponentByRefDes(CmpDes);

        nCon := GetConnectedNetName(Cmp, pStr);
        If nCon <> '' Then Break;
    end;

    inCmps.Free;

    If (pCon <> '') And (nCon <> '') Then
    Begin
        result := True;
    End;

    Board.BoardIterator_Destroy(Iterator);
End;

function RemovePrefix(const InputStr, Prefix: String): String;
var
  LowerInput, LowerPrefix: String;
begin
  // Convert both the input string and the prefix to lowercase for case-insensitive comparison
  LowerInput := AnsiLowerCase(InputStr);
  LowerPrefix := AnsiLowerCase(Prefix);

  // Check if the input string starts with the specified prefix
  if Copy(LowerInput, 1, Length(LowerPrefix)) = LowerPrefix then
    Result := Copy(InputStr, Length(LowerPrefix) + 1, Length(InputStr))
  else
    Result := InputStr; // Return the original string if no match
end;

Function FlattenDiffsToNetList(diffs: TStringList): TStringList;
Const
    pIdx = 0;
    nIdx = 1;
Var
    i, pairCnt : Integer;
    pair, flat : TStringList;
    pairStr : String;
Begin
     flat := TStringList.Create;
     flat.Delimiter := ',';
     flat.StrictDelimiter := True;

     pair := TStringList.Create;
     pair.Delimiter := ';';
     pair.StrictDelimiter := True;

     For i := 0 to diffs.Count - 1 do
     Begin
         pairStr := diffs.ValueFromIndex[i];
         pair.DelimitedText := pairStr;

         pairCnt := pair.Count;

         if pairCnt = 2 Then
         Begin
              flat.Add(pair[pIdx]);
              flat.Add(pair[nIdx]);
         End;
     End;

     result := flat;
End;

Function CreateCmpsWithNetsList(nets: TStringList): TStringList;
Var
    Iterator : IPCB_BoardIterator;
    GrpIter : IPCB_GroupIterator;
    Cmp : IPCB_Component;
    Pad : IPCB_Pad;
    cwn : TStringList;
    CmpDes : String;
Begin
    cwn := TStringList.Create;
    cwn.Duplicates := dupIgnore;
    cwn.NameValueSeparator := '=';

    Iterator := Board.BoardIterator_Create;
    Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
    Iterator.AddFilter_IPCB_LayerSet(LayerSet.AllLayers);
    Iterator.AddFilter_Method(eProcessAll);

    Cmp := Iterator.FirstPCBObject;
    While (Cmp <> Nil) Do
    Begin
        CmpDes := Cmp.Name.Text;

        // Only consider Resistors and Capacitors
        If AnsiStartsStr('R', CmpDes) Or AnsiStartsStr('C', CmpDes) Then
        Begin
            GrpIter := Cmp.GroupIterator_Create;
            GrpIter.SetState_FilterAll;
            GrpIter.AddFilter_ObjectSet(MkSet(ePadObject));

            Pad := GrpIter.FirstPCBObject;
            While Pad <> Nil Do
            Begin
                If Pad.InComponent Then
                Begin
                    If Pad.Net <> Nil Then
                    Begin
                        If nets.IndexOf(Pad.Net.Name) >= 0 Then
                        Begin
                             cwn.Add(Pad.Net.Name+'='+CmpDes);
                        End;
                    End;
                End;

                Pad := GrpIter.NextPCBObject;
            End;
            Cmp.GroupIterator_Destroy(GrpIter);
        End;

        Cmp := Iterator.NextPCBObject;
    End;
    Board.BoardIterator_Destroy(Iterator);

    result := cwn;
End;

Function GetConnectedDiffPairs(diffs: TStringList, alreadyFound: TStringList): TStringList;
Const
    pIdx = 0;
    nIdx = 1;
Var
    i, pairCnt : Integer;
    pair, cwn, newDiffs : TStringList;
    diffName, conName, pStr, nStr, pairStr, pConnect, nConnect, suffix : String;
Begin
     newDiffs := TStringList.Create;

     pair := TStringList.Create;
     pair.Delimiter := ';';
     pair.StrictDelimiter := True;

     cwn := CreateCmpsWithNetsList(alreadyFound); // Components with nets

     For i := 0 to diffs.Count - 1 do
     Begin
         diffName := diffs.Names[i];
         pairStr := diffs.ValueFromIndex[i];
         pair.DelimitedText := pairStr;

         pairCnt := pair.Count;

         if pairCnt = 2 Then
         Begin
              pStr := pair[pIdx];
              nStr := pair[nIdx];

              If IsConnectedDiffPair(cwn, pStr, nStr, pConnect, nConnect) Then
              Begin
                  // New name is old name + designator prefix, unless that already exists, then it is full refDes
                  suffix := RemovePrefix(pConnect, 'net');
                  conName := diffName + '-' + AlphaOnly(suffix);
                  If (diffs.IndexOf(conName) <> -1) or (newDiffs.IndexOf(conName) <> -1) Then conName := diffName + '-' + suffix;

                  If (alreadyFound.IndexOf(pConnect) = -1) and (alreadyFound.IndexOf(nConnect) = -1) Then
                  Begin
                      newDiffs.Add(conName+'='+pConnect+';'+nConnect);

                      alreadyFound.Add(pConnect);
                      alreadyFound.Add(nConnect);
                  End;
              End;
         End;
     End;

     result := newDiffs;
End;

Procedure AddDiffPairClassesToComboBox(Dummy);
Var
    i : Integer;
    ClassIterator :  IPCB_BoardIterator;
    ClassList     :  TStringList;
    DiffClass      :  IPCB_ObjectClass;
    Name : String;
Begin
   ClassList := TStringList.Create;

   ClassIterator := Board.BoardIterator_Create;
   ClassIterator.SetState_FilterAll;
   ClassIterator.AddFilter_ObjectSet(MkSet(eClassObject));
   DiffClass := ClassIterator.FirstPCBObject;
   i := 0;
   While DiffClass <> Nil Do
   Begin
       Inc(i);
       If DiffClass.MemberKind = eClassMemberKind_DifferentialPair Then
       Begin
           Name := DiffClass.Name;
           //cbDiffPairClasses.items.AddObject(DiffClass.Name, DiffClass);
           cbDiffPairClasses.AddItem(DiffClass.Name, DiffClass);
           //IPCB_ObjectClass.MemberName[0];
           ClassList.Add(DiffClass.Name);
       End;
       DiffClass := ClassIterator.NextPCBObject;
   End;
   cbDiffPairClasses.SetItemIndex(0);
   Board.BoardIterator_Destroy(ClassIterator);
End;

procedure ResetStringGrid(Grid: TStringGrid);
var
    Row, Col: Integer;
begin
    // Clear all cell contents
    for Row := 0 to Grid.RowCount - 1 do
        for Col := 0 to Grid.ColCount - 1 do
            Grid.Cells[Col, Row] := '';

    // Reset the grid dimensions
    Grid.RowCount := 1; // Keep only one row
    Grid.ColCount := 1; // Keep only one column

    // Optionally, reset headers if needed
    Grid.Cells[0, 0] := ''; // Clear the header cell or set initial text
end;

Function AddKeysToStringGrid(list: TStringList, HideExisting: Boolean);
Var
    i, RowIdx : Integer;
    DiffPairName, pStr, nStr : String;
    Row, existing: TStringList;
Begin
    Row := TStringList.Create;
    Row.Delimiter := ';';

    existing := GetExistingDiffPairs(Nil);

    // Start adding from the last row
    RowIdx := StringGrid.RowCount; // Get current row count

    For i := 0 to list.Count - 1 do
    begin
        Row.DelimitedText := list.ValueFromIndex[i];
        DiffPairName := list.Names[i];
        pStr := LowerCase(Row[0]);
        nStr := LowerCase(Row[1]);

        If (HideExisting) And ((existing.IndexOf(pStr) <> -1) Or (existing.IndexOf(nStr) <> -1)) Then continue;

        // Add a new row if necessary
        if RowIdx >= StringGrid.RowCount then
            StringGrid.RowCount := StringGrid.RowCount + 1;

        StringGrid.Cells[0, RowIdx] := DiffPairName; // DiffPairName
        StringGrid.Cells[1, RowIdx] := Row[0]; // PositiveNetName
        StringGrid.Cells[2, RowIdx] := Row[1]; // NegativeNetName

        Inc(RowIdx);
    end;
End;

Function InitStringGrid(diffs: TStringList);
Begin
    // Set up StringGrid columns and headers
    StringGrid.RowCount := 1; // Add 1 for header row
    StringGrid.Cells[0, 0] := 'Diff Pair Name';
    StringGrid.Cells[1, 0] := 'Positive Net Name';
    StringGrid.Cells[2, 0] := 'Negative Net Name';

    StringGrid.FixedCols := 0;

    AddKeysToStringGrid(diffs, cbHideExisting.Checked);
End;

{..............................................................................}
Procedure Run(UseGUI : Boolean);
Const
    MAX_CONNECTIONS = 3;
Var
    cmps : TStringList;
    diffs, newDiffs, alreadyFound : TStringList;
    DiffClass : IPCB_ObjectClass;
    i, idx, cnt : Integer;
Begin
    // Retrieve the current board
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then Exit;

    // 1. Get All nets for each pin in a component
    cmps := GetAllPinsSortedByComponent(Nil);

    // 2. For given component, if nets' chars all match except 1 char
    //    add pos/neg net string to TStringList.
    //    Format: DiffPairName=PositiveNetName;NegativeNetName, ...
    diffs := FindDiffPairCandidates(cmps);
    cmps.Free;

    // 3. Find all DiffPair Candidates that go through 2 pin components
    //    and add their nets as well
    // Iterate until no new connected pairs are found or max
    For i := 0 to MAX_CONNECTIONS - 1 Do
    Begin
         alreadyFound := FlattenDiffsToNetList(diffs);
         newDiffs := GetConnectedDiffPairs(diffs, alreadyFound);
         if newDiffs.Count <= 0 then break;

         diffs.AddStrings(newDiffs); // Append new diff pairs list
    End;

    GlbDiffPairs := diffs;

    // TODO: Run until no new pairs are found
    //newDiffs := GetConnectedDiffPairs(newDiffs);
    //diffs.AddStrings(newDiffs); // Append new diff pairs list

    if UseGUI = True then
    begin
        AddDiffPairClassesToComboBox(Nil);
        InitStringGrid(diffs);

        Form1.ShowModal;
    end
    else
    begin
       // 4. Create diff pairs in layout
       AddDiffPairs(Nil, diffs);
    end;
End;
{..............................................................................}

Procedure RunWithGUI;
Begin
     Run(True);
End;

Procedure RunNoGUI;
Begin
     Run(False);
End;


Function GetSelectedDiffPairs(Grid: TStringGrid): TStringList;
var
    DiffPairs: TStringList;
    Row: Integer;
    Key, Value: String;
    Selection: TGridRect;
begin
    DiffPairs := TStringList.Create;
    DiffPairs.Sorted := True;
    DiffPairs.Duplicates := dupIgnore;
    DiffPairs.NameValueSeparator := '=';

    // Get the selection rectangle
    Selection := Grid.Selection;

    // Iterate through the rows in the selected range
    for Row := Selection.Top to Selection.Bottom do
    begin
        // Ensure the row is valid (in case of invalid selections)
        if (Row >= 0) and (Row < Grid.RowCount) then
        begin
            // Construct the dictionary key and value
            Key := Grid.Cells[0, Row]; // Column 1
            Value := Grid.Cells[1, Row] + ';' + Grid.Cells[2, Row]; // Columns 2 and 3

            // Add the entry to the TStringList dictionary
            DiffPairs.Add(Key + '=' + Value);
        end;
    end;

    Result := DiffPairs; // Return the resulting TStringList
end;



procedure TForm1.btnAddDiffPairsClick(Sender: TObject);
var
    idx : Integer;
    ClassObj: IPCB_ObjectClass;
    SelectedDiffPairs: StringList;
begin
    // Get ComboBox selection index
    idx := cbDiffPairClasses.GetItemIndex();

    // Add Differential Pairs to New Class
    if idx < 0 then
    begin
        ClassObj := AddDiffPairClass(cbDiffPairClasses.Text);
    end
    // Add Differential Pairs to Existing Class
    else
    begin
        ClassObj := cbDiffPairClasses.Items.Objects[idx];
    end;

    // Get selected diff pairs from String Grid
    SelectedDiffPairs := GetSelectedDiffPairs(StringGrid);

    // 4. Create diff pairs in layout
    AddDiffPairs(ClassObj, SelectedDiffPairs);

    InitStringGrid(GlbDiffPairs); // Refresh String Grid
end;


procedure TForm1.cbHideExistingClick(Sender: TObject);
begin
     InitStringGrid(GlbDiffPairs);
end;

