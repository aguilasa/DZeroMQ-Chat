object FPrincipal: TFPrincipal
  Left = 0
  Top = 0
  Caption = 'ZeroMQ - Chat'
  ClientHeight = 451
  ClientWidth = 636
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PnNick: TPanel
    Left = 0
    Top = 0
    Width = 636
    Height = 432
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 1
    ExplicitTop = -6
    object Label1: TLabel
      Left = 8
      Top = 56
      Width = 106
      Height = 13
      Caption = 'Informe o "nickname":'
    end
    object EdNick: TEdit
      Left = 8
      Top = 75
      Width = 619
      Height = 21
      TabOrder = 0
      OnKeyDown = EdNickKeyDown
    end
  end
  object StatusB: TStatusBar
    Left = 0
    Top = 432
    Width = 636
    Height = 19
    Panels = <
      item
        Text = 'Conectado como: '
        Width = 105
      end
      item
        Width = 50
      end>
    ExplicitLeft = 224
    ExplicitTop = 304
    ExplicitWidth = 0
  end
  object PnMessages: TPanel
    Left = 0
    Top = 0
    Width = 636
    Height = 432
    Align = alClient
    TabOrder = 1
    ExplicitHeight = 217
    object Panel2: TPanel
      Left = 1
      Top = 395
      Width = 634
      Height = 36
      Align = alBottom
      TabOrder = 0
      ExplicitLeft = 32
      ExplicitTop = 181
      ExplicitWidth = 510
      DesignSize = (
        634
        36)
      object EdMessage: TEdit
        Left = 7
        Top = 6
        Width = 619
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnKeyDown = EdMessageKeyDown
        ExplicitWidth = 495
      end
    end
    object ListBox1: TListBox
      Left = 1
      Top = 1
      Width = 634
      Height = 394
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
      ExplicitLeft = 72
      ExplicitTop = 16
      ExplicitWidth = 121
      ExplicitHeight = 97
    end
  end
end
