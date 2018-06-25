//grep32.exe wrapper utility.
//28-29 March 2016
//Tough bone, finished by recursing to internet resouces/information.

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellAPI, Registry; {This header/unit (i.e. ShellAPI) is needed for the
  ShellExecute function/procedure. It sure was a hard time finding what header
  was needed! A hint is given if one looks up the ShellExecute
  function/procedure in the help menu then QuickInfo->Header File->shellapi.h}

type
  TEdit = class(StdCtrls.TEdit)
  protected
    procedure WMDropFiles(var Message: TWMDropFiles); message WM_DROPFILES;
  end;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Edit1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Edit2DblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  S0, S1, S2, S3: string;
  S4: string = '/C grep32 -r-lido';
  S4a: string = '/C grep32 -r-ldo';
  S4b: string = '/C grep32 -r-lio';
  S4c: string = '/C grep32 -r-lo';
  S5: string = ' "';
  S6: string = '"';
  S7: string = ' > ';
  MyStartupInfo: TStartupInfo;
  MyProcessInfo: TProcessInformation;
  MyBuffer: array[0..MAX_PATH] of Char;
  MyRegistry: TRegistry;
  MyKey: HKEY;
  MyDirectory: string;
  SystemDir: string;
  
implementation

{$R *.DFM}
//-- TEdit class augmentation --//
procedure TEdit.WMDropFiles(var Message: TWMDropFiles);
var
  c: integer;
  fn: array[0..MAX_PATH-1] of char;
begin

  c := DragQueryFile(Message.Drop, $FFFFFFFF, fn, MAX_PATH);

  if c <> 1 then
  begin
    MessageBox(Handle, 'Too many files.', 'Drag and drop error', MB_ICONERROR);
    Exit;
  end;

  if DragQueryFile(Message.Drop, 0, fn, MAX_PATH) = 0 then Exit;

  Text := fn; //this the the class' Text variable, like Edit1.Text
  S2 := fn; //I've put this here but now can't understand its purpose

end;
//-- TEdit class augmentation ends--//

procedure TForm1.Button1Click(Sender: TObject);
begin
  if not FileExists('grep32.exe') then
    begin
      MessageBox(Handle, 'Could not find GREP32.EXE ', 'File Missing', MB_ICONERROR);
      Exit;
    end;
  S1 := Trim(Edit1.Text);
  S2 := Trim(Edit2.Text);
  S3 := Trim(Edit3.Text);
  if GetFileAttributes(PChar(S2)) =  FILE_ATTRIBUTE_DIRECTORY then
    begin
      if CheckBox1.Checked = True then
        S0 := S4a+S5+S1+S6+S5+S2+S6+S7+S3
      else
        S0 := S4+S5+S1+S6+S5+S2+S6+S7+S3;
    end
  else
    begin
      if CheckBox1.Checked = True then
        S0 := S4c+S5+S1+S6+S5+S2+S6+S7+S3
      else
        S0 := S4b+S5+S1+S6+S5+S2+S6+S7+S3;
    end;
  GetSystemDirectory(MyBuffer, MAX_PATH - 1);
  StrCat(MyBuffer, '\cmd.exe');
  SetLength(SystemDir, StrLen(MyBuffer)); //a little bit of help from the net here!
  SystemDir := MyBuffer;
  if not CreateProcess(PChar(SystemDir), PChar(S0), nil, nil, False, NORMAL_PRIORITY_CLASS, nil, nil, MyStartupInfo, MyProcessInfo) then MessageBox(Handle, PChar(SysErrorMessage(GetLastError)), 'System Error!', MB_ICONERROR);
  WaitForSingleObject(MyProcessInfo.hProcess, INFINITE);
  if CheckBox2.Checked = True then ShellExecute(0, 'open', PChar(S3), nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Edit2.Handle, true);
end;

procedure TForm1.Edit1DblClick(Sender: TObject);
begin
  Edit1.SelectAll;
end;

procedure TForm1.Edit2DblClick(Sender: TObject);
begin
  Edit2.SelectAll;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  MyRegistry := TRegistry.Create; //you have to call the (class) constructor yourself!
  MyKey := MyRegistry.RootKey; //not used
  if MyRegistry.OpenKey('Software\Grep32Companion\', True) then
    begin
      MyDirectory := MyRegistry.ReadString('Directory');
      if StrLen(PChar(MyDirectory)) > 0 then Edit2.Text := MyDirectory;
      MyRegistry.CloseKey;
    end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if MyRegistry.OpenKey('Software\Grep32Companion\', True) then
    begin
      MyRegistry.WriteString('Directory',Trim(Edit2.Text));
      MyRegistry.CloseKey;
    end;
end;

end.
