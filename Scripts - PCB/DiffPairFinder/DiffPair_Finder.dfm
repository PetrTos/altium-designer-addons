object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Differential Pair Finder'
  ClientHeight = 679
  ClientWidth = 930
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    930
    679)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 608
    Width = 166
    Height = 13
    Caption = 'Hold SHIFT to select multiple pairs.'
  end
  object StringGrid: TStringGrid
    Left = 8
    Top = 8
    Width = 912
    Height = 592
    Anchors = [akLeft, akTop, akRight]
    ColCount = 3
    DefaultColWidth = 300
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect, goFixedColClick]
    ScrollBars = ssVertical
    TabOrder = 0
    ColWidths = (
      300
      300
      300)
    RowHeights = (
      24
      24
      24
      24
      24)
  end
  object btnAddDiffPairs: TButton
    Left = 744
    Top = 640
    Width = 176
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Add Selected To DiffPair Class'
    TabOrder = 1
    OnClick = btnAddDiffPairsClick
  end
  object cbDiffPairClasses: TComboBox
    Left = 744
    Top = 608
    Width = 177
    Height = 21
    Anchors = [akRight, akBottom]
    TabOrder = 2
    Text = 'Select DiffPair Class'
  end
  object cbHideExisting: TCheckBox
    Left = 8
    Top = 648
    Width = 97
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Hide Existing'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = cbHideExistingClick
  end
end
