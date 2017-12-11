object FChat: TFChat
  Left = 0
  Top = 0
  Caption = 'ZeroMQ - Chat'
  ClientHeight = 301
  ClientWidth = 434
  Color = clBtnFace
  Constraints.MinHeight = 340
  Constraints.MinWidth = 450
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
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
    Top = 282
    Width = 434
    Height = 19
    Panels = <
      item
        Text = 'Conectado como: '
        Width = 105
      end>
    ExplicitTop = 339
    ExplicitWidth = 636
  end
  object PnMessages: TPanel
    Left = 0
    Top = 28
    Width = 434
    Height = 254
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 636
    ExplicitHeight = 311
    object Panel2: TPanel
      Left = 1
      Top = 217
      Width = 432
      Height = 36
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitTop = 274
      ExplicitWidth = 634
      DesignSize = (
        432
        36)
      object EdMessage: TEdit
        Left = 7
        Top = 6
        Width = 417
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnKeyDown = EdMessageKeyDown
        ExplicitWidth = 619
      end
    end
    object LbMessages: TListBox
      Left = 1
      Top = 1
      Width = 432
      Height = 216
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
      ExplicitLeft = 2
      ExplicitWidth = 434
      ExplicitHeight = 290
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 434
    Height = 28
    Align = alTop
    TabOrder = 2
    ExplicitWidth = 636
    DesignSize = (
      434
      28)
    object Label1: TLabel
      Left = 4
      Top = 6
      Width = 53
      Height = 13
      Caption = 'Nickname:'
    end
    object btnConnect: TButton
      Left = 355
      Top = 1
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Conectar'
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object edNickname: TEdit
      Left = 62
      Top = 3
      Width = 291
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      OnKeyDown = edNicknameKeyDown
    end
  end
end
