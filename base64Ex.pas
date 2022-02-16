unit Base64Ex;

interface


const
    cBase64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    cBase64Ex = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/=';


    function Base64Encode(mSource: string; mAddLine: Boolean = True): string;
    function Base64Decode(mCode: string): string;

    function Base64EncodeEx(mSource: string; mAddLine: Boolean = True): string;
    function Base64DecodeEx(mCode: string): string;


implementation


function Base64Encode(mSource: string; mAddLine: Boolean = True): string;
var
  I, J: Integer;
  S: string;
begin
  Result := '';
  J := 0;
  for I := 0 to Length(mSource) div 3 - 1 do begin
    S := Copy(mSource, I * 3 + 1, 3);
    Result := Result + cBase64[Ord(S[1]) shr 2 + 1];
    Result := Result + cBase64[((Ord(S[1]) and $03) shl 4) + (Ord(S[2]) shr 4) + 1];
    Result := Result + cBase64[((Ord(S[2]) and $0F) shl 2) + (Ord(S[3]) shr 6) + 1];
    Result := Result + cBase64[Ord(S[3]) and $3F + 1];
    if mAddLine then begin
      Inc(J, 4);
      if J >= 76 then begin
        Result := Result + #13#10;
        J := 0;
      end;
    end;
  end;
  I := Length(mSource) div 3;
  S := Copy(mSource, I * 3 + 1, 3);
  case Length(S) of
    1: begin
        Result := Result + cBase64[Ord(S[1]) shr 2 + 1];
        Result := Result + cBase64[(Ord(S[1]) and $03) shl 4 + 1];
        Result := Result + cBase64[65];
        Result := Result + cBase64[65];
      end;
    2: begin
        Result := Result + cBase64[Ord(S[1]) shr 2 + 1];
        Result := Result + cBase64[((Ord(S[1]) and $03) shl 4) + (Ord(S[2]) shr 4) + 1];
        Result := Result + cBase64[(Ord(S[2]) and $0F) shl 2 + 1];
        Result := Result + cBase64[65];
      end;
  end;
end; { Base64Encode }

function Base64Decode(mCode: string): string;
var
  I, L: Integer;
  S: string;
begin
  Result := '';
  L := Length(mCode);
  I := 1;
  while I <= L do begin
    if Pos(mCode[I], cBase64) > 0 then begin
      S := Copy(mCode, I, 4);
      if (Length(S) = 4) then begin
        Result := Result + Chr((Pos(S[1], cBase64) - 1) shl 2 +
          (Pos(S[2], cBase64) - 1) shr 4);
        if S[3] <> cBase64[65] then begin
          Result := Result + Chr(((Pos(S[2], cBase64) - 1) and $0F) shl 4 +
            (Pos(S[3], cBase64) - 1) shr 2);
          if S[4] <> cBase64[65] then
            Result := Result + Chr(((Pos(S[3], cBase64) - 1) and $03) shl 6 +
              (Pos(S[4], cBase64) - 1));
        end;
      end;
      Inc(I, 4);
    end else Inc(I);
  end;
end; { Base64Decode }

function Base64EncodeEx(mSource: string; mAddLine: Boolean = True): string;
var
  I, J: Integer;
  S: string;
begin
  Result := '';
  J := 0;
  for I := 0 to Length(mSource) div 3 - 1 do begin
    S := Copy(mSource, I * 3 + 1, 3);
    Result := Result + cBase64Ex[Ord(S[1]) shr 2 + 1];
    Result := Result + cBase64Ex[((Ord(S[1]) and $03) shl 4) + (Ord(S[2]) shr 4) + 1];
    Result := Result + cBase64Ex[((Ord(S[2]) and $0F) shl 2) + (Ord(S[3]) shr 6) + 1];
    Result := Result + cBase64Ex[Ord(S[3]) and $3F + 1];
    if mAddLine then begin
      Inc(J, 4);
      if J >= 76 then begin
        Result := Result + #13#10;
        J := 0;
      end;
    end;
  end;
  I := Length(mSource) div 3;
  S := Copy(mSource, I * 3 + 1, 3);
  case Length(S) of
    1: begin
        Result := Result + cBase64Ex[Ord(S[1]) shr 2 + 1];
        Result := Result + cBase64Ex[(Ord(S[1]) and $03) shl 4 + 1];
        Result := Result + cBase64Ex[65];
        Result := Result + cBase64Ex[65];
      end;
    2: begin
        Result := Result + cBase64Ex[Ord(S[1]) shr 2 + 1];
        Result := Result + cBase64Ex[((Ord(S[1]) and $03) shl 4) + (Ord(S[2]) shr 4) + 1];
        Result := Result + cBase64Ex[(Ord(S[2]) and $0F) shl 2 + 1];
        Result := Result + cBase64Ex[65];
      end;
  end;
end; { Base64Encode }

function Base64DecodeEx(mCode: string): string;
var
  I, L: Integer;
  S: string;
  Y: integer;
begin
  Result := '';
  L := Length(mCode);
  Y := L mod 4;
  while (Y mod 4) > 0 do
  begin
      mCode := mCode + '=';
      Y := Y + 1;
  end;

  L := Length(mCode);
  I := 1;
  while I <= L do begin
    if Pos(mCode[I], cBase64Ex) > 0 then begin
      S := Copy(mCode, I, 4);
      if (Length(S) = 4) then begin
        Result := Result + Chr((Pos(S[1], cBase64Ex) - 1) shl 2 +
          (Pos(S[2], cBase64Ex) - 1) shr 4);
        if S[3] <> cBase64Ex[65] then begin
          Result := Result + Chr(((Pos(S[2], cBase64Ex) - 1) and $0F) shl 4 +
            (Pos(S[3], cBase64Ex) - 1) shr 2);
          if S[4] <> cBase64Ex[65] then
            Result := Result + Chr(((Pos(S[3], cBase64Ex) - 1) and $03) shl 6 +
              (Pos(S[4], cBase64Ex) - 1));
        end;
      end;
      Inc(I, 4);
    end else Inc(I);
  end;
end; { Base64Decode }

end.
