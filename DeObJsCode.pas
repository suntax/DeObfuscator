unit DeObJsCode;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
    System.Types, Web.HTTPApp, FMX.Log,
    System.Generics.Collections, System.NetEncoding;
    //三个关键字符串  _0x3d13，_0x3d8c，_0x23666d 分别为ABC，CDE, EFG 以示区别，涉及3个关键字函数均以上述开头。

type

    TEFG_Func = record
        FuncName: string;
        Formula: string;
        IsFormula: boolean;
    end;
    PEFG_Func = TEFG_Func;

    TEFG_ListFunc = TArray<TEFG_Func>;

    TGHI_Func = record
        FuncName: string;
        Formula: string;
        IsFormula: boolean;
    end;
    PGHI_Func = TGHI_Func;

    TGHI_ListFunc = TArray<TGHI_Func>;


    TDeObJs = class(TObject)
    private
        FABC: string;
        FCDE: string;
        FEFG: string;
        FABC_EndIndex: integer;
        FEFG_BeginIndex: integer;
        FEFG_EndIndex: integer;
        FEFG_Index: integer;

        FCryptType: integer;       //加密类型 默认 1,
        FCDE1: string;
        FCDE2: string;

        FGHI: string;
        FGHI_EndIndex: integer;
        FGHI_Index: integer;

        FJsFileName: string;
        FJsText: string;

        FABC_ListData: TStringList;
        FEFG_ListFuncData: TEFG_ListFunc;

        FEFG_DictFunc: TDictionary<string, string>;

        FGHI_ListFuncData: TGHI_ListFunc;

        FGHI_DictFunc: TDictionary<string, string>;

        procedure ReadJsFile(jsFileName: string);
        procedure WriteDeJsFile(jsFileName: string);
        function ABC_GetABC(): string;
        procedure ABC_SetListData();
        function CDE_GetCDE(): string;
        procedure CDE_ReplaceFuncData();
        function CDE_DeCryptCode(R1: string; R2: string): string;

        procedure CDE_SetCDE12();
        procedure CDE12_ReplaceFuncData(strCDE: string);
        function CDE12_DeCryptCode(R1: string; R2: string): string;

        function EFG_GetEFG(): string;
        procedure EFG_SetListFuncData();
        procedure EFG_ReplaceFuncData();

        function GHI_GetGHI(): string;
        procedure GHI_SetListFuncData();
        procedure GHI_ReplaceFuncData();

               // Quotation   ignore
    protected
        function ExtractTextBetweenBracketsCheckQuotationMark(LeftMark, RightMark: string; Index: integer): string;
        function ExtractTextBetweenBracketsIgnoreQuotationMark(LeftMark, RightMark: string; Index: integer): string;
        function ExtractTextBetweenBrackets(Text: string; LeftMark, RightMark: string): string;
        function CheckBracketsCheckQuotationMark(Text: string; LeftMark, RightMark: string): boolean;
        function CheckBrackets(Text: string; LeftMark, RightMark: string): boolean;
        function CheckQuotation(Text: string; QuotationMark: string): boolean;
    public
        constructor Create;
        destructor Destroy; override;

        property ABC: string read FABC write FABC;
        property CDE: string read FCDE write FCDE;
        property EFG: string read FEFG write FEFG;

        property JsFileName: string read FJsFileName write FJsFileName;

        procedure EFG_FuncData();

        procedure AutoDeObJsCodeFile();
        procedure DeObJsCodeFile();

    end;




implementation


uses
    UnitExpCalc, Base64Ex;


constructor TDeObJs.Create;
begin
    inherited;

    FABC_ListData := TStringList.Create;
    FEFG_DictFunc := TDictionary<string, string>.Create;
    FGHI_DictFunc := TDictionary<string, string>.Create;
    FEFG_Index := 1;
    FCryptType := 1;

    InitSignParam();
end;

//! Destructor
destructor TDeObJs.Destroy;
begin

    inherited;
end;


procedure TDeObJs.AutoDeObJsCodeFile();
var
    strDeJsFile: string;
begin
    ReadJsFile(FJsFileName);
    FABC := ABC_GetABC();
    Log.i('ABC：' + FABC);
    if not string.IsNullOrEmpty(FABC) then
    begin
        ABC_SetListData();
        if FCryptType = 1 then
        begin
            FCDE := CDE_GetCDE();
            Log.i('CDE：' + FCDE);
            if not string.IsNullOrEmpty(FCDE) then
            begin
                CDE_ReplaceFuncData();
            end;

            Repeat
                FEFG := '';
                FEFG := EFG_GetEFG();
                Log.i('EFG：' + FEFG);
                if not string.IsNullOrEmpty(FCDE) and not string.IsNullOrEmpty(FEFG) then
                begin
                    EFG_SetListFuncData();
                    EFG_ReplaceFuncData();
                end;
            Until FEFG = '';
        end;

        if FCryptType = 2 then
        begin
            CDE_SetCDE12();

            Repeat
                FGHI := '';
                FGHI := GHI_GetGHI();
                Log.i('GHI：' + FGHI);
                if not string.IsNullOrEmpty(FCDE1) and not string.IsNullOrEmpty(FCDE2) and not string.IsNullOrEmpty(FGHI) then
                begin
                    GHI_SetListFuncData();
                    GHI_ReplaceFuncData();
                end;
            Until FGHI = '';

            if not string.IsNullOrEmpty(FCDE1) then
            begin
                CDE12_ReplaceFuncData(FCDE1);
            end;

            if not string.IsNullOrEmpty(FCDE2) then
            begin
                CDE12_ReplaceFuncData(FCDE2);
            end;

        end;


    end;
    strDeJsFile := ExtractFilePath(FJsFileName) + 'De_' + ExtractFileName(FJsFileName);
    WriteDeJsFile(strDeJsFile);

end;


procedure TDeObJs.DeObJsCodeFile();
begin
    ReadJsFile(FJsFileName);
    ABC_SetListData();
    CDE_ReplaceFuncData();
  //  EFG_SetListFuncData();
  //  EFG_ReplaceFuncData();
end;

procedure TDeObJs.EFG_FuncData();
begin
    EFG_SetListFuncData();
    EFG_ReplaceFuncData();
end;


procedure TDeObJs.ReadJsFile(jsFileName: string);
var
    tsJs: TStringList;
    i: integer;
begin
    FJsText := '';
    tsJs := TStringList.Create;
    tsJs.LoadFromFile(jsFileName);
    for i := 0 to tsJs.Count - 1 do
    begin
        //tsJs[i] := StringReplace(tsJs[i], ' ', '', [rfReplaceAll]);
        FJsText := FJsText + tsJs[i];
    end;
    tsJs.Free;
    Log.i('源JS文件名：' + jsFileName);
end;

