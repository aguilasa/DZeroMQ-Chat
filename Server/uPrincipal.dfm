object FPrincipal: TFPrincipal
  Left = 0
  Top = 0
  Caption = 'ZeroMQ - Server'
  ClientHeight = 201
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 447
    Height = 41
    Align = alTop
    TabOrder = 0
    object BtnIniciar: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Iniciar'
      TabOrder = 0
      OnClick = BtnIniciarClick
    end
    object BtnPausar: TButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Pausar'
      Enabled = False
      TabOrder = 1
    end
    object Button1: TButton
      Left = 184
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 2
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 447
    Height = 160
    Align = alClient
    TabOrder = 1
    object MemoMessages: TMemo
      Left = 1
      Top = 1
      Width = 445
      Height = 158
      Align = alClient
      TabOrder = 0
    end
  end
end
