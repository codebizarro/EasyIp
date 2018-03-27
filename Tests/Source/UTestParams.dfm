object TestParams: TTestParams
  Left = 463
  Top = 440
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Configuration '
  ClientHeight = 171
  ClientWidth = 187
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ipList: TListBox
    Left = 15
    Top = 15
    Width = 156
    Height = 97
    ItemHeight = 13
    TabOrder = 0
    OnDblClick = ipListDblClick
  end
  object btOk: TButton
    Left = 15
    Top = 130
    Width = 75
    Height = 25
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 1
  end
  object btCancel: TButton
    Left = 95
    Top = 130
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
  end
end
