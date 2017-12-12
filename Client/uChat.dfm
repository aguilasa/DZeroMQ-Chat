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
  end
  object PnMessages: TPanel
    Left = 0
    Top = 27
    Width = 434
    Height = 255
    Align = alClient
    TabOrder = 0
    ExplicitTop = 28
    ExplicitHeight = 254
    object Panel2: TPanel
      Left = 1
      Top = 218
      Width = 432
      Height = 36
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitTop = 217
      DesignSize = (
        432
        36)
      object EdMessage: TEdit
        Left = 7
        Top = 6
        Width = 354
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnKeyDown = EdMessageKeyDown
      end
      object BtnImage: TButton
        Left = 367
        Top = 4
        Width = 60
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Imagem'
        TabOrder = 1
        OnClick = BtnImageClick
      end
    end
    object LbMessages: TListBox
      Left = 1
      Top = 1
      Width = 432
      Height = 217
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
      ExplicitHeight = 216
    end
  end
  object PnTop: TPanel
    Left = 0
    Top = 0
    Width = 434
    Height = 27
    Align = alTop
    TabOrder = 2
    DesignSize = (
      434
      27)
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
