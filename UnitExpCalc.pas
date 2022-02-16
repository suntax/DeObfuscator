{License, info, etc
 ------------------

This implementation is made by Tang qishi (Satrry), to contact me
mail to 619325079@qq.com or tangqishi@gmail.com

This implementaion is available at
http://www.cnblogs.com/tangqs/archive/2011/11/03/2234715.html

copyright 2011, Tang qishi
This header may not be removed.

Version V2.6
Create time : 2017-02-28
}
  //********************************************************************************/
  //*   ��ѧ���ʽ��������    ����:����ʱ Tang qishi (Satrry)  2012.01-2017.02     */
  //*   ������ַ����ϸ���������´������أ�                                         */
  //*   http://www.cnblogs.com/tangqs/archive/2011/11/03/2234715.html              */
  //*   �иĽ���������κδ�����ת����,���˲�ʤ�м���                            */
  //*   E-Mail:619325079@qq.com                                                    */
  //*   (  ת��ʱ�뱣����˵��:)  )                                                 */
  //********************************************************************************/


  {
  /*   ���÷�ʽ��CalcExp('1+max(0.5,sin(1))+sum(1,2^3,mod(5,3))', res, infoStr)   */
  /*   �����Ų������÷���,�ȵ��÷��Ŷ���AddSignParam���ٵ��� CalcExp��            */
  /*        AddSignParam(['a','s'], [1, 0.5]);  ���� AddSignParam('a=1,s=0.5')    */
  /*        CalcExp('1+a+sin(s)', res, infoStr)                                   */
  /*   ����res�洢��������Ϊdouble�ͣ�infoStr�洢����ʱ����ʾ��Ϣ,Ϊstring      */
  //*******************************************************************************/
  /*   ���ʽ֧�ֵĹ��ܣ�                                                         */
  /*   1���������� + - * / ������()������(+ -)                                    */
  /*   2���ٷ��� %������ ^ �������׳� ! (1 �� 150)                                */
  /*   3�����Ų������㣬ʾ����a+b,ʹ��ǰҪ�ȶ������ֵ������AddSignParam����      */
  /*                    AddSignParam('a=1,b=0.5')                                 */
  /*   4������e��Բ����PI                                                         */
  /*   5���ḻ�ĺ�������:                                                         */
  /*          ͳ�ƺ�����   max,min,sum,avg,stddev ��׼ƫ���֧�ֶ����          */
  /*          ���Ǻ���:    sin,cos,tan,arcsin,arccos,arctan                       */
  /*                       degrad(60)   �Ƕ�ת����                                */
  /*                       raddeg(3.14) ����ת�Ƕ�                                */
  /*                       costh(a,b,c) ���Ҷ��� cosC)                            */
  /*         ָ������������sqrt,power(x,y),abs,exp,log2,log10,logN(a,N),ln        */
  /*         ���ݴ�������int(x),trunc(x) ȡ��                                   */
  /*                       frac(x) ȡС������                                     */
  /*                       round(x) ��������ȡ��                                  */
  /*                       roundto(x,-1) ����һλС��                             */
  /*                       mod(M,N) ��ģ                                          */
  /*         �������������s_tria(a,b,c) ���������                               */
  /*                       s_circ(r)     Բ�����                                 */
  /*                       s_elli(a,b)   ��Բ���                                 */
  /*                       s_rect(a,b)   �������                                 */
  /*                       s_poly(a,n)   ����������                             */
  /*        ƽ�漸�κ����� pdisplanes(x1,y1,x2,y2) ƽ���������                   */
  /*                       pdisspace(x1,y1,z1,x2,y2,z2) �ռ�����                  */
  /*                       p_line(x0,y0, A, B, C) ƽ��㵽�߾���                  */
  /*                       p_planes(x0,y0,z0 A, B, C, D)�ռ�㵽�����            */
  /*        �������:      sn(a1, d, n) �Ȳ�����ǰn���                           */
  /*                       sqn(a1, q, n) �ȱ�����ǰn���                          */
  /*      ��˰���㺯����   intax(x), arcintax(x) ��˰����                         */
  /*                       morrep(A,i,N,trpe,monthN)                              */
  /*   5����ʷ�����¼��˫�������¼�������޸ļ���                                */
  /*   ʾ��: sin(1)+(-2+(3-4))*20% , e^63+PI , 15! , log2(max(2,3)                */
  /*   ע: ���������Ϊ��Ǹ�ʽ�����Ǻ�Ϊ���ȣ�������ÿո���                   */
  //*******************************************************************************/}

unit UnitExpCalc;

interface
uses
  SysUtils, Variants, Classes, StdCtrls, StrUtils, Dialogs, math;
type
  TSetChar = set of char;
  RecStack = record
    sv: TStringList;
    top: integer;
  end;

  function CalcExp(const aExpT: string; out calResult: double; out AInfo: string): boolean;
  function CheckCalcExp(const ExpT: string; out AInfo: string): boolean;
  function CheckFun(): boolean;
  function AddSignParam(const ASignList: array of string; ASignValue: array of double): integer; overload;
  function AddSignParam(const ASignParamStr: string): integer; overload;
  function GetSignParam(Aindex: integer = 0): string; overload;
  function GetSignParam(const AParamName: string): string; overload;
  function DelSignParam(const AParamName: string): Boolean;
  procedure InitSignParam();      // ����û��Զ���Ĳ������ָ����� pi, e
  // ����Ϊ�������ڲ����ú���
  {
  procedure Init();
  procedure FreeRes();

  procedure replaceSignParam(var AExpT: string);
  procedure SetError(var AError: boolean; var AErrorStr: string; const AStr: string);
  function Push(var aStack: RecStack; const values: string): boolean;      // ��ջ
  function Pop(var aStack: RecStack; out values: string): boolean;         // ��ջ
  function GetTop(var aStack: RecStack): string;
  function GetSyP(sy: char): integer;
  function GetStackStr(const aStack: RecStack): string;
  function GetParamStr(const AParamStr: string; const AParamN: integer): string;
  function IsCalcFun(const AFunName: string; const ACalcFunList: TStringList): boolean;
  function GetFunParamN(const AFunName: string; const ACalcFunList: TStringList):integer;
  function GetFunParamValuse(const AParamStr: string; var A_Valuse_arr: array of double): boolean;
  function CheckCalcFun(const ACalcFunList: TStringList): boolean;
  // �Զ��庯�� 
  function IncomeTaxCalc(const AValues: double): double;     // ���¸�˰���㺯��
  function ArcIncomeTaxCalc(const AValues: double): double;  // ���¸�˰���㺯��
  function My_max(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_min(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_sum(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_avg(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_stdDev(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_cosTh(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_AreaTriangle(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_PlanesPointDis(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_SpacePointDis(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_PointToLineDis(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_PointToPlanesDis(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_SumSubSeri(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  function My_SumRatioSeri(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
  }

implementation

var
  symbolSets, numberSets: TSetChar;
  sMathFun: TStringList;
  SignArr: array of string;
  SignValueArr: array of double;
//*************************************************************************
//*************************************************************************
function AddSignParam(const ASignList: array of string; ASignValue: array of double): integer;
var    // ���ø�ʽ��AddSignParam(['a','b','c'], [1, 2,3]);
  i, j, minPN: integer;
  f_sameParam: Boolean;
begin
  result := 0;
  for i := 0 to High(ASignList) do    // �������ַ��Ƿ���ȷ
  begin
    if ASignList[i] = '' then Exit;
    if not (ASignList[i][1] in ['A'..'Z', 'a'..'z'])then Exit; // ��������ĸ����Ϊ��ĸ
    for j := 1 to Length(ASignList[i]) do
      if not (ASignList[i][j] in ['A'..'Z', 'a'..'z', '0'..'9', '_'])then Exit;
  end;
  minPN := Min(High(ASignList), High( ASignValue));
  for i := 0 to minPN do
  begin
    Inc(result);
    f_sameParam := false;
    for j := 0 to High(SignArr) do     // �޸��Ѵ��ڵķ������Ӧֵ
    begin
      if ASignList[i] = SignArr[j] then
      begin
        SignValueArr[j] := ASignValue[i];
        f_sameParam := true;
        Break;
      end;
    end;  // for
    if not f_sameParam then        // �����������Ӧֵ
    begin
      SetLength(SignValueArr, Length(SignValueArr) + 1);
      SignValueArr[high(SignValueArr)] :=  ASignValue[i];
      SetLength(SignArr, Length(SignArr) + 1);
      SignArr[high(SignArr)] := ASignList[i];
    end;
  end;          // for
end;

function AddSignParam(const ASignParamStr: string): integer;
var     // ���ø�ʽ��AddSignParam('a=1,b=2.1,c=3');
  i, j, minPN, commPos, equPos: integer;
  signStr, signValStr, tmpStr: string;
  signValue: double;
  f_signErr, f_sameParam: Boolean;
begin
  result := 0;
  if Length(ASignParamStr) < 3 then Exit;
  commPos := 0;
  for i := 1 to Length(ASignParamStr) do
  begin
    if ASignParamStr[i] = '=' then
    begin
      equPos := i;
      signStr := midStr(ASignParamStr, commPos + 1, equPos - commPos - 1);
      f_signErr := false;
      if signStr = '' then f_signErr := true
      else
        if not (signStr[1] in ['A'..'Z', 'a'..'z']) then f_signErr := true
        else
          for j := 1 to length(signStr) do
            if not (signStr[j] in ['A'..'Z', 'a'..'z', '0'..'9', '_'])then f_signErr := true;

    end;   // if ASignParamStr[i] = '=' then
    if (ASignParamStr[i] = ',') or (i = Length(ASignParamStr))then
    begin
      commPos := i;
      if i = Length(ASignParamStr) then commPos := i + 1;
      signValStr := midStr(ASignParamStr, equPos + 1, commPos - equPos - 1);
      if TryStrToFloat(signValStr, signValue) and (not f_signErr) then
      begin
        //****************************
        result := result + 1;
        f_sameParam := false;
        for j := 0 to High(SignArr) do     // �޸��Ѵ��ڵķ������Ӧֵ
        begin
          if signStr = SignArr[j] then
          begin
            SignValueArr[j] := signValue;
            f_sameParam := true;
            Break;
          end;
        end;  // for
        if not f_sameParam then        // �����������Ӧֵ
        begin
          SetLength(SignValueArr, Length(SignValueArr) + 1);
          SignValueArr[high(SignValueArr)] :=  signValue;
          SetLength(SignArr, Length(SignArr) + 1);
          SignArr[high(SignArr)] := signStr;
        end;
        //********************************
      end;   // if
    end;
  end;
end;

procedure ReplaceSignParam(var AExpT: string);   // 2017-02-28 �޸��˸ú�����bug
var
  i, len, tmpPos, signPos, signLen, replaceLen: integer;
  expT, tmpStr: string;
  f_SignP: Boolean;
begin
  // Ԥ�����Ų���    SignArr, SignValueArr
  if (Length(SignArr) = 0) or (Length(SignValueArr) = 0) then Exit;
  expT := AExpT;
  len := Length(expT);
  for i := 0 to High(SignArr) do
  begin
    signPos := Pos(SignArr[i], expT);
    while (signPos <> 0) do
    begin
      f_SignP := true;
      signLen := Length(SignArr[i]);       // ���ų���
      if (signPos - 1) > 0 then
        if (expT[signPos - 1] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then f_SignP := false;
      if (signPos + signLen) <= len then
        if (expT[signPos + signLen] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then f_SignP := false;
      if f_SignP then    // �Ǽ������ʱ
      begin
        delete(expT, signPos, signLen);
        Insert(floatToStr(SignValueArr[i]), expT, signPos);
        len := Length(expT);
        replaceLen := Length(floatToStr(SignValueArr[i]));       // ������ֵ���ַ�����
      end
      else replaceLen := signLen;
      tmpStr :=  RightStr(expT, len - signPos - replaceLen + 1);
      tmpPos := Pos(SignArr[i], tmpStr);
      if tmpPos <> 0 then signPos := signPos + tmpPos + replaceLen - 1
      else signPos := 0;
    end;   // while
  end;   //for
  AExpT := expT;
end;

function GetSignParam(Aindex: integer = 0): string;
var i: integer;
begin
  result := '';
  if Aindex < 0 then Exit;
  if (Aindex = 0) or (Aindex >= Length(SignArr)) then
  begin
    for i := 0 to High(SignArr) do
      result := result + SignArr[i] + '=' + FloatToStr(SignValueArr[i]) + ' , ';
  end
  else result := 'param' + IntToStr(Aindex) + ': ' + SignArr[Aindex] + '=' + FloatToStr(SignValueArr[Aindex]);
end;

function GetSignParam(const AParamName: string): string; overload;
var i: integer;
begin
  result := '';
  if AParamName = '' then Exit;
  for i := 0 to High(SignArr) do
    if SignArr[i] = AParamName then
    begin
      result := FloatToStr(SignValueArr[i]);
    end;
end;

function DelSignParam(const AParamName: string): Boolean;
var i, j: integer;
begin
  result := false;
  if AParamName = '' then Exit;
  for i := 0 to High(SignArr) do
    if SignArr[i] = AParamName then
    begin
      for j := (i + 1) to High(SignArr) do
      begin
        SignArr[j - 1] := SignArr[j];
        SignValueArr[j - 1] := SignValueArr[j];
      end;
      setLength(SignArr, Length(SignArr) - 1);
      setLength(SignValueArr, Length(SignValueArr) - 1);
      result := true;
      break;
    end;
end;

procedure InitSignParam();   // ��ʼ������
begin
  SetLength(SignArr, 0);
  SetLength(SignValueArr, 0);
  AddSignParam(['pi', 'PI', 'e', 'E'], [3.1415926535897932384, 3.1415926535897932384, 2.718281828459045, 2.718281828459045]);
end;

function CheckCalcFun(const ACalcFunList: TStringList): boolean;
var
  i, j, bkPos1, bkPos2: integer;
  fNStr: string;
  funCharError: Boolean;
begin
  if ACalcFunList.Count = 0 then
  begin
    Result := false;
    Exit;
  end;
  Result := true;
  for i := 0 to (ACalcFunList.Count - 1) do
  begin
    fNStr := Trim(ACalcFunList[i]);
    if Length(fNStr) = 0 then
    begin
      Result := false;
      Break;  // ��������ĸ����
    end;
    bkPos1 := Pos('(', fNStr);
    bkPos2 := Pos(')', fNStr);
    funCharError := false;
    if (not (fNStr[1] in ['a'..'z', 'A'..'Z', '_'])) then
    begin
      Result := false;
      Break;  // ��������ĸ����
    end;
    for j := 2 to (bkPos1 - 1) do
      if (not (fNStr[j] in ['a'..'z', 'A'..'Z', '_', '0'..'9'])) then
      begin
        funCharError := true;
        break;
      end;
    if (bkPos1 + 1) > (bkPos2 - 1) then funCharError := true;
    for j := (bkPos1 + 1) to (bkPos2 - 1) do
      if (not (fNStr[j] in ['0'..'9'])) then
      begin
        funCharError := true;
        break;
      end;
    if bkPos2 <> length(fNStr) then funCharError := true;   //  ) ���滹���ַ�
    if funCharError then
    begin
      Result := false;
      break;    // ������ĸ������Ҫ��
    end;
  end;
end;

function CheckFun(): boolean;
begin
  result := CheckCalcFun(sMathFun);
end;

function Pop(var aStack: RecStack; out values: string): boolean;
begin
  if aStack.top <> -1 then
  begin
    values := aStack.sv[aStack.top];
    aStack.sv.Delete(aStack.top);
    aStack.top := aStack.sv.Count - 1;
    result := true;
  end
  else result := false;   // ջΪ��
end;

function Push(var aStack: RecStack; const values: string): boolean;
begin
  result := false;
  aStack.sv.Add(values);
  aStack.top := aStack.sv.Count - 1;
  result := true;
end;

function GetTop(var aStack: RecStack): string;
begin
  if (aStack.top >= 0) and (aStack.top = (aStack.sv.Count - 1))  then result := aStack.sv[aStack.top]
  else result := '';
end;

function GetSyP(sy: char): integer;
begin
  case sy of
    '#': Result := 0;
    '(': Result := 1;
    ',': Result := 2;
    '+', '-': Result := 3;
    '*', '/': Result := 5;
    '~', '@': Result := 7;
    '!', '%', '^': Result := 9;
    ')': Result := 10;
  else
    Result := -1;
  end;
end;

function GetStackStr(const aStack: RecStack): string;
var
  i: integer;
  str: string;
begin
  str := '';
  for i := 0 to aStack.top do
    str := str + aStack.sv[i] + ',';
  Result := str;
end;

procedure SetError(var AError: boolean; var AErrorStr: string; const AStr: string);
begin
  AError := true;
  AErrorStr := AErrorStr + AStr + ';' ;
end;

function GetParamStr(const AParamStr: string; const AParamN: integer): string;
var
  i, commaCount, commaPos: integer;
  remainPamraStr: string;
begin              // ȥ�����������ĳ������
  Result := '';
  remainPamraStr := StringReplace(AParamStr, ' ', '', [rfReplaceAll]);
  if (AParamN <= 0) or (remainPamraStr = '') then Exit;
  i := 1;
  commaCount := 0;
  while (i < AParamN) do
  begin
    commaPos := pos(',', remainPamraStr);
    if (commaPos <> 0) then Inc(commaCount);
    remainPamraStr := RightStr(remainPamraStr, (Length(remainPamraStr) - commaPos));
    inc(I);
  end;
  if (commaCount = (AParamN - 1)) then
  begin
    commaPos := pos(',', remainPamraStr);
    if commaPos = 0 then Result := remainPamraStr
    else Result := LeftStr(remainPamraStr, commaPos - 1);
  end
  else Result := '';
end;

function IsCalcFun(const AFunName: string; const ACalcFunList: TStringList): boolean;
var
  i, bkPos: integer;
  fNStr: string;
begin
  Result := false;
  if ACalcFunList.Count = 0 then Exit;
  for i := 0 to (ACalcFunList.Count - 1) do
  begin
    fNStr := Trim(ACalcFunList[i]);
    bkPos := Pos('(', fNStr);
    if bkPos > 0 then
      if AFunName = leftStr(fNStr, bkPos - 1) then
      begin
        Result := true;
        break;
      end;
  end;
end;

function GetFunParamN(const AFunName: string; const ACalcFunList: TStringList):integer;
var
  i, bkPos1, bkPos2: integer;
  fNStr: string;
begin
  Result := -1;
  if ACalcFunList.Count = 0 then Exit;
  for i := 0 to (ACalcFunList.Count - 1) do
  begin
    fNStr := Trim(ACalcFunList[i]);
    bkPos1 := Pos('(', fNStr);
    bkPos2 := Pos(')', fNStr);
    if (bkPos1 > 0) and (bkPos2 > 0) and (bkPos2 > bkPos1) then
      if AFunName = leftStr(fNStr, bkPos1 - 1) then
      begin
        if not TryStrToInt(midStr(fNStr, (bkPos1 + 1), (bkPos2 - bkPos1 - 1)), Result) then
          Result := -1;
        break;
      end;
  end;
end;

function IncomeTaxCalc(const AValues: double): double;
var
  overPays: double;
begin    //  ��������˰���㺯��
  {
  ��2011��9��1�յ��������� ������ 3500Ԫ
  ȫ��Ӧ��˰�����1500Ԫ 3% 0
  ȫ��Ӧ��˰���1500Ԫ��4500Ԫ 10% 105
  ȫ��Ӧ��˰���4500Ԫ��9000Ԫ 20% 555
  ȫ��Ӧ��˰���9000Ԫ��35000Ԫ 25% 1005
  ȫ��Ӧ��˰���35000Ԫ��55000Ԫ 30% 2755
  ȫ��Ӧ��˰���55000Ԫ��80000Ԫ 35% 5505
  ȫ��Ӧ��˰���80000Ԫ 45% 13505
  }
  overPays := AValues - 3500;
  if overPays <= 0 then result := 0;
  if (overPays > 0   )  and (overPays <= 1500) then result := overPays * 0.03 - 0;
  if (overPays > 1500)  and (overPays <= 4500)  then result := overPays * 0.1  - 105;
  if (overPays > 4500)  and (overPays <= 9000)  then result := overPays * 0.2  - 555;
  if (overPays > 9000)  and (overPays <= 35000) then result := overPays * 0.25 - 1005;
  if (overPays > 35000) and (overPays <= 55000) then result := overPays * 0.3  - 2755;
  if (overPays > 55000) and (overPays <= 80000) then result := overPays * 0.35 - 5505;
  if (overPays > 80000) then                         result := overPays * 0.45 - 13505;
end;

function ArcIncomeTaxCalc(const AValues: double): double;
begin
  {
  0	    45
  45	  345
  345	  1245
  1245	7745
  7745	13745
  13745	22495
  22495 +��
  }
  if AValues <= 0 then
  begin
    result := 0;  // ������˰ʱ�޷����㹤��
    Exit;
  end;
  if (AValues > 0)     and (AValues <= 45)    then result := 3500 + (AValues + 0)     / 0.03;
  if (AValues > 45)    and (AValues <= 345)   then result := 3500 + (AValues + 105)   / 0.1;
  if (AValues > 345)   and (AValues <= 1245)  then result := 3500 + (AValues + 555)   / 0.2;
  if (AValues > 1245)  and (AValues <= 7745)  then result := 3500 + (AValues + 1005)  / 0.25;
  if (AValues > 7745)  and (AValues <= 13745) then result := 3500 + (AValues + 2755)  / 0.3;
  if (AValues > 13745) and (AValues <= 22495) then result := 3500 + (AValues + 5505)  / 0.35;
  if (AValues > 22495)                        then result := 3500 + (AValues + 13505) / 0.45;
end;

function GetFunParamValuse(const AParamStr: string; var A_Valuse_arr: array of double): Boolean;
var
  i: integer;
  tmpStr: string;
begin
  i := 1;
  tmpStr := '';
  try
    tmpStr := GetParamStr(AParamStr, i);
    while ((tmpStr <> '') and (i <= (High(A_Valuse_arr) + 1))) do
    begin
      A_Valuse_arr[i - 1] := StrToFloat(tmpStr);
      Inc(i);
      tmpStr := GetParamStr(AParamStr, i);
    end;
    result := true;
  except
    result := false;
  end;
end;

function My_MorRep(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var                                //morrep(480000,0.049,30,0,1)
  i, arrLen: integer;
  vRes: double;
  vn: array of double;
BEGIN
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if ((arrLen = 5) and (vn[0] > 0) and (vn[1] > 0) and (vn[2] > 0) and (frac(vn[2]) = 0) and (vn[4] > 0) and (vn[4] <= vn[2] * 12) and (frac(vn[4]) = 0)) then
  begin
    if vn[3] = 1 then     // �ȶ�𻹿ʽ
    begin
      vRes := vn[0] / (vn[2] * 12) + vn[0] * (1 - (vn[4] - 1) /(vn[2] * 12)) * vn[1] / 12;
    end
    else begin          // ����Ĭ�ϰ��ȶϢ���ʽ
      vRes := vn[0] * (vn[1] / 12) * power(1 + (vn[1] / 12), vn[2] * 12) / (power(1 + (vn[1] / 12), vn[2] * 12) - 1);
    end;
    ARes := vRes;
    result := true;
  end
  else begin
    SetError(AError, AErrorStr, '���һ��������������');
    Exit;
  end;
end;

function My_max(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var
  i, arrLen: integer;
  vRes: double;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  vRes := vn[0];
  for i := 1 to (Length(vn) - 1) do
    vRes := max(vRes, vn[i]);
  ARes := vRes;
  result := true;
end;

function My_min(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var
  i, arrLen: integer;
  vRes: double;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  vRes := vn[0];
  for i := 1 to (Length(vn) - 1) do
    vRes := min(vRes, vn[i]);
  ARes := vRes;
  result := true;
end;

function My_sum(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var
  i, arrLen: integer;
  vRes: double;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  vRes := vn[0];
  for i := 1 to (Length(vn) - 1) do
    vRes := vRes + vn[i];
  ARes := vRes;
  result := true;
end;

function My_avg(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var
  i, arrLen: integer;
  vRes: double;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  vRes := vn[0];
  for i := 1 to (Length(vn) - 1) do
    vRes := vRes + vn[i];
  vRes := vRes / Length(vn);
  ARes := vRes;
  result := true;
end;

function My_stdDev(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var
  i, arrLen: integer;
  vRes, avgV: double;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  avgV := 0;
  for i := 0 to (Length(vn) - 1) do
    avgV := avgV + vn[i];
  avgV := avgV / Length(vn);
  vRes := 0;
  for i := 0 to (Length(vn) - 1) do
    vRes := vRes + power((vn[i] - avgV), 2);
  vRes := sqrt(vRes / (Length(vn) - 1));
  result := true;
end;

function My_cosTh(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var
  i, arrLen: integer;
  vRes: double;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if ((arrLen = 3) and (vn[0] + vn[1] > vn[2]) and
      (vn[1] + vn[2] > vn[0]) and (vn[0] + vn[2] > vn[1]) and (vn[0] > 0) and (vn[1] > 0) and (vn[2] > 0)) then
  begin
    vRes := (power(vn[0], 2) + power(vn[1], 2) - power(vn[2], 2)) / (2 * vn[0] * vn[1]);
    if (vRes >= 1) or (vRes <= -1) then SetError(AError, AErrorStr, '���߲��ܹ���һ��������!')
    else begin
      ARes := vRes;
      result := true;
    end;
  end
  else begin
    SetError(AError, AErrorStr, '���߲��ܹ���һ�������� !');
    Exit;
  end;
end;

function My_AreaTriangle(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var                   // ���������
  i, arrLen: integer;
  vRes, tmpV: double;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if ((arrLen = 3) and (vn[0] + vn[1] > vn[2]) and
      (vn[1] + vn[2] > vn[0]) and (vn[0] + vn[2] > vn[1]) and (vn[0] > 0) and (vn[1] > 0) and (vn[2] > 0)) then
  begin
    tmpV := 0.5 * (vn[0] + vn[1] + vn[2]);
    vRes := sqrt(tmpV * (tmpV - vn[0]) * (tmpV - vn[1])* (tmpV - vn[2]));
    ARes := vRes;
    result := true;
  end
  else begin
    SetError(AError, AErrorStr, '���߲��ܹ���һ�������� !');
    Exit;
  end;
end;

function My_PlanesPointDis(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var                   // ƽ������ľ���  v0,v1,v2,v3 (x1,y1) (x2,y2)
  i, arrLen: integer;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if (arrLen = 4) then
  begin
    ARes := sqrt(power(vn[0] - vn[2], 2) + power(vn[1] - vn[3], 2));
    result := true;
  end
  else begin
    SetError(AError, AErrorStr, 'ƽ�������������� !');
    Exit;
  end;
end;

function My_SpacePointDis(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var                   // �ռ�����ľ���   v0,v1,v2,v3,v4,v5, (x1,y1,z1) (x2,y2,z2)
  i, arrLen: integer;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if (arrLen = 6) then
  begin
    ARes := sqrt(power(vn[0] - vn[3], 2) + power(vn[1] - vn[4], 2) + power(vn[2] - vn[5], 2));
    result := true;
  end
  else begin
    SetError(AError, AErrorStr, '�ռ������������� !');
    Exit;
  end;
end;

function My_PointToLineDis(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var                   // ƽ��㵽ֱ�ߵľ���  v0,v1, v2,v3,v4 (x1,y1) (a,b,c)   ax + by + c =0
  i, arrLen: integer;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if (arrLen = 5) then
  begin
    ARes := abs(vn[0] * vn[2] + vn[1] * vn[3] + vn[4]) / sqrt(power(vn[2], 2) + power(vn[3], 2));
    result := true;
  end
  else begin
    SetError(AError, AErrorStr, '������������ !');
    Exit;
  end;
end;

function My_PointToPlanesDis(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var                   // �ռ�㵽��ľ���   v0,v1,v2,  v3,v4,v5,v6 (x1,y1,z1) (A,B,C,D)  Ax + By+ Cz + D =0
  i, arrLen: integer;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if (arrLen = 7) then
  begin
    ARes := abs(vn[0] * vn[3] + vn[1] * vn[4] + vn[2] * vn[5] + vn[6]) / sqrt(power(vn[3], 2) + power(vn[3], 2) + power(vn[5], 2));
    result := true;
  end
  else begin
    SetError(AError, AErrorStr, '������������ !');
    Exit;
  end;
end;

function My_SumRatioSeri(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var                   // �ȱ�����ǰ n ����͹�ʽ v0,v1,v2 ��Ӧ a1��q, n
  i, arrLen: integer;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if (arrLen = 3) and (vn[1] <> 1) and (vn[2] > 0) and (frac(vn[2]) = 0) then
  begin
    ARes := vn[0] * (1 - power(vn[1], vn[2])) /(1 - vn[1]);
    result := true;
  end
  else begin
    SetError(AError, AErrorStr, '�ȱ����в����������󣬹��Ȳ���Ϊ1 !');
    Exit;
  end;
end;

function My_SumSubSeri(const AParam: string; out ARes: double; var AError: boolean; var AErrorStr: string): boolean;
var                   // �Ȳ�����ǰ n ����͹�ʽ  v0,v1,v2 ��Ӧ a1��d, n
  i, arrLen: integer;
  vRes, tmpV: double;
  vn: array of double;
begin
  result := false;
  arrLen := 1;
  for i := 1 to Length(AParam) do
    if AParam[i] = ',' then Inc(arrLen);
  SetLength(vn, arrLen);
  GetFunParamValuse(AParam, vn);
  if (arrLen = 3) and (vn[2] > 0) and (frac(vn[2]) = 0) then
  begin
    ARes := vn[2] * vn[0] + vn[2] * (vn[2] - 1) * vn[1] / 2;
    result := true;
  end
  else begin
    SetError(AError, AErrorStr, '�ȱ����в����������󣬹��Ȳ���Ϊ1 !');
    Exit;
  end;
end;

//*****************************************************************************
//*****************************************************************************

function CalcExp(const aExpT: string; out calResult: double; out AInfo: string): boolean;
var
  i, j, k, len, temp, funIndex, commaPos, arrLen, signP: integer;
  av, sy, calcV: RecStack;
  expT, elemStr, str1, str2, valuesStr, funNameStr, topSStr, funParamStr, tmpStr: string;
  v1, v2, tmpV: Extended;
  vRes: double;
  vn: array of double;
  caclError, ConstE, constPI: boolean;
begin
  result := false;
  caclError := false;
  expT := StringReplace(aExpT, ' ', '', [rfReplaceAll]);     // ȥ�ո�
  len := Length(expT);
  if len = 0 then   Exit;                         // ���ʽΪ��ʱ�˳�����
  ReplaceSignParam(expT);                         // �滻���ʽ�еķ��Ų���(SignArr)
  if not CheckCalcExp(expT, AInfo) then   Exit;   // �����ʽ��ʽ�Ƿ���ȷ, ����ȷʱ�˳�����
  len := Length(expT);                            // �滻���ź��ַ������ȱ仯������ȡ���ȡ�
  for i := len downto 1 do                        // �滻�����ţ�  ���� + �� @��  ���� - �� ~
  begin
    if (expT[i] = '-') and (i > 1) then
      if (expT[i - 1] in ['+', '-', '*', '/', '^', '(', ',']) then expT[i] := '~';
    if (expT[i] = '-') and (i = 1) then  expT[i] := '~';
    if (expT[i] = '+') and (i > 1) then
      if (expT[i - 1] in ['+', '-', '*', '/', '^', '(', ',']) then expT[i] := '@';
    if (expT[i] = '+') and (i = 1) then  expT[i] := '@';
  end;
  expT := StringReplace(ExpT, '@', '', [rfReplaceAll]);    // ȥ����
  expT := expT + '#';                                      // ��ӽ�����־ # �����ȼ����
  len := Length(expT);
  // ��������ջ���沨�����ʽջ,����ֵ�洢ջ
  av.sv := TStringList.Create;      //  �沨��ջ
  sy.sv := TStringList.Create;      //  ����ջ
  calcV.sv := TStringList.Create;   //  ����ֵ�洢ջ
  try
    av.sv.Sorted := false;
    sy.sv.Sorted := false;
    calcV.sv.Sorted := false;
    calcV.top := -1;
    av.top := -1;
    sy.top := -1;
    Push(sy, '#');
    valuesStr := '';
    funNameStr := '';
    for i := 1 to len do
    begin
      elemStr := expT[i];
      if (valuesStr <> '') and (not (expT[i] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'])) then
      begin       // һ����ֵɨ�����
        Push(av, valuesStr);
        while ((GetTop(sy) = '~') or (GetTop(sy) = '@')) do
          if Pop(sy, str1)then
            Push(av, str1);
        valuesStr := '';
      end;
      if (funNameStr <> '') and (not (expT[i] in ['a'..'z', 'A'..'Z', '0'..'9', '_'])) then
      begin      // һ��������ɨ�����
        Push(sy, funNameStr);
        funNameStr := '';
      end;
      case expT[i] of
        '#':
          begin
            while (GetTop(sy) <> '#') and (GetTop(sy) <> '') do
              if Pop(sy, str1)then     // ����ջ��ջ�ɹ�
                Push(av, str1);        // �ٴ����沨�����ʽջ
            Break;                     // ���������� for ѭ��
          end;
        '~', '@': Push(sy, elemStr);   // ������Ŀ�����
        '!', '%': Push(av, elemStr);   // �׳��ҵ�Ŀ����
        '(': Push(sy, elemStr);
        ')':
          begin
            while ((GetTop(sy) <> '(') and (GetTop(sy) <> '#') and (GetTop(sy) <> ''))  do
              if Pop(sy, str1)then     // ����ջ��ջ�ɹ�
                Push(av, str1);        // �ٴ����沨�����ʽջ
            Pop(sy, str1);             // ')' ��ջ
            topSStr := GetTop(sy);
            while ((topSStr = '~') or (topSStr = '@') or (topSStr[1] in ['a'..'z', 'A'..'Z', '_'])) do
            begin
              if Pop(sy, str1)then
                Push(av, str1);
              topSStr := GetTop(sy);
            end;
          end;
        '+', '-', '*', '/', '^':
          begin
            str1 := GetTop(sy);
            while (GetSyP(expT[i]) <= GetSyP(str1[1])) and (str1 <> '') do   // �Ƚ����ȼ�
              if Pop(sy, str1)then
              begin
                Push(av, str1);
                str1 := GetTop(sy);
              end
              else break;
            Push(sy, elemStr);
          end;
        '.': valuesStr := valuesStr + elemStr;
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9':
          begin
            if funNameStr = '' then valuesStr := valuesStr + elemStr
            else funNameStr := funNameStr + elemStr;
          end;
        'a'..'z', 'A'..'Z', '_': funNameStr := funNameStr + elemStr;
        ',':         //���Ŵ���
          begin
            while ( (GetTop(sy) <> '(') and (GetTop(sy) <> ',')
              and (GetTop(sy) <> '#')  and (GetTop(sy) <> '') )do
              if Pop(sy, str1)then Push(av, str1)// ����ջ��ջ�ɹ�,�ٴ����沨�����ʽջ
              else break;        //
            Push(sy, elemStr);
          end;
      end;   // case
    end;  // for
    //showMessage('���ɵ��沨��ʽ:' + GetStackStr(av));
    // �����沨��ʽ
    try
      i := 0;
      while (not caclError) and (i <= av.top) do
      begin
        valuesStr := av.sv[i];
        case valuesStr[1] of
          '~':
            if Pop(calcV, str1) then
              Push(calcV, floatToStr(-1 * StrToFloat(str1)));
          '@': ;
          '!':
            begin
              if Pop(calcV, str1) then
              begin
                v1 := StrToFloat(str1);
                if (Frac(v1) = 0) and (v1 <= 150) and (v1 >= 1)then // Ϊ������С��150ʱ
                begin
                  temp := Trunc(v1);
                  vRes := 1;
                  while (temp >= 1) do    // ��׳�
                  begin
                    vRes := vRes * temp;
                    Dec(temp);
                  end;
                  Push(calcV, floatToStr(vRes));
                end
                else SetError(caclError, AInfo, '�׳˼���ֻ��Ϊ��������Χ1��150!');
              end;
            end;
          '%':
            if Pop(calcV, str1) then
            begin
              vRes := StrToFloat(str1) * 0.01;
              Push(calcV, FloatToStr(vRes));
            end;
          '+', '-', '*', '/', '^':
            begin
              if Pop(calcV, str1) and Pop(calcV, str2) then
              begin
                v1 := StrToFloat(str1);
                v2 := StrToFloat(str2);
                vRes := 0;
                case valuesStr[1] of
                  '+': vRes := v2 + v1;
                  '-': vRes := v2 - v1;
                  '*': vRes := v2 * v1;
                  '/':
                    begin
                      if v1 <> 0 then vRes := v2 / v1     // ��������Ϊ��
                      else  SetError(caclError, AInfo, '��������Ϊ��!');
                    end;
                  '^': vRes := Power(v2, v1);
                end;
                Push(calcV,  FloatToStr(vRes));
              end;   // if
            end;
          '0'..'9', '.': Push(calcV, valuesStr);  // ����ʱ
          ',':
            if Pop(calcV, str1) and Pop(calcV, str2) then
              Push(calcV, str2 + ',' + str1);             //  ����˳����
          'a'..'z', 'A'..'Z', '_':      // ����ʱ
          begin
            if IsCalcFun(valuesStr, sMathFun) and Pop(calcV, str1) then
            begin
              funParamStr := GetParamStr(str1, 1);
              if funParamStr <> '' then v1 := StrToFloat(funParamStr)
              else SetError(caclError, AInfo, '������������!');
              //******************************************************
              // ���ݲ�ͬ����������Ӧ����
              vRes := 0;
              for k := 1 to 1 do
              begin
                valuesStr := LowerCase(valuesStr);
                if valuesStr = 'abs'      then  begin vRes := abs(v1);        break; end;
                if valuesStr = 'sin'      then  begin vRes := sin(v1);        break; end;
                if valuesStr = 'cos'      then  begin vRes := cos(v1);        break; end;
                if valuesStr = 'tan'      then  begin vRes := tan(v1);        break; end;
                if valuesStr = 'arctan'   then  begin vRes := arctan(v1);     break; end;
                if valuesStr = 'degrad'   then  begin vRes := v1 * 3.14159265358979 / 180;     break; end;
                if valuesStr = 'raddeg'   then  begin vRes := v1 * 180 / 3.14159265358979;     break; end;
                if valuesStr = 'int'      then  begin vRes := int(v1);        break; end;
                if valuesStr = 'trunc'    then  begin vRes := trunc(v1);      break; end;
                if valuesStr = 'round'    then  begin vRes := round(v1);      break; end;
                if valuesStr = 'frac'     then  begin vRes := frac(v1);       break; end;
                if valuesStr = 'exp'      then  begin vRes := exp(v1);        break; end;
                if valuesStr = 'intax'    then  begin vRes := IncomeTaxCalc(v1);  break; end; // intax ��˰���㺯��
                if valuesStr = 'power'    then
                begin
                  funParamStr := '';
                  funParamStr := GetParamStr(str1, 2);
                  if funParamStr <> '' then v2 := StrToFloat(funParamStr)
                  else SetError(caclError, AInfo, '������������!');
                  vRes := power(v1, v2);
                  break;
                end;
                if valuesStr = 'sqrt' then
                begin
                  if v1 >= 0 then vRes := sqrt(v1)
                  else SetError(caclError, AInfo, '�����ڱ���Ϊ����!');
                  break;
                end;
                if valuesStr = 'arcsin' then
                begin
                  if (v1 >= -1) and (v1 <= 1) then vRes := arcsin(v1)
                  else SetError(caclError, AInfo, '�����Һ���ֵ������-1��1֮��!');
                  break;
                end;
                if valuesStr = 'arccos' then
                begin
                  if (v1 <= 1) and (v1 >= -1) then vRes := arccos(v1)
                  else SetError(caclError, AInfo, '�����Һ���ֵ������-1��1֮��!');
                  break;
                end;
                
                if valuesStr = 'log2' then
                begin
                  if v1 > 0 then vRes := log2(v1)
                  else SetError(caclError, AInfo, '��������ֵ�������0!');
                  break;
                end;
                if valuesStr = 'log10' then
                begin
                  if v1 > 0 then vRes := log10(v1)
                  else SetError(caclError, AInfo, '��������ֵ�������0!');
                  break;
                end;
                if valuesStr = 'ln' then
                begin
                  if v1 > 0 then vRes := ln(v1)
                  else SetError(caclError, AInfo, '��������ֵ�������0!');
                  break;
                end;
                if valuesStr = 'logn' then
                begin
                  funParamStr := '';
                  funParamStr := GetParamStr(str1, 2);
                  if funParamStr <> '' then v2 := StrToFloat(funParamStr)
                  else SetError(caclError, AInfo, '��������ֵ����!');
                  if (v1 > 0) and (v2 > 0) and (v2 <> 1) then vRes := logN(v1, v2) // ����������ֵʱ�Ѿ�����˳����
                  else  SetError(caclError, AInfo, '��������ֵ������������0���ҵ������ܵ���1!');
                  break;
                end;
                if valuesStr = 'roundto' then
                begin
                  funParamStr := '';
                  funParamStr := GetParamStr(str1, 2);
                  if funParamStr <> '' then v2 := StrToFloat(funParamStr)
                  else SetError(caclError, AInfo, '����Լλ������!');
                  if (Frac(v2) = 0) and (v2 < 15) and (v2 > -15) then
                  begin
                    temp := Round(v2);
                    vRes := roundTo(v1, temp);
                  end
                  else SetError(caclError, AInfo, '����Լλ������!');
                  Break;
                end;
                if valuesStr = 'mod' then
                begin
                  funParamStr := '';
                  funParamStr := GetParamStr(str1, 2);
                  if funParamStr <> '' then v2 := StrToFloat(funParamStr)
                  else SetError(caclError, AInfo, '������������!');
                  if (Frac(v2) = 0) and (Frac(v1) = 0) and (v2 > 0) then
                  begin
                    vRes := Trunc(v1) mod Trunc(v2);
                  end
                  else SetError(caclError, AInfo, '�������Ϊ������!');
                  Break;
                end;
                if valuesStr = 'arcintax' then
                begin
                  if v1 > 0 then vRes := ArcIncomeTaxCalc(v1)
                  else SetError(caclError, AInfo, 'δ����������˰ʱ�޷����㹤�ʣ�');
                  Break;
                end;
                // ��������
                if valuesStr = 'max'      then  begin My_max(str1, vRes, caclError, AInfo);    break; end;
                if valuesStr = 'min'      then  begin My_min(str1, vRes, caclError, AInfo);    break; end;
                if valuesStr = 'sum'      then  begin My_sum(str1, vRes, caclError, AInfo);    break; end;
                if valuesStr = 'avg'      then  begin My_avg(str1, vRes, caclError, AInfo);    break; end;
                if valuesStr = 'stddev'   then  begin My_stdDev(str1, vRes, caclError, AInfo); break; end; // ͳ��ʵ���׼ƫ��
                if valuesStr = 'costh'    then  begin My_costh(str1, vRes, caclError, AInfo);  break; end;
                if valuesStr = 'sn'       then  begin My_SumSubSeri(str1, vRes, caclError, AInfo); break; end;
                if valuesStr = 'sqn'       then  begin My_SumRatioSeri(str1, vRes, caclError, AInfo); break; end;
                if valuesStr = 's_tria'   then  begin My_AreaTriangle(str1, vRes, caclError, AInfo);    break; end;
                if valuesStr = 'pdisplanes'   then  begin My_PlanesPointDis(str1, vRes, caclError, AInfo);   break; end;
                if valuesStr = 'pdisspace'    then  begin My_SpacePointDis(str1, vRes, caclError, AInfo);    break; end;
                if valuesStr = 'p_line'       then  begin My_PointToLineDis(str1, vRes, caclError, AInfo);   break; end;
                if valuesStr = 'p_planes'     then  begin My_PointToPlanesDis(str1, vRes, caclError, AInfo); break; end;
                if valuesStr = 'morrep'       then  begin My_MorRep(str1, vRes, caclError, AInfo); break; end;
                if valuesStr = 's_circ'   then
                begin
                  if v1 > 0 then vRes := PI * Power(v1, 2)
                  else SetError(caclError, AInfo, 'Բ�뾶����Ϊ������');
                  break;
                end;
                if valuesStr = 's_ellip' then
                begin
                  funParamStr := '';
                  funParamStr := GetParamStr(str1, 2);
                  if funParamStr <> '' then v2 := StrToFloat(funParamStr)
                  else SetError(caclError, AInfo, '��Բ��������');
                  if (v1 > 0) and (v2 > 0) then  vRes := PI * v1 * v2
                  else SetError(caclError, AInfo, '��Բ���̰���ֵ����Ϊ������');
                  break;
                end;
                if valuesStr = 's_rect' then
                begin
                  funParamStr := '';
                  funParamStr := GetParamStr(str1, 2);
                  if funParamStr <> '' then v2 := StrToFloat(funParamStr)
                  else SetError(caclError, AInfo, '���γ�������');
                  if (v1 > 0) and (v2 > 0) then  vRes := v1 * v2
                  else SetError(caclError, AInfo, '���γ������Ϊ������');
                  break;
                end;
                if valuesStr = 's_poly' then
                begin
                  funParamStr := '';
                  funParamStr := GetParamStr(str1, 2);
                  if funParamStr <> '' then v2 := StrToFloat(funParamStr)
                  else SetError(caclError, AInfo, '������β�������');
                  if (v1 > 0) and (v2 >= 3) and (frac(v2) = 0) then
                    vRes := (v2 / 4) * power(v1, 2) *(1 / tan(PI / v2))
                  else SetError(caclError, AInfo, '������β�������');
                  break;
                end;
              end; // for  k := 1 to 1 do
              //*****************************************************************
              if not caclError then  Push(calcV,  FloatToStr(vRes));
            end  // if
            else SetError(caclError, AInfo, '�޷�ʶ��ĺ�����');
          end;
        else
          SetError(caclError, AInfo, '���ʽ����Ч�ַ�');
        end;   // case
        Inc(i);
        if caclError then break;
      end;      // while
      if  not caclError then
      begin
        calResult := StrToFloat(calcV.sv[calcV.top]);
        result := true;
      end;
    except
      caclError := true;
      result := false;
    end;
  finally
    av.sv.Free;
    sy.sv.Free;
    calcV.sv.Free;
  end;
end;

function CheckCalcExp(const ExpT: string; out AInfo: string): boolean;
var           // ֧�� + - * / %  +- ^ ()
  i, j, funS, funE,
  lenExpT, pairBktN, dotPos, commaN, fPN_given: integer;    // Bkt: brackets ����
  expError: boolean;
  aExpT, str1, lStr, mStr, rStr: string;
begin
  result := false;
  expError := false;                                             // Ĭ�ϱ��ʽ��ȷ
  aExpT := StringReplace(ExpT, ' ', '', [rfReplaceAll]);         // ȥ�ո�
  aExpT := StringReplace(aExpT, '%', '/(100)', [rfReplaceAll]);  // �滻�ٷ������� %
  aExpT := StringReplace(aExpT, '^', '*', [rfReplaceAll]);       // �滻���ݷ��� ^
  aExpT := StringReplace(aExpT, '!', '*(1*1)', [rfReplaceAll]);  // �滻�׳˷��� !
  lenExpT := Length(aExpT);
  if lenExpT = 0 then Exit;     // ���ʽ����ȷʱ�˳�����
  //******************************************************************
  // ���ұ��ʽ�Ƿ���ָ����ϵͳ������ ���ҵ����� (1)* ������ټ����ʽ����ȷ��
  // ���������붺�ŵļ��
  // ����һ�����֮����ѧ���� e ���� PI ������Ԥ������ֵ���棬������ܻ��뺯������ͻ
  if not expError then
  begin
    funS := 0;
    funE := 0;
    i := 1;
    while i <= lenExpT do
    begin
      if (funS = 0) and (aExpT[i] in ['a'..'z', 'A'..'Z', '_']) then funS := i;
      if (funS <> 0) and (aExpT[i] = '(') then
      begin
        funE := i ;
        for j := funS to funE - 1 do
          if not (aExpT[j] in ['a'..'z', 'A'..'Z', '_', '0'..'9']) then
          begin
            SetError(expError, AInfo, '����������');
            break;
          end;
        str1 := midStr(aExpT, funS, funE - funS);
        if IsCalcFun(str1, sMathFun) then
        begin      // ������ƥ��ʱ
          // �ټ�麯�����������Ƿ���ȷ
          pairBktN := 0;
          commaN := 0;
          for j := funE to lenExpT do
          begin
            if aExpT[j] = '(' then  Inc(pairBktN);  // ��ƥ����������1
            if aExpT[j] = ')' then  Dec(pairBktN);  // ��ȥ�Ѿ�ƥ���һ������
            if (aExpT[j] = ',') and (pairBktN = 1) then
            begin
              Inc(commaN);
              aExpT[j] := '*';   // �������Ķ������滻Ԥ����
            end;
            if pairBktN = 0 then break;
          end;
          fPN_given := GetFunParamN(str1, sMathFun);
          if (pairBktN = 0) and (((commaN + 1) = fPN_given) or (fPN_given = 0))then
          begin
            if (funS - 1) > 0 then lStr := LeftStr(aExpT,  funS - 1)
            else lStr := '';
            if funE <= lenExpT then rStr := RightStr(aExpT, lenExpT - funE + 1)
            else rStr := '';
            aExpT := lStr + '(1)*' + rStr;
            lenExpT := Length(aExpT);
            i := funS;
          end
          else SetError(expError, AInfo, '������������������');
        end
        else SetError(expError, AInfo, '�޷�ʶ��ĺ�������');
        funS := 0;
        funE := 0;
      end;  // if
      if expError then break;
      Inc(i);
    end;   // while
  end;  // if
  //******************************************************************
  // �����ʽ�ַ��Ƿ���ȷ���ַ���Χ��0~9  + - * / . ( )
  if not expError then
    for i := 1 to lenExpT do
      if not (aExpT[i] in (symbolSets + numberSets + ['(', ')', '.'])) then
      begin
        SetError(expError, AInfo, '���ʽ������Ч�ַ�');
        break;
      end;
  //******************************************************************
  // �����ʽ��'('��')'�Ƿ���ȷ
  if not expError then
  begin
    pairBktN := 0;
    for i := 1 to lenExpT do
    begin
      // ��� '('��')'�Ƿ�ɶԳ���
      if aExpT[i] = '(' then  Inc(pairBktN);  // ��ƥ����������1
      if aExpT[i] = ')' then  Dec(pairBktN);  // ��ȥ�Ѿ�ƥ���һ������
      if pairBktN < 0 then
      begin
        SetError(expError, AInfo, '���ʽ����������');
        break;
      end;
      // ��� '('��')' ǰ���ַ��Ƿ���ȷ
      // '(' ֮ǰ + - * / ( ��Ч�� '(' ֮�� + - ( 0~9 ��Ч
      // ')' ֮ǰ 0~9 ) ��Ч�� ')' ֮�� + - * / ) ��Ч
      if aExpT[i] = '(' then
      begin
        if (i - 1) >= 1 then
          if not (aExpT[i - 1] in (symbolSets + ['('])) then SetError(expError, AInfo, '���ʽ������ǰ������');
        if (i + 1) <= lenExpT then
          if not (aExpT[i + 1] in (numberSets + ['(', '+', '-'])) then SetError(expError, AInfo, '���ʽ������ǰ������');
      end;
      if aExpT[i] = ')' then
      begin
        if (i - 1) >= 1 then
          if not (aExpT[i - 1] in (numberSets + [')'])) then SetError(expError, AInfo, '���ʽ������ǰ������');
        if (i + 1) <= lenExpT then
          if not (aExpT[i + 1] in (symbolSets + [')'])) then SetError(expError, AInfo, '���ʽ������ǰ������');
      end;
      if expError then Break;
    end;  // for
    if pairBktN <> 0 then SetError(expError, AInfo, '���ʽ�������������');
  end;   // if
  //******************************************************************
  // �����ʽ�� + - * / �Ƿ���ȷ
  if not expError then
    for i := 1 to lenExpT  do
    begin
      // �����������,��ͷ��λ���ܳ��� * / ����β���ܳ��� + - * /
      if (aExpT[i] in ['*', '/']) and (i = 1) then  SetError(expError, AInfo, '���ʽ�����ַ�����');
      if (aExpT[i] in symbolSets) and (i = lenExpT) then  SetError(expError, AInfo, '���ʽ��β�ַ�����');
      // �����������ǰ���ܵķ���
      // + - ����֮ǰ . ��Ч��֮�� * /  ) . ��Ч
      // * / ����֮ǰ + - * / . ( ��Ч��֮�� * / ) . ��Ч
      if (aExpT[i] in ['+', '-']) and ((i - 1) >= 1) and ((i + 1) <= lenExpT) then
        if (aExpT[i - 1] in ['.']) or (aExpT[i + 1] in ['*', '/', ')', '.']) then
          SetError(expError, AInfo, '���ʽ�������ǰ������');
      if (aExpT[i] in ['*', '/']) and ((i - 1) >= 1) and ((i + 1) <= lenExpT) then
        if (aExpT[i - 1] in (symbolSets + ['.','('])) or (aExpT[i + 1] in ['*', '/', ')', '.']) then
          SetError(expError, AInfo, '���ʽ�������ǰ������');
      if expError then Break;
    end;  // for
  //******************************************************************
  // �����ʽ�� . �Ƿ���ȷ
  if not expError then
  begin
    dotPos := 0;
    for i := 1 to lenExpT do
    begin
      // ���С�����Ƿ�����ڿ�ͷ���β
      if ((i = 1) or (i = lenExpT)) and (aExpT[i] = '.') then  SetError(expError, AInfo, '���ʽ��С�����������β��');
      // �������С����֮���Ƿ�Ϊ�������ַ�
      if aExpT[i] = '.' then
      begin
        if dotPos > 0 then
        begin
          if (i - dotPos) = 1 then SetError(expError, AInfo, '���ʽ��С������������');     // . ����ʱ
          for j := (dotPos + 1) to (i - 1) do
            if not (aExpT[j] in numberSets) then  break  // ����Сѭ��
            else if j = (i - 1) then  SetError(expError, AInfo, '���ʽ��С��������');
        end;
        dotPos := i;
      end;
      if expError then Break;   // ������ѭ��
    end;   // for
  end;  // if
  //******************************************************************
  if not expError then  result := true;
end;

procedure Init();
begin
  symbolSets := ['+', '-', '*', '/'];  // ��������ַ�
  numberSets := ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];  // ���ַ���
  sMathFun := TStringList.Create;
  sMathFun.CommaText := 'sqrt(1),abs(1),exp(1),power(2),' +
                        'sin(1),cos(1),tan(1),arcsin(1),arccos(1),arctan(1),degrad(1),raddeg(1),costh(3),' +
                        's_tria(3),s_circ(1),s_ellip(2),s_rect(2),s_poly(2),' +
                        'log2(1),log10(1),logN(2),ln(1),' +
                        'int(1),trunc(1),round(1),roundto(2),frac(1),mod(2),' +
                        'max(0),min(0),sum(0),avg(0),stddev(0),' +
                        'sn(3), sqn(3),' +
                        'intax(1),arcintax(1),morrep(5),' +
                        'pdisplanes(4), pdisspace(6), p_line(5), p_planes(7)';
  InitSignParam();
end;

procedure FreeRes();
begin
  sMathFun.Free;
end;

initialization
  Init();
finalization
  FreeRes();
end.
{
    // 2017-02-28 �޸���ReplaceSignParam������bug
}

