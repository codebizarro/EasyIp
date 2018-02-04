object mainForm: TmainForm
  Left = 571
  Top = 235
  Width = 461
  Height = 414
  Caption = 'mainForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 15
    Top = 20
    Width = 22
    Height = 13
    Caption = 'Host'
  end
  object Label2: TLabel
    Left = 210
    Top = 20
    Width = 48
    Height = 13
    Caption = 'Data type'
  end
  object pager: TPageControl
    Left = 15
    Top = 60
    Width = 416
    Height = 261
    ActivePage = sheetOnePoint
    TabOrder = 0
    object sheetOnePoint: TTabSheet
      Caption = 'Read one point'
      object Label3: TLabel
        Left = 10
        Top = 20
        Width = 39
        Height = 13
        Caption = 'Address'
      end
      object Label4: TLabel
        Left = 155
        Top = 20
        Width = 26
        Height = 13
        Caption = 'Value'
      end
      object editOffset: TEdit
        Left = 10
        Top = 40
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object editValue: TEdit
        Left = 155
        Top = 40
        Width = 121
        Height = 21
        Color = clMenu
        ReadOnly = True
        TabOrder = 1
      end
    end
    object sheetBlockRead: TTabSheet
      Caption = 'Read data block'
      ImageIndex = 1
    end
    object sheetInfo: TTabSheet
      Caption = 'Read device info'
      ImageIndex = 2
    end
  end
  object editHost: TEdit
    Left = 50
    Top = 15
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object comboDataType: TComboBox
    Left = 270
    Top = 15
    Width = 121
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    Items.Strings = (
      'Undefined'
      'Flag'
      'Input'
      'Output'
      'Register'
      'Timer')
  end
  object btnRefresh: TButton
    Left = 15
    Top = 333
    Width = 75
    Height = 25
    Caption = 'Refresh'
    TabOrder = 3
    OnClick = btnRefreshClick
  end
  object statusBar: TStatusBar
    Left = 0
    Top = 368
    Width = 453
    Height = 19
    Panels = <>
    SimplePanel = False
  end
end
