object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'MainForm'
  ClientHeight = 205
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 594
    Height = 199
    Align = alClient
    Lines.Strings = (
      'GUI mode is not done yet.'
      'Read how to use the "console mode" at'
      'https://github.com/TikoTako/GW2-MultiBox'
      ''
      'TL;DR;'
      
        'Create a shortcut to the program and pass the parameters to open' +
        ' the game with different settings.')
    TabOrder = 0
  end
end
