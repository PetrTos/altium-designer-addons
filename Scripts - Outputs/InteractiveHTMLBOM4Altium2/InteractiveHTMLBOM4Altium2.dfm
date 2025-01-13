object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'MainFrm'
  ClientHeight = 573
  ClientWidth = 733
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 280
    Top = 144
    Width = 101
    Height = 13
    Caption = 'WORK IN PROGRESS'
  end
  object GroupBox1: TGroupBox
    Left = 32
    Top = 360
    Width = 224
    Height = 144
    Caption = 'Units'
    TabOrder = 0
    object ShowUnitsChk: TCheckBox
      Left = 16
      Top = 72
      Width = 97
      Height = 17
      Caption = 'Show Units'
      TabOrder = 0
    end
    object ComboBox1: TComboBox
      Left = 16
      Top = 104
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
    object RadioButton1: TRadioButton
      Left = 16
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Imperial'
      TabOrder = 2
    end
    object RadioButton2: TRadioButton
      Left = 136
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Metric'
      TabOrder = 3
    end
  end
  object GroupBox2: TGroupBox
    Left = 264
    Top = 360
    Width = 185
    Height = 144
    Caption = 'GroupBox2'
    TabOrder = 1
    object FieldSeparatorCb: TComboBox
      Left = 8
      Top = 24
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
  end
  object GroupBox3: TGroupBox
    Left = 456
    Top = 360
    Width = 264
    Height = 144
    Caption = 'GroupBox3'
    TabOrder = 2
    object LayerFilterCb: TComboBox
      Left = 8
      Top = 24
      Width = 145
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 532
    Width = 733
    Height = 41
    Align = alBottom
    Caption = 'Panel1'
    ParentBackground = False
    TabOrder = 3
    object OKBtn: TButton
      Left = 440
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
      OnClick = OKBtnClick
    end
    object CancelBtn: TButton
      Left = 544
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = CancelBtnClick
    end
  end
end