procedure TDeObJs.WriteDeJsFile(jsFileName: string);
var
    tsJs: TStringList;
    i: integer;
begin
    tsJs := TStringList.Create;
    tsJs.Clear;
    tsJs.Add(FJsText);
    tsJs.SaveToFile(jsFileName);
    tsJs.Free;
    Log.i('反编译JS文件名：' + jsFileName);
end;


//_0x3d13
function TDeObJs.ABC_GetABC(): string;
var
    strABC: string;
begin
    Result := '';
    if FJsText.StartsWith('var') then
    begin
        strABC := Copy(FJsText, Pos('var', FJsText) + 'var'.Length,
                Pos('=[', FJsText) - (Pos('var', FJsText) + 'var'.Length) ).Trim;

        while strABC.StartsWith('_0x') = false do
        begin
            strABC := Copy(strABC, Pos('var', strABC)+ 'var'.Length, strABC.Length).Trim;
        end;

        if Pos('_0x', strABC) > 0 then
        begin
            //FABC := strABC.Trim;
            Result := strABC.Trim;
        end;
    end;
end;

//_0x3d13
procedure TDeObJs.ABC_SetListData();
var
    strABC_Data: string;
    i,j: integer;
    strTemp: string;
    strABC_Index: string;
    intABC_Index: integer;
