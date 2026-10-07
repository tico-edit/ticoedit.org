{ hello.pas: a friendly greeting from tico. }

program Hello;

var
  I: Integer;

begin
  if ParamCount = 0 then
    WriteLn('Hello, world!')
  else
    for I := 1 to ParamCount do
      WriteLn('Hello, ', ParamStr(I), '!');
end.
