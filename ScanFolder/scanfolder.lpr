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
  Classes, SysUtils, FileUtil, DateUtils;

const
  VERSION = '1.1';
  DATE_FORMAT = 'yyyy-mm-dd';

type
  TScanOption = (soSimple, soPath, soSize, soDate, soHelp);

var
  Option: TScanOption;
  SearchPath: string;
  SearchPattern: string;
  ShowHelp: Boolean = False;

procedure DisplayHelp;
begin
  WriteLn('ScanFolder v', VERSION, ' - File search utility');
  WriteLn('Usage:');
  WriteLn('  ScanFolder [options] <path> <search_pattern>');
  WriteLn;
  WriteLn('Options:');
  WriteLn('  -p          Show full file paths');
  WriteLn('  -s          Show file sizes in KB');
  WriteLn('  -d          Show file dates');
  WriteLn('  -h, --help  Show this help message');
  WriteLn;
  WriteLn('Examples:');
  WriteLn('  ScanFolder D:\ *document*');
  WriteLn('  ScanFolder -p C:\ *.pas');
  WriteLn('  ScanFolder -s D:\Projects\ *.*');
  WriteLn('  ScanFolder -d C:\Windows\ *.exe');
end;

procedure ParseParameters;
var
  i: Integer;
  Param: string;
begin
  if ParamCount = 0 then
  begin
    ShowHelp := True;
    Exit;
  end;

  // Default option
  Option := soSimple;

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
    else if i = ParamCount - 1 then
    begin
      SearchPath := IncludeTrailingPathDelimiter(Param);
      Inc(i);
    end
    else if i = ParamCount then
    begin
      SearchPattern := Param;
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

procedure ScanAndDisplayFiles;
var
  slFileList: TStringList;
  i: Integer;
  stFileName: string;
  intFileSize: Int64;
  datFileDate: TDateTime;
  DisplayStr: string;
begin
  slFileList := FindAllFiles(SearchPath, SearchPattern, True);
  try
    if slFileList.Count = 0 then
    begin
      WriteLn('No files found matching "', SearchPattern, '" in ', SearchPath);
      Exit;
    end;

    for i := 0 to slFileList.Count - 1 do
    begin
      stFileName := slFileList[i];

      case Option of
        soSimple:
          DisplayStr := ExtractFileName(stFileName);
        soPath:
          DisplayStr := stFileName;
        soSize:
          begin
            intFileSize := FileSize(stFileName);
            DisplayStr := Format('%-20s %s',
              ['[' + FormatFileSize(intFileSize) + ']', stFileName]);
          end;
        soDate:
          begin
            datFileDate := FileDateToDateTime(FileAge(stFileName));
            DisplayStr := Format('%-20s %s',
              ['[' + FormatDateTime(DATE_FORMAT, datFileDate) + ']', stFileName]);
          end;
      end;

      WriteLn(DisplayStr);
    end;

    WriteLn;
    WriteLn('Found ', slFileList.Count, ' files');
  finally
    slFileList.Free;
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
