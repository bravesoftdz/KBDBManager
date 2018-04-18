object fmDBSettings: TfmDBSettings
  Left = 519
  Top = 328
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'DB Settings'
  ClientHeight = 187
  ClientWidth = 485
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 18
  object RzLabel1: TRzLabel
    Left = 16
    Top = 8
    Width = 68
    Height = 18
    Caption = 'User Name'
  end
  object RzLabel2: TRzLabel
    Left = 264
    Top = 8
    Width = 59
    Height = 18
    Caption = 'Password'
  end
  object RzLabel3: TRzLabel
    Left = 16
    Top = 64
    Width = 57
    Height = 18
    Caption = 'DB Name'
  end
  object RzLabel4: TRzLabel
    Left = 264
    Top = 64
    Width = 28
    Height = 18
    Caption = 'Host'
  end
  object ebUserName: TRzEdit
    Left = 16
    Top = 32
    Width = 209
    Height = 26
    Text = ''
    FrameStyle = fsBump
    FrameVisible = True
    TabOrder = 0
  end
  object ebPassword: TRzEdit
    Left = 264
    Top = 32
    Width = 209
    Height = 26
    Text = ''
    FrameStyle = fsBump
    FrameVisible = True
    PasswordChar = '*'
    TabOrder = 1
  end
  object ebDBName: TRzEdit
    Left = 16
    Top = 88
    Width = 209
    Height = 26
    Text = ''
    FrameStyle = fsBump
    FrameVisible = True
    TabOrder = 2
  end
  object ebHost: TRzEdit
    Left = 264
    Top = 88
    Width = 209
    Height = 26
    Text = ''
    FrameStyle = fsBump
    FrameVisible = True
    TabOrder = 3
  end
  object btnOK: TRzBitBtn
    Left = 317
    Top = 158
    Caption = '&OK'
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TRzBitBtn
    Left = 398
    Top = 158
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = btnCancelClick
  end
  object ckbWindowsAuth: TRzCheckBox
    Left = 16
    Top = 128
    Width = 200
    Height = 20
    Caption = 'Use Windows  Authentication'
    HotTrack = True
    State = cbUnchecked
    TabOrder = 6
    OnClick = ckbWindowsAuthClick
  end
end
