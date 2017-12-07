object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 163
  ClientWidth = 328
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 79
    Top = 18
    Width = 41
    Height = 13
    Caption = 'Task idle'
  end
  object Label2: TLabel
    Left = 32
    Top = 18
    Width = 35
    Height = 13
    Caption = 'Status:'
  end
  object btnStartTask: TButton
    Left = 32
    Top = 40
    Width = 137
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btnStartTaskClick
  end
  object btnPauseResume: TButton
    Left = 32
    Top = 71
    Width = 137
    Height = 25
    Caption = 'Pause/Resume'
    Enabled = False
    TabOrder = 1
    OnClick = btnPauseResumeClick
  end
  object btnCancelTask: TButton
    Left = 32
    Top = 102
    Width = 137
    Height = 25
    Caption = 'Cancel'
    Enabled = False
    TabOrder = 2
    OnClick = btnCancelTaskClick
  end
end
