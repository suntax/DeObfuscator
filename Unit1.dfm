object Form16: TForm16
  Left = 0
  Top = 0
  Caption = 'DeObfuscator'
  ClientHeight = 285
  ClientWidth = 517
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 517
    Height = 177
    Align = alTop
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Button3: TButton
    Left = 95
    Top = 216
    Width = 138
    Height = 25
    Caption = 'DeObfuscator'
    TabOrder = 1
    OnClick = Button3Click
  end
  object OpenTextFileDialog1: TOpenTextFileDialog
    Left = 328
    Top = 208
  end
end
