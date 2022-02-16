program DeObJS;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form16},
  DeObJsCode in 'DeObJsCode.pas',
  FMX.Log in 'FMX.Log.pas',
  UnitExpCalc in 'UnitExpCalc.pas',
  base64Ex in 'base64Ex.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm16, Form16);
  Application.Run;
end.
