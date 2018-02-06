object mainForm: TmainForm
  Left = 571
  Top = 235
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'EasyIp Demo application'
  ClientHeight = 387
  ClientWidth = 453
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
    Top = 10
    Width = 22
    Height = 13
    Caption = 'Host'
  end
  object Label2: TLabel
    Left = 160
    Top = 10
    Width = 48
    Height = 13
    Caption = 'Data type'
  end
  object Label3: TLabel
    Left = 305
    Top = 10
    Width = 39
    Height = 13
    Caption = 'Address'
  end
  object pager: TPageControl
    Left = 15
    Top = 70
    Width = 416
    Height = 251
    ActivePage = sheetOnePoint
    TabOrder = 0
    object sheetOnePoint: TTabSheet
      Caption = 'Read one point'
      object Label4: TLabel
        Left = 10
        Top = 20
        Width = 26
        Height = 13
        Caption = 'Value'
      end
      object editValue: TEdit
        Left = 10
        Top = 40
        Width = 121
        Height = 21
        Color = clMenu
        ReadOnly = True
        TabOrder = 0
      end
    end
    object sheetBlockRead: TTabSheet
      Caption = 'Read data block'
      ImageIndex = 1
      object Label6: TLabel
        Left = 155
        Top = 20
        Width = 31
        Height = 13
        Caption = 'Values'
      end
      object Label7: TLabel
        Left = 10
        Top = 20
        Width = 61
        Height = 13
        Caption = 'Words count'
      end
      object spinLength: TSpinEdit
        Left = 10
        Top = 40
        Width = 121
        Height = 22
        MaxValue = 256
        MinValue = 1
        TabOrder = 0
        Value = 0
      end
      object listValues: TListBox
        Left = 155
        Top = 40
        Width = 236
        Height = 176
        ItemHeight = 13
        TabOrder = 1
      end
    end
    object sheetInfo: TTabSheet
      Caption = 'Read device info'
      ImageIndex = 2
      object memoInfo: TMemo
        Left = 10
        Top = 15
        Width = 386
        Height = 201
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object editHost: TEdit
    Left = 15
    Top = 30
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '10.20.0.104'
  end
  object comboDataType: TComboBox
    Left = 160
    Top = 30
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
  object editOffset: TEdit
    Left = 305
    Top = 30
    Width = 121
    Height = 21
    TabOrder = 5
    Text = '5000'
  end
end
