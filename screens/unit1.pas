unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

const
  devResolutionX = 1280;
  devResolutionY = 800;
  useResolutionX = 1600; // how to get / read out this property?
  useResolutionY = 1200; // how to get / read out this property?

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  MonId          : integer;
  Mon            : TMonitor;
  I              : integer;
  ScreenCount    : integer;
  P              : TPoint;
  AllMonitorsWidth, AllMonitorsHeight: integer;



begin


  //Form1.Height := Form1.Height+devResolutionY-useResolutionY;
  //Form1.Width  := Form1.Width+devResolutionX-useResolutionX;




  Memo1.Clear;
  Memo1.Lines.Append(Format('Number of monitors: %d', [Screen.MonitorCount]));







  Memo1.Clear;
  ScreenCount := Screen.MonitorCount;
  P := Mouse.CursorPos;

  Memo1.Font.Name := 'Courier new';//'Dejavu Sans' 'Courier new';
  Memo1.Font.Size := 10;

  Memo1.Lines.Add('Monitor number:       ' + IntToStr(ScreenCount) );
  //Memo1.Lines.Add('Mouse.CursorPos:      ' + IntToStr(P.X) + ' x ' + IntToStr(P.Y) );

  {
  for I := 0 to ScreenCount-1 do
  begin
    Memo1.Lines.Add( '' );
    Memo1.Lines.Add('Screen.Width:       '+ IntToStr(Screen.Width));
    Memo1.Lines.Add('Monitor:            '+IntToStr(Screen.Monitors[I].MonitorNum) );
    Memo1.Lines.Add('Top:                '+IntToStr(Screen.Monitors[I].Top) );
    Memo1.Lines.Add('Left:               '+IntToStr(Screen.Monitors[I].Left) );
    Memo1.Lines.Add('Width:              '+IntToStr(Screen.Monitors[I].Width) );
    Memo1.Lines.Add('Height:             '+IntToStr(Screen.Monitors[I].Height) );
    //Memo1.Lines.Add('MonitorFromRect(mdNearest):  ' + IntToStr( (Screen.MonitorFromRect( TRect.Create(P,100,100), mdNearest)).MonitorNum) );
  end;
  }

  Memo1.Lines.Add( '' );
  Memo1.Lines.Add( '######################' );





  for MonId := 0 to Screen.MonitorCount - 1 do
  begin

    Mon := Screen.Monitors[MonId];

    With Memo1.Lines do
    begin
      Append('');
      Append(Format('--------  Monitor #%d  --------', [mon.MonitorNum]));
      Append(Format('Resolution: %dpx x %dpx', [Mon.Width, Mon.Height]));
      Append(Format('X-offset: %dpx', [Mon.Left]));
      Append(Format('Y-offset: %dpx', [Mon.Top]));
    end;

  end;





  //AllMonitorsWidth  := GetSystemMetrics(SM_CXVIRTUALSCREEN);
  //AllMonitorsHeight := GetSystemMetrics(SM_CYVIRTUALSCREEN);


  //With Memo1.Lines do
  //  begin
  //    Append('');
  //    Append('--------  All monitors  --------');
  //    Append(Format('Resolution: %dpx x %dpx', [AllMonitorsWidth, AllMonitorsHeight]));
  //    Append(Format('PPI: %d', [Screen.PixelsPerInch]));
  //  end;



  With Memo1.Lines do
    begin
      Append('');
      Append('--------  Monitors Scale  --------');
      Append(Format('Scale: %g', [(Screen.PixelsPerInch / 96.0)*100]));
    end;



  end;
end.

