object RenumberPads: TRenumberPads
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Renumber Pads'
  ClientHeight = 278
  ClientWidth = 247
  Color = clBtnFace
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMode = pmAuto
  Position = poScreenCenter
  OnCreate = RenumberPadsCreate
  FormKind = fkModal
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox: TGroupBox
    Left = 8
    Top = 8
    Width = 232
    Height = 220
    Caption = 'Renumber setup'
    TabOrder = 0
    object lblFirstPadIndex: TLabel
      Left = 20
      Top = 20
      Width = 73
      Height = 13
      Caption = 'First Pad Index'
    end
    object lblPadIncrement: TLabel
      Left = 20
      Top = 50
      Width = 101
      Height = 13
      Caption = 'Pad Index Increment'
    end
    object lblPreview: TLabel
      Left = 182
      Top = 160
      Width = 38
      Height = 13
      Alignment = taRightJustify
      Caption = 'Preview'
      Layout = tlCenter
      Visible = False
    end
    object edFirstPadNumber: TEdit
      Left = 140
      Top = 20
      Width = 80
      Height = 21
      Hint = 'Enter starting designator index.'
      Alignment = taRightJustify
      NumbersOnly = True
      TabOrder = 0
      Text = '1'
    end
    object btnOK: TButton
      Left = 20
      Top = 190
      Width = 80
      Height = 25
      Caption = 'OK'
      TabOrder = 2
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 140
      Top = 190
      Width = 80
      Height = 25
      Caption = 'Cancel'
      TabOrder = 3
      OnClick = btnCancelClick
    end
    object edPadIncrement: TEdit
      Left = 140
      Top = 50
      Width = 80
      Height = 21
      Hint = 'Enter designator incrementing index.'
      Alignment = taRightJustify
      NumbersOnly = True
      TabOrder = 1
      Text = '1'
    end
    object cbPrefix: TCheckBox
      Left = 20
      Top = 80
      Width = 100
      Height = 25
      Hint = 'Enable designator prefix.'
      Caption = 'Prefix'
      TabOrder = 4
      OnClick = cbPrefixClick
    end
    object cbSuffix: TCheckBox
      Left = 20
      Top = 110
      Width = 100
      Height = 25
      Hint = 'Enable designator suffix.'
      Caption = 'Suffix'
      TabOrder = 5
      OnClick = cbSuffixClick
    end
    object edPrefix: TEdit
      Left = 140
      Top = 80
      Width = 80
      Height = 21
      Hint = 'Enter designator prefix.'
      Alignment = taRightJustify
      Enabled = False
      TabOrder = 6
      Text = 'A'
    end
    object edSuffix: TEdit
      Left = 140
      Top = 110
      Width = 80
      Height = 21
      Hint = 'Enter designator suffix.'
      Alignment = taRightJustify
      Enabled = False
      TabOrder = 7
      Text = 'A'
    end
    object btnPreview: TButton
      Left = 20
      Top = 160
      Width = 80
      Height = 25
      Caption = 'Preview'
      TabOrder = 8
      OnClick = btnPreviewClick
    end
  end
end
