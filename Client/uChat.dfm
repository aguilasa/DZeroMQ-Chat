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
    object Splitter1: TSplitter
      Left = 285
      Top = 1
      Height = 217
      Align = alRight
      Visible = False
      ExplicitLeft = 272
      ExplicitTop = 48
      ExplicitHeight = 100
    end
    object Panel2: TPanel
      Left = 1
      Top = 218
      Width = 432
      Height = 36
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        432
        36)
      object EdMessage: TEdit
        Left = 7
        Top = 6
        Width = 355
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnKeyDown = EdMessageKeyDown
      end
      object BtnImagem: TButton
        Left = 364
        Top = 4
        Width = 66
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Imagem'
        TabOrder = 1
        OnClick = BtnImagemClick
      end
    end
    object MemoMessages: TListBox
      Left = 1
      Top = 1
      Width = 284
      Height = 217
      Align = alClient
      Constraints.MinWidth = 280
      ItemHeight = 13
      TabOrder = 1
      OnClick = MemoMessagesClick
    end
    object PnImage: TPanel
      Left = 288
      Top = 1
      Width = 145
      Height = 217
      Align = alRight
      TabOrder = 2
      Visible = False
      object Image1: TImage
        Left = 1
        Top = 1
        Width = 143
        Height = 215
        Align = alClient
        Stretch = True
        ExplicitLeft = 64
        ExplicitTop = 96
        ExplicitWidth = 105
        ExplicitHeight = 105
      end
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
  object openDialog: TOpenPictureDialog
    Filter = 'JPEG Image File (*.jpg)|*.jpg|JPEG Image File (*.jpeg)|*.jpeg'
    Left = 272
    Top = 131
  end
end
