{
program ScanFolder;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes,
  { you can add units after this }
  Types, SysUtils, FileUtil, ULog; //IOUtils;



{
procedure ScanFolder(const Path: String);
var
  sPath   : string;
  rec     : TSearchRec;
begin
  //WriteLn('ScanFolder:',Path);

  sPath := IncludeTrailingPathDelimiter(Path);
  if FindFirst(sPath + '*.pas', faAnyFile, rec) = 0 then
  begin
    repeat
     {
      if (rec.Attr and faDirectory) <> 0 then
      begin
        ScanFolder(sPath + rec.Name);
      end;
      }

      {
      // item is a directory
      if (rec.Name <> '.') and (rec.Name <> '..') then
      begin
           ScanFolder(sPath + rec.Name);
           WriteLn('ScanFOLDER:',Path);
      end


      // item is a file
      else
      begin
           WriteLn('ScanFILE:',Path);
      end;
      }


      WriteLn('Filename:',sPath, rec.Name);

    until FindNext(rec) <> 0;
    FindClose(rec);

  end;
end;
}




procedure ScanFolder(const sOption, sPath, sPhrase: String)Overload;
var
  SL      : TStringList;
  i       : Integer;
  FS      : String;
  FSS     : string;

begin

  SL := TStringList.Create;
  SL := (FindAllFiles(sPath,sPhrase,True));



  for i := 0 to SL.Count-1 do
  begin
       if (sOption.Equals('-p')) then
          WriteLn((SL[i]));
       if (sOption.Equals('-s')) then
          begin

            FSS:= IntToStr( FileSize(SL[i]) div 1024 );
            FS := Concat('[' , FSS , '] KB');

            WriteLn(Format('%-25s %s', [FS, SL[i]]));
          end;
       if (sOption.Equals('-d')) then
          begin
            WriteLn(Format('%-25s %s', [ '[ ' + DateToStr(FileDateToDateTime( FileAge(SL[i]) )) + ' ]', SL[i] ] ));
          end;

  end;

  SL.SaveToFile(ParamStr(0)+'LOG');
end;



procedure ScanFolder(const sPath, sPhrase: String)Overload;
var
  S       : TStringList;
  i       : Integer;

begin

  S := TStringList.Create;
  S := (FindAllFiles(sPath,sPhrase,True));

  for i := 0 to S.Count-1 do
  begin
       WriteLn(( ExtractFileName(S[i]) ));
  end;

  S.SaveToFile(ParamStr(0)+'LOG');
end;




// No need for this function for testing
//function FileLCLR(const sPath, sPhrase: String): string;
//var
//  S       : TStringList;
//  i       : Integer;
//begin
//
//  S := TStringList.Create;
//  S := (FindAllFiles(sPath,sPhrase,True));
//
//  for i := 0 to S.Count-1 do
//  begin
//       WriteLn((S[i]));
//  end;
//  Result:= S.Text;
//end;





//var
//  ilog :TLog;
begin

  //Log the result
  //ilog := TLog.Create();
  //ilog._AddLog( 'Test1' );
  //ilog._AddLog('motaibi','xxxxxxxxxx');
  //WriteLn(ilog._GetLog());

  //OLD scan Folder
  //ScanFolder('C:\Users\m1\');

  //FileLCL('C:\');
  //FileLCL('D:\', '*SAEI*');


  if(ParamCount = 2 ) then
      begin
        ScanFolder(ParamStr(1), ParamStr(2));
      end

  else if(ParamCount = 3 ) then
      begin
        ScanFolder(ParamStr(1), ParamStr(2), ParamStr(3));
      end


  else
      begin
           WriteLn('');
           WriteLn('Enter: sOption *sPath *sPhrase');
           WriteLn('               * : Mandatory Value');
           WriteLn('');
           WriteLn('EX.: ScanFolder D:\ *document* ');
           WriteLn('EX.: ScanFolder C:\ *pas');
           WriteLn('EX.: ScanFolder -p to see full path');
           WriteLn('EX.: ScanFolder -s to see file size');
           WriteLn('EX.: ScanFolder -d to see file date of creation');
      end;

  WriteLn('');
  Write('END.');
end.

}







program ScanFolder;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, FileUtil, DateUtils, StrUtils;

const
  VERSION = '1.2';
  DATE_FORMAT = 'yyyy-mm-dd';

type
  TScanOption = (soSimple, soPath, soSize, soDate, soHelp, soDateRange);

var
  Option: TScanOption;
  SearchPath: string;
  SearchPattern: string;
  DateFrom: TDateTime;
  DateTo: TDateTime;
  HasDateRange: Boolean = False;
  ShowHelp: Boolean = False;

procedure DisplayHelp;
begin
  WriteLn('ScanFolder v', VERSION, ' - File search utility');
  WriteLn('Usage:');
  WriteLn('  ScanFolder [options] <path> <search_pattern> [date_from..date_to]');
  WriteLn;
  WriteLn('Options:');
  WriteLn('  -p          Show full file paths');
  WriteLn('  -s          Show file sizes in KB');
  WriteLn('  -d          Show file dates');
  WriteLn('  -r          Filter by date range (use with date_from..date_to)');
  WriteLn('  -h, --help  Show this help message');
  WriteLn;
  WriteLn('Date format: ', DATE_FORMAT);
  WriteLn('Examples:');
  WriteLn('  ScanFolder D:\ *document*');
  WriteLn('  ScanFolder -p C:\ *.pas');
  WriteLn('  ScanFolder -s D:\Projects\ *.*');
  WriteLn('  ScanFolder -d C:\Windows\ *.exe');
  WriteLn('  ScanFolder -r C:\Reports\ *.pdf 2023-01-01..2023-12-31');
