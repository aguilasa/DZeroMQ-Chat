object FChat: TFChat
  Left = 0
  Top = 0
  Caption = 'ZeroMQ - Chat'
  ClientHeight = 358
  ClientWidth = 636
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusB: TStatusBar
    Left = 0
    Top = 339
    Width = 636
    Height = 19
    Panels = <
      item
        Text = 'Conectado como: '
        Width = 105
      end>
  end
  object PnMessages: TPanel
    Left = 0
    Top = 28
    Width = 636
    Height = 311
    Align = alClient
    TabOrder = 0
    object Panel2: TPanel
      Left = 1
      Top = 274
      Width = 634
      Height = 36
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
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
      end
    end
    object LbMessages: TListBox
      Left = 1
      Top = 1
      Width = 634
      Height = 273
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
      ExplicitLeft = 32
      ExplicitTop = 24
      ExplicitWidth = 121
      ExplicitHeight = 97
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 636
    Height = 28
    Align = alTop
    TabOrder = 2
    object btnConnect: TButton
      Left = 2
      Top = 1
      Width = 75
      Height = 25
      Caption = 'Conectar'
      TabOrder = 0
      OnClick = btnConnectClick
    end
  end
end
