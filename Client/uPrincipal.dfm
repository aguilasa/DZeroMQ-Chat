object FPrincipal: TFPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Entre o nickname:'
  ClientHeight = 97
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 49
    Height = 13
    Caption = 'Nickname:'
  end
  object edNickname: TEdit
    Left = 8
    Top = 32
    Width = 269
    Height = 21
    TabOrder = 0
    OnKeyDown = edNicknameKeyDown
  end
  object Button1: TButton
    Left = 7
    Top = 59
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 89
    Top = 59
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 2
  end
end
