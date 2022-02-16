unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtDlgs,
  DeObJsCode;

type
  TForm16 = class(TForm)
    Memo1: TMemo;
    OpenTextFileDialog1: TOpenTextFileDialog;
    Button3: TButton;
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form16: TForm16;
    deObJs: TDeObJs;

implementation

{$R *.dfm}

procedure TForm16.Button3Click(Sender: TObject);
begin
    OpenTextFileDialog1.Filter := 'JSÎÄ¼þ(*.js,*.JS)|*.js;*.JS';;

    if OpenTextFileDialog1.Execute() then
    begin
        Memo1.Lines.Add(OpenTextFileDialog1.FileName);

        deObJs := TDeObJs.Create;
        deObJs.JsFileName := OpenTextFileDialog1.FileName;
        deObJs.AutoDeObJsCodeFile;
    end;

end;

end.
