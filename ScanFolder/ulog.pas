unit ULog;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;


type

{ TLog }

TLog = class(TObject)
private

public
SL : TStringList;
constructor Create();
destructor  Destroy; override;

procedure _AddLog(AText: string);
procedure _AddLog(AFrom, AText : string);
procedure _AddLog(E: Exception);


function _GetMsgErrorLog(E: Exception): string;
function _GetTimeDate(): string;
function _GetLog(): string; overload;
//function _GetLog(ASL:TStringList):TStringList; overload;
//function _GetLog(ASL:TStringList):string; overload;


end;


implementation


{ TLog }

constructor TLog.Create;
begin
  SL := TStringList.Create;
end;

destructor TLog.Destroy;
begin
  inherited Destroy;
  SL.free;
end;

procedure TLog._AddLog(AText: string);
begin
  //{$IFDEF CONSOLE}Writeln(AText);{$ENDIF}
  SL.Add(AText);
end;

procedure TLog._AddLog(AFrom, AText: string);
begin
  _AddLog('[' + AFrom + '] - ' + _GetTimeDate + ': ' + AText);
end;

function TLog._GetMsgErrorLog(E: Exception): string;
begin
  Result := 'Error.Class: ' + Trim(E.ClassName) + ' | ' + 'Error.Message: ' + Trim(E.Message);
end;

function TLog._GetTimeDate: string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

function TLog._GetLog: string;
begin
  Result := SL.Text;
end;

procedure TLog._AddLog(E: Exception);
begin
  Self._AddLog('[ Exception ] - ' + Trim(E.ClassName) +  Self._GetMsgErrorLog(E));
end;

end.