begin

    strABC_Data := ExtractTextBetweenBrackets(FJsText, FABC + '=[', '];');

    FABC_EndIndex := Pos((FABC + '=['), FJsText) + (FABC + '=[' + strABC_Data + '];').Length;

    strABC_Data := StringReplace(strABC_Data, '''', '', [rfReplaceAll]);

    FABC_ListData.Clear;
    FABC_ListData.Delimiter := ',';
    FABC_ListData.DelimitedText := strABC_Data;

    i := Pos(('(' + FABC + ','),FJsText);

    strTemp := Copy(FJsText, i + Length(('(' + FABC + ',')), 100);
    j := Pos(')', strTemp);
    strABC_Index := Copy(strTemp, 1, j - 1);

    //随即数
    strABC_Index := StringReplace(strABC_Index, '0x', '$', [rfReplaceAll]);

    if string.IsNullOrEmpty(strABC_Index) then
    begin
        FCryptType := 2;
        Log.i('加密方式：' + FCryptType.ToString);
    end
    else
    begin
        FCryptType := 1;
        FABC_EndIndex := i;
        Log.i('加密方式：' + FCryptType.ToString);

        if StrToInt(strABC_Index) < FABC_ListData.Count then
        begin
            for i := 0 to StrToInt(strABC_Index) - 1 do
            begin
                FABC_ListData.Add(FABC_ListData[i]);
            end;

            for i := 0 to StrToInt(strABC_Index) - 1 do
            begin
                FABC_ListData.Delete(0);
            end;

            //还原字符串
        end
        else
        begin

        end;
    end;
    //FABC_ListData.SaveToFile('123t.txt');
end;

//_0x3d8c
function TDeObJs.CDE_GetCDE(): string;
var
    strCDE: string;
    n,m,v: integer;
begin
    Result := '';
    if FABC_EndIndex > 0 then
    begin
        n := Pos('var', FJsText, FABC_EndIndex);
        m := Pos('=', FJsText, FABC_EndIndex);
        v := 'var'.Length;
        strCDE := Copy(FJsText, n + v, m - (n + v) );

        if Pos('_0x', strCDE) > 0 then
        begin
            //FCDE := strCDE.Trim;
            Result := strCDE.Trim;
        end;
    end;
end;


procedure TDeObJs.CDE_SetCDE12();
var
    strCDE1, strCDE2: string;
    strCDE1_Data, strCDE2_Data: string;
    strLeftMark,strRightMark: string;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    n,m,v: integer;
begin
    if FABC_EndIndex > 0 then
    begin
        n := Pos('var', FJsText, FABC_EndIndex);
        m := Pos('=', FJsText, FABC_EndIndex);
        v := 'var'.Length;
        strCDE1 := Copy(FJsText, n + v, m - (n + v) );

        if Pos('_0x', strCDE1) > 0 then
        begin
            FCDE1 := strCDE1.Trim;
            Log.i('CDE1：' + FCDE1);
        end;

        strLeftMark := '{';
        strRightMark :=  '}';

        FABC_EndIndex := Pos(FCDE1, FJsText, FABC_EndIndex);

        strCDE1_Data := ExtractTextBetweenBracketsCheckQuotationMark(strLeftMark, strRightMark, FABC_EndIndex);

        FABC_EndIndex := Pos(strLeftMark, FJsText, FABC_EndIndex) + (strCDE1_Data + strRightMark).Length;

        n := Pos('var', FJsText, FABC_EndIndex);
        m := Pos('=', FJsText, FABC_EndIndex);
        v := 'var'.Length;
        strCDE2 := Copy(FJsText, n + v, m - (n + v) );

        if Pos('_0x', strCDE2) > 0 then
        begin
            FCDE2 := strCDE2.Trim;
            Log.i('CDE2：' + FCDE2);
        end;

        FABC_EndIndex :=  Pos(FCDE2, FJsText, FABC_EndIndex);

        strCDE2_Data := ExtractTextBetweenBracketsCheckQuotationMark(strLeftMark, strRightMark, FABC_EndIndex);

        FABC_EndIndex := Pos(strLeftMark, FJsText, FABC_EndIndex) + (strCDE2_Data + strRightMark).Length;

        FGHI_Index := FABC_EndIndex;
    end;
end;

//_0x36b965
function TDeObJs.CDE_DeCryptCode(R1: string; R2: string): string;
var
    TMP: array[0..$100-1] of integer;
    m: integer;
    a: integer;
    B,C: string;
    Rx: string;
    i,j: integer;
    Base64: TBase64Encoding;
    Rb: TBytes;
begin
    m := 0;
    a := 0;
    B := '';
    C := '';

    //base64 to bin(str)
    Base64 := TBase64Encoding.Create;
    Rb := Base64.DecodeStringToBytes(R1);

    //bin（str） to  % + Hex
    for i := 0 to Length(Rb) -1 do
    begin
        C := C + '%' + Rb[i].ToHexString(2);
    end;

    //解码 decodeURI  to bin(str)
    Rx := Web.HTTPApp.HTTPDecode(C);

    if string.IsNullOrEmpty(R2) then    //另外一种解密
    begin
        Result := Rx;
        exit;
    end;

    //临时数组
    for i := 0 to $100 - 1 do
    begin
        TMP[i] := i;
    end;

    //计算  TMP[m]
    for i := 0 to $100 - 1 do
    begin
        m := (m + TMP[i] + Ord(R2[(i mod Length(R2)) + 1])) mod $100;
        a := TMP[i];
        TMP[i] := TMP[m];
        TMP[m] := a;
    end;

    j := 0;
    m := 0;

    for i := 0 to Length(Rx) -1 do
    begin
        j := (j + $1) mod $100;
        m := (m + TMP[j]) mod $100;
        a := TMP[j];
        TMP[j] := TMP[m];
        TMP[m] := a;
        B := B + Char(  Ord(Rx[i + 1]) xor TMP[ (TMP[j] + TMP[m]) mod $100 ]);
    end;
    Result := B;
end;

function TDeObJs.CDE12_DeCryptCode(R1: string; R2: string): string;
var
    TMP: array[0..$100-1] of integer;
    m: integer;
    a: integer;
    B,C: string;
    Rx: string;
    i,j: integer;
    Base64: TBase64Encoding;
    //Rb: TBytes;
    Rb: string;
begin
    m := 0;
    a := 0;
    B := '';
    C := '';

    //base64 to bin(str)
    Rb := Base64DecodeEx(R1);

    //bin（str） to  % + Hex
    for i := 0 to Length(Rb) -1 do
    begin
        C := C + '%' + Ord(Rb[i+1]).ToHexString(2);
    end;

    //解码 decodeURI  to bin(str)
    Rx := Web.HTTPApp.HTTPDecode(C);

    if string.IsNullOrEmpty(R2) then    //另外一种解密
    begin
        Result := Rx;
        exit;
    end;

    //临时数组
    for i := 0 to $100 - 1 do
    begin
        TMP[i] := i;
    end;

    //计算  TMP[m]
    for i := 0 to $100 - 1 do
    begin
        m := (m + TMP[i] + Ord(R2[(i mod Length(R2)) + 1])) mod $100;
        a := TMP[i];
        TMP[i] := TMP[m];
        TMP[m] := a;
    end;

    j := 0;
    m := 0;

    for i := 0 to Length(Rx) -1 do
    begin
        j := (j + $1) mod $100;
        m := (m + TMP[j]) mod $100;
        a := TMP[j];
        TMP[j] := TMP[m];
        TMP[m] := a;
        B := B + Char(  Ord(Rx[i + 1]) xor TMP[ (TMP[j] + TMP[m]) mod $100 ]);
    end;
    Result := B;
end;


//_0x3d8c
procedure TDeObJs.CDE_ReplaceFuncData();
var
    strCDE_Para, strCDE_funcData: string;
    strCDE_Ret: string;
    strR1,strR2: string;
    intR1: integer;
    strLeftMark,strRightMark: string;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
begin
    Repeat
        strLeftMark := FCDE + '(''';
        //strRightMark :=  ''')';
        strRightMark :=  ')';
        intBeginBracketsIndex := Pos(strLeftMark,FJsText);
        intEndBracketsIndex := Pos(strRightMark, FJsText, intBeginBracketsIndex);

        strCDE_Para := ExtractTextBetweenBracketsCheckQuotationMark(strLeftMark, strRightMark, intBeginBracketsIndex);

        strCDE_funcData := strLeftMark +  strCDE_Para + strRightMark;
        strCDE_Para := StringReplace(strCDE_Para, '''', '', [rfReplaceAll]);  //去掉 '引号

        if Pos(',', strCDE_Para) > 0 then
        begin
            strR1 := Copy(strCDE_Para, 1, Pos(',', strCDE_Para) - 1);
            strR2 := Copy(strCDE_Para, Pos(',', strCDE_Para) + 1, Length(strCDE_Para));
        end
        else     //没有逗号
        begin
            strR1 := strCDE_Para;
            strR2 := '';
        end;

        //if strR1 = '0x93c' then
        //begin
        //   strR1 := '0x93c';
        //end;

        strR1 := StringReplace(strR1, '0x' , '$', [rfReplaceAll]);
        intR1 := strR1.ToInteger;
        strR1 := FABC_ListData[intR1];
        strCDE_Ret := CDE_DeCryptCode(strR1,strR2);
        strCDE_Ret := StringReplace(strCDE_Ret, #$C , '/f', [rfReplaceAll]);
        strCDE_Ret := StringReplace(strCDE_Ret, #$A , '/n', [rfReplaceAll]);
        strCDE_Ret := StringReplace(strCDE_Ret, #$D , '/r', [rfReplaceAll]);
        strCDE_Ret := StringReplace(strCDE_Ret, #9 , '/t', [rfReplaceAll]);
        strCDE_Ret := StringReplace(strCDE_Ret, '\' , '\\', [rfReplaceAll]);
        strCDE_Ret := strCDE_Ret.QuotedString;
        FJsText := StringReplace(FJsText,  strCDE_funcData, strCDE_Ret, [rfReplaceAll]);
    Until (Pos(strLeftMark, FJsText) = 0);
end;


procedure TDeObJs.CDE12_ReplaceFuncData(strCDE: string);
var
    strCDE_Para, strCDE_funcData: string;
    strCDE_Ret: string;
    strR1,strR2, strR: string;
    intR1, intR: integer;
    strLeftMark,strRightMark: string;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    intRightMarkIndex: integer;
    arrR: TArray<string>;
    i: integer;
    dleCalRet: double;
    strOutInfo: string;
    tsTemp: TStrings;
begin
    tsTemp := TStringList.Create;
    intRightMarkIndex := 1;
    Repeat
        strLeftMark := strCDE + '(';
        //strRightMark :=  ''')';
        strRightMark :=  ')';
        intBeginBracketsIndex := Pos(strLeftMark,FJsText, intRightMarkIndex);
        intEndBracketsIndex := Pos(strRightMark, FJsText, intBeginBracketsIndex);

        strCDE_Para := ExtractTextBetweenBracketsCheckQuotationMark(strLeftMark, strRightMark, intBeginBracketsIndex);

        strCDE_funcData := strLeftMark +  strCDE_Para + strRightMark;
        strCDE_Para := StringReplace(strCDE_Para, '''', '', [rfReplaceAll]);  //去掉 '引号    -0xdb- -0xe9,-0xd1

        if Pos(',', strCDE_Para) > 0 then
        begin
            strR1 := Copy(strCDE_Para, 1, Pos(',', strCDE_Para) - 1);
            strR2 := Copy(strCDE_Para, Pos(',', strCDE_Para) + 1, Length(strCDE_Para));
        end
        else     //没有逗号
        begin
            strR1 := strCDE_Para;
            strR2 := '';
        end;

        //if strR1 = '0x93c' then
        //begin
        //   strR1 := '-0xdb- -0xe9';
        //end;

        arrR := strR1.Split(['-']);
        for i := 0 to Length(arrR) - 1 do
        begin
            strR := StringReplace(arrR[i], '0x' , '$', [rfReplaceAll]);
            intR := StrToIntDef(strR, 99999999);
            if intR = 99999999 then
            begin

            end
            else
            begin
                strR1 := StringReplace(strR1, arrR[i] , intR.ToString, [rfReplaceAll]);
            end;
       end;

       if CalcExp(strR1, dleCalRet, strOutInfo) then
       begin
          intR1 := dleCalRet.ToString.ToInteger;
          strR1 := FABC_ListData[intR1];
          if strCDE = FCDE1 then
          begin
              strR2 := '';
          end;
          strCDE_Ret := CDE12_DeCryptCode(strR1,strR2);
          strCDE_Ret := StringReplace(strCDE_Ret, #$C , '/f', [rfReplaceAll]);
          strCDE_Ret := StringReplace(strCDE_Ret, #$A , '/n', [rfReplaceAll]);
          strCDE_Ret := StringReplace(strCDE_Ret, #$D , '/r', [rfReplaceAll]);
          strCDE_Ret := StringReplace(strCDE_Ret, #9 , '/t', [rfReplaceAll]);
          strCDE_Ret := StringReplace(strCDE_Ret, '\' , '\\', [rfReplaceAll]);
          strCDE_Ret := strCDE_Ret.QuotedString;
          FJsText := StringReplace(FJsText,  strCDE_funcData, strCDE_Ret, [rfReplaceAll]);
       end
       else
       begin

       end;

       intRightMarkIndex := intBeginBracketsIndex + strLeftMark.Length;

        //tsTemp.Clear;
        //tsTemp.Add(FJsText);
        //tsTemp.SaveToFile('c:\12345678.txt');

    Until (Pos(strLeftMark, FJsText, intRightMarkIndex) = 0);
end;

function TDeObJs.EFG_GetEFG(): string;
var
    intEFG_BeginIndex, intEFG_EndIndex, intEFG_VARIndex, intEFG_Index: integer;
    strEFGVARMark, strEFGLeftMark, strEFGRightMark: string;
    strEFG: string;
begin
    //var _0x23666d={'Qhafz':function(_0x3e4d7e,_0x34ba06)
    strEFGVARMark := 'var';
    strEFGLeftMark := '={''';
    strEFGRightMark := ''':';
    //FEFG_Index := 1;
    strEFG := '';
    Result := '';
    Repeat
        intEFG_BeginIndex := Pos(strEFGLeftMark, FJsText, FEFG_Index);
        intEFG_EndIndex := Pos(strEFGRightMark, FJsText, intEFG_BeginIndex);
        intEFG_Index := intEFG_EndIndex - intEFG_BeginIndex;
        if (intEFG_EndIndex - intEFG_BeginIndex) = 8 then
        begin
            intEFG_VARIndex := Pos(strEFGVARMark, FJsText, intEFG_BeginIndex - 16);

            strEFG := Copy(FJsText, intEFG_VARIndex + strEFGVARMark.Length, intEFG_BeginIndex - (intEFG_VARIndex + strEFGVARMark.Length) );

            //if Pos('_0x', strEFG) > 0 then
            begin
                //FEFG := strEFG.Trim;
                Result := strEFG.Trim;
            end;
        end;
        FEFG_Index := intEFG_EndIndex;
    Until (Pos(strEFGLeftMark, FJsText, intEFG_EndIndex) = 0) or (not string.IsNullOrEmpty(strEFG));
end;


//_0x23666d
procedure TDeObJs.EFG_SetListFuncData();
var
    strEFG_Data: string;
    i,j: integer;
    strTemp: string;
    arrFunc,arrPara: TArray<string>;
    strKey,strValue: string;
    strLeftMark,strRightMark: string;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    strR, strFuncRet: string;
    n1,n2: integer;
begin
    //if FEFG = '_0x519d42' then
    //begin
    //  FEFG := '_0x519d42';
    //end;

    FEFG_DictFunc.Clear;
    strLeftMark := FEFG + '={';
    strRightMark :=  '};';
    intBeginBracketsIndex := Pos(strLeftMark,FJsText);
    intEndBracketsIndex := Pos(strRightMark, FJsText, intBeginBracketsIndex);

    strEFG_Data := Copy(FJsText, intBeginBracketsIndex + strLeftMark.Length,
                intEndBracketsIndex - (intBeginBracketsIndex + strLeftMark.Length) );

    arrFunc := strEFG_Data.Split([',']);

    for i := 0 to Length(arrFunc) -1 do
    begin
        if Pos(''':',arrFunc[i]) > 0 then
        begin
            strTemp := arrFunc[i];
            strKey := Copy(strTemp, 1, Pos(':',strTemp) - 1);
            strKey := strKey.Trim.DeQuotedString;
            strValue :=  Copy(strTemp, Pos(':',strTemp) + 1, Length(strTemp));
        end
        else
        begin
            strTemp := strTemp + ','+ arrFunc[i];
            strValue :=  Copy(strTemp, Pos(':',strTemp) + 1, Length(strTemp));
        end;


        if (Pos('function', strValue) > 0) and (Pos(';}', strValue) > 0) then
        begin
            strR := ExtractTextBetweenBrackets(strValue, 'function(', '){');
            strFuncRet := ExtractTextBetweenBrackets(strValue, 'return', ';}');

            arrPara := strR.Split([',']);

            for j := 0 to Length(arrPara) - 1 do
            begin
                strFuncRet := StringReplace(strFuncRet, arrPara[j].Trim , ' R' + IntToStr(j+1) + ' ', [rfReplaceAll]);
            end;

            strFuncRet := StringReplace(strFuncRet, ' (', '(', [rfReplaceAll]);
            strFuncRet := StringReplace(strFuncRet, ' )', ')', [rfReplaceAll]);
            strFuncRet := StringReplace(strFuncRet, '( ', '(', [rfReplaceAll]);
            strValue := StringReplace(strFuncRet, ' ,', ',', [rfReplaceAll]);
        end
        else if (Pos('function', strValue) = 0) then
        begin
            if Pos(''':',arrFunc[i]) = 0 then
            begin
            //    strTemp := strTemp + ','+ arrFunc[i];
             //   strValue :=  Copy(strTemp, Pos(':',strTemp) + 1, Length(strTemp));
            end;
        end;

        //if (strKey = 'HbePX') then
        //begin
        //    strKey :=  strKey;
        //end;

        if ((FEFG_DictFunc <> nil) and FEFG_DictFunc.ContainsKey(strKey)) then
        begin
            FEFG_DictFunc[strKey] := strValue;
        end
        else
        begin
            FEFG_DictFunc.Add(strKey, strValue);
        end;

    end;

end;

//_0x23666d
procedure TDeObJs.EFG_ReplaceFuncData();
var
    strEFG_FuncName: string;
    strEFG_Para, strEFG_funcData: string;
    strCDE_Ret: string;
    strR1,strR2: string;
    intR1: integer;
    strLeftMark,strRightMark: string;
    strLeftBracketsMark,strRightBracketsMark: string;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    tsPara, tsTemp: TStrings;
    i,j: integer;
    strPara: string;
    arrTemp: TArray<string>;
begin
    tsPara := TStringList.Create;
    tsTemp := TStringList.Create;
   try
    Repeat
        //(_0x23666d['aSbps'](_0x3f4d75, _0x4ccc2d)
        strLeftMark := FEFG + '[''';
        strRightMark :=  ''']';
        intBeginBracketsIndex := Pos(strLeftMark, FJsText);
        intEndBracketsIndex := Pos(strRightMark, FJsText, intBeginBracketsIndex);
        strEFG_FuncName := ExtractTextBetweenBracketsIgnoreQuotationMark(strLeftMark, strRightMark, intBeginBracketsIndex);
        strEFG_funcData := strLeftMark + strEFG_FuncName + strRightMark;

        //if (strEFG_FuncName = 'ENPFj') then
        //begin
        //    strEFG_FuncName := strEFG_FuncName + '';
        //end;

        strLeftBracketsMark := '(';
        strRightBracketsMark :=  ')';
        if FJsText[intEndBracketsIndex + 2]  = strLeftBracketsMark then    //函数
        begin
            strEFG_Para := ExtractTextBetweenBracketsCheckQuotationMark(strLeftBracketsMark, strRightBracketsMark, intEndBracketsIndex + 2);
            strEFG_funcData := strEFG_funcData + strLeftBracketsMark + strEFG_Para + strRightBracketsMark;

            //Log.i(strEFG_funcData);

            tsPara.Clear;

            //拆分 参数
            arrTemp := strEFG_Para.Split([',']);
            strPara := '';

            for i := 0 to Length(arrTemp) - 1 do
            begin
                if Trim(strPara) <> '' then
                begin
                    strPara := strPara + ', ' + arrTemp[i];
                end
                else
                begin
                    strPara := arrTemp[i];
                end;

                //如果是含有 function 检查 大括号{} 配对, 否则 检查 小括号()
                if strPara.StartsWith('function') then
                begin
                    if CheckBracketsCheckQuotationMark(strPara, '{', '}') = true then
                    begin
                        tsPara.Add(strPara);
                        strPara := '';
                    end;
                end
                else
                begin
                    if (CheckBracketsCheckQuotationMark(strPara, '(', ')') = true)
                        and (not string.IsNullOrEmpty(strPara)) then
                    begin
                        if strPara.Trim.StartsWith('''') then
                        begin
                           if strPara.Trim.StartsWith('''') and strPara.Trim.EndsWith('''') and (strPara.Trim <> '''') then
                           begin
                              tsPara.Add(strPara);
                              strPara := '';
                           end;

                        end
                        else
                        begin
                          tsPara.Add(strPara);
                          strPara := '';
                        end;
                    end;
                end;

            end;

            strCDE_Ret := FEFG_DictFunc[strEFG_FuncName];

            for i := 0 to tsPara.Count - 1 do
            begin
                strCDE_Ret := StringReplace(strCDE_Ret, 'R' + IntToStr(i+1), tsPara[i], [rfReplaceAll]);
            end;

            FJsText := StringReplace(FJsText, strEFG_funcData, strCDE_Ret, [rfReplaceAll]);

        end
        else
        begin
            if not string.IsNullOrEmpty(strEFG_FuncName) then
            begin
                strCDE_Ret := FEFG_DictFunc[strEFG_FuncName];

                FJsText := StringReplace(FJsText, strEFG_funcData, strCDE_Ret, [rfReplaceAll]);
            end;

        end;

        //tsTemp.Clear;
        //tsTemp.Add(FJsText);
        //tsTemp.SaveToFile('c:\12345678.txt');

    Until (Pos(strLeftMark, FJsText) = 0);

   // FJsText := StringReplace(FJsText, 'var', 'var ', [rfReplaceAll]);

//        tsTemp.Clear;
//        tsTemp.Add(FJsText);
//        tsTemp.SaveToFile('c:\12345678.txt');

    Except
      strPara := strEFG_Para;
    end;

end;


function TDeObJs.GHI_GetGHI(): string;
var
    intGHI_BeginIndex, intGHI_EndIndex, intGHI_VARIndex, intGHI_Index: integer;
    strGHIVARMark, strGHILeftMark, strGHIRightMark: string;
    strGHI, strFun: string;
begin
    //var _0x23666d={'Qhafz':function(_0x3e4d7e,_0x34ba06)
    strGHIVARMark := 'var';
    strGHILeftMark := 'var';
    //strGHIRightMark := '=function(';
    strGHIRightMark := '=';
    //FEFG_Index := 1;
    strGHI := '';
    Result := '';
    Repeat
        intGHI_VARIndex := Pos(strGHIVARMark, FJsText, FGHI_Index);
        intGHI_BeginIndex := intGHI_VARIndex;
        intGHI_EndIndex := Pos(strGHIRightMark, FJsText, intGHI_BeginIndex);

        strGHI := Copy(FJsText, intGHI_VARIndex + strGHIVARMark.Length, intGHI_EndIndex - (intGHI_VARIndex + strGHIVARMark.Length) );

        //if Pos('_0x11c1d1', strGHI) > 0 then
        //begin
        //    strGHI := strGHI;
        //end;

        //=function(
        strFun := Copy(FJsText, intGHI_EndIndex,('=function(').Length);
        if strFun = '=function('  then
        begin
            Result := strGHI.Trim;
        end
        else
        begin
            //strGHI := strGHI;
        end;

        FGHI_Index := intGHI_EndIndex;

    Until (Pos(strGHILeftMark, FJsText, intGHI_EndIndex) = 0) or (not string.IsNullOrEmpty(Result));
end;

procedure TDeObJs.GHI_SetListFuncData();
var
    strGHI_Data: string;
    i,j: integer;
    strTemp: string;
    arrFunc,arrPara: TArray<string>;
    strKey,strValue: string;
    strLeftMark,strRightMark: string;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    strR, strFuncRet: string;
    n1,n2: integer;
begin
    //if FGHI = '_0x519d42' then
    //begin
    //  FGHI := '_0x519d42';
    //end;

    FGHI_DictFunc.Clear;
    strLeftMark := FGHI + '=function(';
    strRightMark :=  '};';
    intBeginBracketsIndex := Pos(strLeftMark,FJsText);
    intEndBracketsIndex := Pos(strRightMark, FJsText, intBeginBracketsIndex);

    strGHI_Data := Copy(FJsText, intBeginBracketsIndex,
                (intEndBracketsIndex - intBeginBracketsIndex) + strRightMark.Length );

    strKey := FGHI;
    strValue := strGHI_Data;

//    arrFunc := strGHI_Data.Split([',']);

//    for i := 0 to Length(arrFunc) -1 do
    begin
        if (Pos('function', strValue) > 0) and (Pos(';}', strValue) > 0) then
        begin
            strR := ExtractTextBetweenBrackets(strValue, 'function(', '){');
            strFuncRet := ExtractTextBetweenBrackets(strValue, 'return', ';}');

            arrPara := strR.Split([',']);

            for j := 0 to Length(arrPara) - 1 do
            begin
                strFuncRet := StringReplace(strFuncRet, arrPara[j].Trim , 'R' + IntToStr(j+1), [rfReplaceAll]);
            end;

            //strFuncRet := StringReplace(strFuncRet, '0x', '$', [rfReplaceAll]); //?
            //strValue := StringReplace(strFuncRet, '_$', '_0x', [rfReplaceAll]);
            strValue := strFuncRet;
        end;

        if ((FGHI_DictFunc <> nil) and FGHI_DictFunc.ContainsKey(strKey)) then
        begin
            FGHI_DictFunc[strKey] := strValue;
        end
        else
        begin
            FGHI_DictFunc.Add(strKey, strValue);
        end;

    end;

end;

procedure TDeObJs.GHI_ReplaceFuncData();
var
    strGHI_FuncName: string;
    strGHI_Para, strGHI_funcData: string;
    strGHI_Ret: string;
    strR1,strR2: string;
    intR1: integer;
    strLeftMark,strRightMark: string;
    strLeftBracketsMark,strRightBracketsMark: string;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    tsPara, tsTemp: TStrings;
    i,j: integer;
    strPara: string;
    arrTemp, arrPara: TArray<string>;
begin
    tsPara := TStringList.Create;
    tsTemp := TStringList.Create;
   try
    Repeat
        //_0x4f91aa(-0x9e, -0x74, -0x24, -0x86, -0x1a)
        strLeftMark := FGHI + '(';
        strRightMark :=  ')';
        intBeginBracketsIndex := Pos(strLeftMark, FJsText);
        intEndBracketsIndex := Pos(strRightMark, FJsText, intBeginBracketsIndex);
        strGHI_Para := ExtractTextBetweenBracketsCheckQuotationMark(strLeftMark, strRightMark, intBeginBracketsIndex);
        strGHI_funcData := strLeftMark + strGHI_Para + strRightMark;
        strGHI_FuncName := FGHI;

        if (strGHI_FuncName = '_0x11c1d1') then
        begin
            strGHI_FuncName := strGHI_FuncName + '';
        end;

        //Log.i(strGHI_funcData);

        //拆分 参数
        arrPara := strGHI_Para.Split([',']);

        strGHI_Ret := FGHI_DictFunc[strGHI_FuncName];

        for i := 0 to Length(arrPara) - 1 do
        begin
            strGHI_Ret := StringReplace(strGHI_Ret, 'R' + IntToStr(i+1), arrPara[i], [rfReplaceAll]);
        end;

        FJsText := StringReplace(FJsText, strGHI_funcData, strGHI_Ret, [rfReplaceAll]);

        //tsTemp.Clear;
        //tsTemp.Add(FJsText);
        //tsTemp.SaveToFile('c:\12345678.txt');

    Until (Pos(strLeftMark, FJsText) = 0);

   // FJsText := StringReplace(FJsText, 'var', 'var ', [rfReplaceAll]);

//        tsTemp.Clear;
//        tsTemp.Add(FJsText);
//        tsTemp.SaveToFile('c:\12345678.txt');

    Except
      strPara := strGHI_Para;
    end;

end;



//取2个括号之间的数据 检查引号-注释
function  TDeObJs.ExtractTextBetweenBracketsCheckQuotationMark(LeftMark, RightMark: string; Index: integer): string;
var
    intBracketsCount, intBracketsIndex: integer;
    intLeftBracketsIndex,intRightBracketsIndex: integer;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    intLeftQuotationIndex,intRightQuotationIndex: integer;
    strQuotationMark: string;
    strBracketsText: string;
    strTempText: string;
begin
    //计算括号数量： 左括号( 发现一个增加1; 右括号) 发现一个减1 ；数量最后等于0时 取开始的与最后的括号之间的数值。
    //过滤 引号 中 的括号()
    strQuotationMark := '''';
    intBracketsCount := 0;
    intBracketsIndex := Index;
    intLeftBracketsIndex := 0;
    intRightBracketsIndex := 0;
    intBeginBracketsIndex := Pos(LeftMark, FJsText, intBracketsIndex);
    intBracketsIndex := Index;
    intEndBracketsIndex := Pos(RightMark, FJsText, intBracketsIndex);
    intLeftQuotationIndex := Pos(strQuotationMark, FJsText, intBracketsIndex);
    intRightQuotationIndex := Pos(strQuotationMark, FJsText, intLeftQuotationIndex + 1);

    Repeat
        intLeftBracketsIndex := Pos(LeftMark, FJsText, intBracketsIndex);
        intRightBracketsIndex := Pos(RightMark, FJsText, intBracketsIndex);

        intLeftQuotationIndex := Pos(strQuotationMark, FJsText, intBracketsIndex);
        intRightQuotationIndex := Pos(strQuotationMark, FJsText, intLeftQuotationIndex + 1);

        if (intLeftBracketsIndex = 0) and (intRightBracketsIndex = 0) then      // (intLeftBracketsIndex   )intRightBracketsIndex
        begin
            //
        end
        else if (intLeftBracketsIndex > 0) and
                (  (intRightBracketsIndex = 0)
                or (intLeftBracketsIndex < intRightBracketsIndex) ) then
        begin
            if (intLeftBracketsIndex < intLeftQuotationIndex)
                or (intLeftQuotationIndex = 0) then
            begin
                strTempText := Copy(FJsText, intLeftBracketsIndex + Length(LeftMark), intRightBracketsIndex -(intLeftBracketsIndex + Length(LeftMark)) );
                //Log.i(strTempText);
                //Log.i(intBracketsCount.ToString);
                intBracketsCount :=  intBracketsCount + 1;
                intBracketsIndex := intLeftBracketsIndex + 1;
            end
            else
            begin
                if intRightQuotationIndex > intLeftQuotationIndex then
                begin
                    intBracketsIndex := intRightQuotationIndex + 1;
                end
                else
                begin
                    intBracketsIndex := intLeftQuotationIndex + 1;
                end;
            end;
        end
        else if (intRightBracketsIndex > 0) and
                (  (intLeftBracketsIndex = 0)
                or (intRightBracketsIndex < intLeftBracketsIndex) ) then
        begin
            if (intRightBracketsIndex < intLeftQuotationIndex)
                or (intLeftQuotationIndex = 0) then
            begin
                strTempText := Copy(FJsText, intRightBracketsIndex + Length(RightMark), intLeftBracketsIndex -(intRightBracketsIndex + Length(RightMark)) );
                //Log.i(strTempText);
                //Log.i(intBracketsCount.ToString);
                intBracketsCount :=  intBracketsCount - 1;
                intBracketsIndex := intRightBracketsIndex + 1;
            end
            else
            begin
                if intRightQuotationIndex > intLeftQuotationIndex then
                begin
                    intBracketsIndex := intRightQuotationIndex + 1;
                end
                else
                begin
                    intBracketsIndex := intLeftQuotationIndex + 1;
                end;
            end;
        end;
    Until (intBracketsCount = 0) or ((intLeftBracketsIndex = 0) and  (intRightBracketsIndex = 0));

    intEndBracketsIndex := intBracketsIndex;

    strBracketsText := Copy(FJsText, intBeginBracketsIndex + Length(LeftMark), intEndBracketsIndex - (intBeginBracketsIndex + Length(LeftMark)) - 1);

    Result := strBracketsText;
end;


//取2个括号之间的数据 忽略引号-注释
function  TDeObJs.ExtractTextBetweenBracketsIgnoreQuotationMark(LeftMark, RightMark: string; Index: integer): string;
var
    intBracketsCount, intBracketsIndex: integer;
    intLeftBracketsIndex,intRightBracketsIndex: integer;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    strQuotationMark: string;
    strBracketsText: string;
    strTempText: string;
begin
    //计算括号数量： 左括号( 发现一个增加1; 右括号) 发现一个减1 ；数量最后等于0时 取开始的与最后的括号之间的数值。
    //过滤 引号 中 的括号()
    strQuotationMark := '''';
    intBracketsCount := 0;
    intBracketsIndex := Index;
    intLeftBracketsIndex := 0;
    intRightBracketsIndex := 0;
    intBeginBracketsIndex := Pos(LeftMark, FJsText, intBracketsIndex);
    intBracketsIndex := Index;
    intEndBracketsIndex := Pos(RightMark, FJsText, intBracketsIndex);

    Repeat
        intLeftBracketsIndex := Pos(LeftMark, FJsText, intBracketsIndex);
        intRightBracketsIndex := Pos(RightMark, FJsText, intBracketsIndex);

        if (intLeftBracketsIndex = 0) and (intRightBracketsIndex = 0) then      // (intLeftBracketsIndex   )intRightBracketsIndex
        begin
            //
        end
        else if (intLeftBracketsIndex > 0) and
                (  (intRightBracketsIndex = 0)
                or (intLeftBracketsIndex < intRightBracketsIndex) ) then
        begin
            strTempText := Copy(FJsText, intLeftBracketsIndex + Length(LeftMark), intRightBracketsIndex -(intLeftBracketsIndex + Length(LeftMark)) );
            intBracketsCount :=  intBracketsCount + 1;
            intBracketsIndex := intLeftBracketsIndex + 1;
        end
        else if (intRightBracketsIndex > 0) and
                ( (intLeftBracketsIndex = 0)
                or (intRightBracketsIndex < intLeftBracketsIndex) ) then
        begin
            strTempText := Copy(FJsText, intRightBracketsIndex + Length(RightMark), intLeftBracketsIndex -(intRightBracketsIndex + Length(RightMark)) );
            intBracketsCount :=  intBracketsCount - 1;
            intBracketsIndex := intRightBracketsIndex + 1;
        end;

    Until (intBracketsCount = 0) or ((intLeftBracketsIndex = 0) and  (intRightBracketsIndex = 0));

    intEndBracketsIndex := intBracketsIndex;

    strBracketsText := Copy(FJsText, intBeginBracketsIndex + Length(LeftMark), intEndBracketsIndex - (intBeginBracketsIndex + Length(LeftMark)) - 1);

    Result := strBracketsText;
end;



//取2个括号之间的数据
function  TDeObJs.ExtractTextBetweenBrackets(Text: string; LeftMark, RightMark: string): string;
var
    intBracketsCount, intBracketsIndex: integer;
    intLeftBracketsIndex,intRightBracketsIndex: integer;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    strBracketsText: string;
    strTempText: string;
begin
    //计算括号数量： 左括号( 发现一个增加1; 右括号) 发现一个减1 ；数量最后等于0时 取开始的与最后的括号之间的数值。
    intBracketsCount := 0;
    intBracketsIndex := 0;
    intLeftBracketsIndex := 0;
    intRightBracketsIndex := 0;
    strBracketsText := Text;
    strTempText := strBracketsText;
    intBeginBracketsIndex := Pos(LeftMark,strTempText);
    intEndBracketsIndex := Pos(RightMark,strTempText);
    Repeat
        intLeftBracketsIndex := Pos(LeftMark,strTempText);
        intRightBracketsIndex := Pos(RightMark,strTempText);
        if intLeftBracketsIndex > 0 then
        begin
            if intLeftBracketsIndex < intRightBracketsIndex then      // (intLeftBracketsIndex   )intRightBracketsIndex
            begin
                intBracketsCount :=  intBracketsCount + 1;
                strTempText := Copy(strTempText, intLeftBracketsIndex + Length(LeftMark), Length(strTempText));
                intBracketsIndex := intBracketsIndex + intLeftBracketsIndex;
            end
            else                // )intRightBracketsIndex    (intLeftBracketsIndex
            begin
                intBracketsCount :=  intBracketsCount - 1;
                strTempText := Copy(strTempText, intRightBracketsIndex + Length(RightMark), Length(strTempText));
                intBracketsIndex := intBracketsIndex + intRightBracketsIndex;
            end;
        end
        else if intRightBracketsIndex > 0 then
        begin
            intBracketsCount :=  intBracketsCount - 1;
            strTempText := Copy(strTempText, intRightBracketsIndex + Length(RightMark), Length(strTempText));
            intBracketsIndex := intBracketsIndex + intRightBracketsIndex;
        end;
    Until (intBracketsCount = 0) or ((intLeftBracketsIndex = 0) and  (intRightBracketsIndex = 0)) or (strTempText = '');

    intEndBracketsIndex := intBracketsIndex;

    strBracketsText := Copy(strBracketsText, intBeginBracketsIndex + Length(LeftMark), intEndBracketsIndex - intBeginBracketsIndex - 1);

    Result := strBracketsText;
end;

//检查括号配对情况，不配对，返回 false    检查引号-注释
function TDeObJs.CheckBracketsCheckQuotationMark(Text: string; LeftMark, RightMark: string): boolean;
var
    intBracketsCount, intBracketsIndex: integer;
    intLeftBracketsIndex,intRightBracketsIndex: integer;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    intLeftQuotationIndex,intRightQuotationIndex: integer;
    strQuotationMark: string;
    strBracketsText: string;
    strTempText: string;
begin
    //计算括号数量： 左括号( 发现一个增加1; 右括号) 发现一个减1 ；数量最后等于0时 取开始的与最后的括号之间的数值。
    //过滤 引号 中 的括号()
    Result := true;
    strTempText := Text;
    intBracketsCount := 0;

    strQuotationMark := '''';
    intBracketsCount := 0;
    intBracketsIndex := 1;
    intLeftBracketsIndex := 0;
    intRightBracketsIndex := 0;
    intBeginBracketsIndex := Pos(LeftMark, strTempText, intBracketsIndex);
    intBracketsIndex := 1;
    intEndBracketsIndex := Pos(RightMark, strTempText, intBracketsIndex);
    intLeftQuotationIndex := Pos(strQuotationMark, strTempText, intBracketsIndex);
    intRightQuotationIndex := Pos(strQuotationMark, strTempText, intLeftQuotationIndex + 1);

    Repeat
        intLeftBracketsIndex := Pos(LeftMark, strTempText);
        intRightBracketsIndex := Pos(RightMark, strTempText);

        intLeftQuotationIndex := Pos(strQuotationMark, strTempText);
        intRightQuotationIndex := Pos(strQuotationMark, strTempText, intLeftQuotationIndex + 1);

        if (intLeftBracketsIndex = 0) and (intRightBracketsIndex = 0) then      // (intLeftBracketsIndex   )intRightBracketsIndex
        begin
            //
        end
        else if (intLeftBracketsIndex > 0) and
                (  (intRightBracketsIndex = 0)
                or (intLeftBracketsIndex < intRightBracketsIndex) ) then
        begin
            if (intLeftBracketsIndex < intLeftQuotationIndex)
                or (intLeftQuotationIndex = 0) then
            begin
                strTempText := Copy(strTempText, intLeftBracketsIndex + Length(LeftMark), Length(strTempText) );
                intBracketsCount :=  intBracketsCount + 1;
                intBracketsIndex := intLeftBracketsIndex + 0;
            end
            else
            begin
                if intRightQuotationIndex > intLeftQuotationIndex then
                begin
                    intBracketsIndex := intRightQuotationIndex + 0;
                end
                else
                begin
                    intBracketsIndex := intLeftQuotationIndex + 0;
                end;
                strTempText := Copy(strTempText, intBracketsIndex + Length(strQuotationMark), Length(strTempText) );
            end;
        end
        else if (intRightBracketsIndex > 0) and
                (  (intLeftBracketsIndex = 0)
                or (intRightBracketsIndex < intLeftBracketsIndex) ) then
        begin
            if (intRightBracketsIndex < intLeftQuotationIndex)
                or (intLeftQuotationIndex = 0) then
            begin
                strTempText := Copy(strTempText, intRightBracketsIndex + Length(RightMark), Length(strTempText) );
                intBracketsCount :=  intBracketsCount - 1;
                intBracketsIndex := intRightBracketsIndex + 0;
            end
            else
            begin
                if intRightQuotationIndex > intLeftQuotationIndex then
                begin
                    intBracketsIndex := intRightQuotationIndex + 0;
                end
                else
                begin
                    intBracketsIndex := intLeftQuotationIndex + 0;
                end;
                strTempText := Copy(strTempText, intBracketsIndex + Length(strQuotationMark), Length(strTempText) );
            end;
        end;
    Until ((Pos(LeftMark,strTempText) = 0) and  (Pos(RightMark,strTempText) = 0)) or (strTempText = '');

    if intBracketsCount > 0 then
    begin
        Result := false;
    end;

end;


//检查括号配对情况，不配对，返回 false
function  TDeObJs.CheckBrackets(Text: string; LeftMark, RightMark: string): boolean;
var
    intBracketsCount, intBracketsIndex: integer;
    intLeftBracketsIndex,intRightBracketsIndex: integer;
    intBeginBracketsIndex,intEndBracketsIndex: integer;
    strBracketsText: string;
    strTempText: string;

    L_all: string;
    L_temp: string;
    n_parentheses: integer;     //动态括号数量  ( + 1,  )  - 1
    m1,m2:integer;
begin
    Result := true;
    strTempText := Text;
    intBracketsCount := 0;
    Repeat
        intLeftBracketsIndex := Pos(LeftMark,strTempText);
        intRightBracketsIndex := Pos(RightMark,strTempText);
        if intLeftBracketsIndex > 0 then
        begin
            if (intLeftBracketsIndex < intRightBracketsIndex) and (intLeftBracketsIndex > 0) then      // (intLeftBracketsIndex   )intRightBracketsIndex
            begin
                intBracketsCount :=  intBracketsCount + 1;
                strTempText := Copy(strTempText, intLeftBracketsIndex + Length(LeftMark), Length(strTempText));
            end
            else if(intRightBracketsIndex < intLeftBracketsIndex) and (intRightBracketsIndex > 0) then               // )intRightBracketsIndex    (intLeftBracketsIndex
            begin
                intBracketsCount :=  intBracketsCount - 1;
                strTempText := Copy(strTempText, intRightBracketsIndex + Length(RightMark), Length(strTempText));
            end
            else if (intLeftBracketsIndex = 0) and (intRightBracketsIndex > 0) then
            begin
                intBracketsCount :=  intBracketsCount - 1;
                strTempText := Copy(strTempText, intRightBracketsIndex + Length(RightMark), Length(strTempText));
            end
            else if (intRightBracketsIndex = 0) and (intLeftBracketsIndex > 0) then
            begin
                intBracketsCount :=  intBracketsCount + 1;
                strTempText := Copy(strTempText, intLeftBracketsIndex + Length(LeftMark), Length(strTempText));
            end;

        end
        else if intRightBracketsIndex > 0 then
        begin
            intBracketsCount :=  intBracketsCount - 1;
            strTempText := Copy(strTempText, intRightBracketsIndex + Length(RightMark), Length(strTempText));
        end;
    Until ((Pos(LeftMark,strTempText) = 0) and  (Pos(RightMark,strTempText) = 0)) or (strTempText = '');

    if intBracketsCount > 0 then
    begin
        Result := false;
    end;
end;

function TDeObJs.CheckQuotation(Text: string; QuotationMark: string): boolean;
var
    intQuotationCount, intQuotationIndex: integer;
    strTempText: string;
begin
    Result := true;
    strTempText := Text;
    intQuotationCount := 0;
    Repeat
        intQuotationIndex := Pos(QuotationMark, strTempText);
        if intQuotationIndex > 0 then
        begin
            intQuotationCount :=  intQuotationCount + 1;
            strTempText := Copy(strTempText, intQuotationIndex + Length(QuotationMark), Length(strTempText));
        end;
    Until (Pos(QuotationMark,strTempText) = 0) or (strTempText = '');

    if (intQuotationCount mod 2) =  1 then
    begin
        Result := false;
    end;

end;


end.
