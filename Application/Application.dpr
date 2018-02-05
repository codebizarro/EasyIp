program Application;
//{$APPTYPE CONSOLE}
uses
  Forms,
  SysUtils,
  UMainForm in 'Source\UMainForm.pas' {mainForm},
  UTypes in 'Source\UTypes.pas',
  UDefaultPresenter in 'Source\UDefaultPresenter.pas',
  UEasyIpService in 'Source\UEasyIpService.pas',
  UHelperThread in 'Source\UHelperThread.pas';

begin
  Forms.Application.Initialize;
  Forms.Application.CreateForm(TmainForm, mainForm);
  Forms.Application.Run;
end.