end;

function TryStrToDateRange(const DateStr: string; out FromDate, ToDate: TDateTime): Boolean;
var
  DateParts: TStringArray;
begin
  Result := False;
  DateParts := DateStr.Split(['..']);
  if Length(DateParts) <> 2 then Exit;

  if TryStrToDate(DateParts[0], FromDate) and TryStrToDate(DateParts[1], ToDate) then
    Result := True;
end;

procedure ParseParameters;
var
  i: Integer;
  Param: string;
  LastParam: string;
begin
  if ParamCount = 0 then
  begin
    ShowHelp := True;
    Exit;
  end;

  // Default option
  Option := soSimple;
  HasDateRange := False;

  // Parse options
  i := 1;
  while i <= ParamCount do
  begin
    Param := ParamStr(i);

    if (Param = '-h') or (Param = '--help') then
    begin
      ShowHelp := True;
      Exit;
    end
    else if Param = '-p' then
    begin
      Option := soPath;
      Inc(i);
    end
    else if Param = '-s' then
    begin
      Option := soSize;
      Inc(i);
    end
    else if Param = '-d' then
    begin
      Option := soDate;
      Inc(i);
    end
    else if Param = '-r' then
    begin
      Option := soDateRange;
      Inc(i);
    end
    else if i = ParamCount - 2 then
    begin
      SearchPath := IncludeTrailingPathDelimiter(Param);
      Inc(i);
    end
    else if i = ParamCount - 1 then
    begin
      SearchPattern := Param;
      Inc(i);
    end
    else if i = ParamCount then
    begin
      LastParam := Param;
      // Check if this is a date range
      if TryStrToDateRange(LastParam, DateFrom, DateTo) then
      begin
        HasDateRange := True;
      end
      else if Option = soDateRange then
      begin
        WriteLn('Error: Invalid date range format. Use yyyy-mm-dd..yyyy-mm-dd');
        ShowHelp := True;
        Exit;
      end;
      Inc(i);
    end
    else
    begin
      WriteLn('Error: Invalid parameter "', Param, '"');
      ShowHelp := True;
      Exit;
    end;
  end;

  // Validate parameters
  if (SearchPath = '') or (SearchPattern = '') then
  begin
    WriteLn('Error: Missing required parameters');
    ShowHelp := True;
  end;
end;

function FormatFileSize(Size: Int64): string;
begin
  if Size < 1024 then
    Result := IntToStr(Size) + ' bytes'
  else if Size < 1024 * 1024 then
    Result := IntToStr(Size div 1024) + ' KB'
  else if Size < 1024 * 1024 * 1024 then
    Result := FormatFloat('0.00', Size / (1024 * 1024)) + ' MB'
  else
    Result := FormatFloat('0.00', Size / (1024 * 1024 * 1024)) + ' GB';
end;

function FileInDateRange(const FileName: string): Boolean;
var
  FileDate: TDateTime;
begin
  if not HasDateRange then
    Exit(True);

  FileDate := FileDateToDateTime(FileAge(FileName));
  Result := (FileDate >= DateFrom) and (FileDate <= DateTo);
end;

procedure ScanAndDisplayFiles;
var
  FileList: TStringList;
  i: Integer;
  FileName: string;
  intFileSize: Int64;
  FileDate: TDateTime;
  DisplayStr: string;
  FilesInRange: Integer;
begin
  FileList := FindAllFiles(SearchPath, SearchPattern, True);
  try
    if FileList.Count = 0 then
    begin
      WriteLn('No files found matching "', SearchPattern, '" in ', SearchPath);
      Exit;
    end;

    FilesInRange := 0;
    for i := 0 to FileList.Count - 1 do
    begin
      FileName := FileList[i];

      if not FileInDateRange(FileName) then
        Continue;

      Inc(FilesInRange);

      case Option of
        soSimple:
          DisplayStr := ExtractFileName(FileName);
        soPath:
          DisplayStr := FileName;
        soSize:
          begin
            intFileSize := FileSize(FileName);
            DisplayStr := Format('%-12s %s',
              ['[' + FormatFileSize(intFileSize) + ']', FileName]);
          end;
        soDate, soDateRange:
          begin
            FileDate := FileDateToDateTime(FileAge(FileName));
            DisplayStr := Format('%-15s %s',
              ['[' + FormatDateTime(DATE_FORMAT, FileDate) + ']', FileName]);
          end;
      end;

      WriteLn(DisplayStr);
    end;

    WriteLn;
    if HasDateRange then
      WriteLn('Found ', FilesInRange, ' files (', FileList.Count, ' total) in date range ',
        FormatDateTime(DATE_FORMAT, DateFrom), '..', FormatDateTime(DATE_FORMAT, DateTo))
    else
      WriteLn('Found ', FileList.Count, ' files');
  finally
    FileList.Free;
  end;
end;

begin
  ParseParameters;

  if ShowHelp then
  begin
    DisplayHelp;
    Exit;
  end;

  try
    if not DirectoryExists(SearchPath) then
    begin
      WriteLn('Error: Directory "', SearchPath, '" does not exist');
      Exit;
    end;

    ScanAndDisplayFiles;
  except
    on E: Exception do
      WriteLn('Error: ', E.Message);
  end;

  WriteLn;
  WriteLn('Done.');
end.




