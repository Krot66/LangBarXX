Base64PNG_to_HICON(Base64PNG, W:=0, H:=0) {     ;   By SKAN on D094/D357 @ tiny.cc/t-36636
Local BLen:=StrLen(Base64PNG), Bin:=0,     nBytes:=Floor(StrLen(RTrim(Base64PNG,"="))*3/4)                     
  Return DllCall("Crypt32.dll\CryptStringToBinary", "Str",Base64PNG, "UInt",BLen, "UInt",1
            ,"Ptr",&(Bin:=VarSetCapacity(Bin,nBytes)), "UIntP",nBytes, "UInt",0, "UInt",0)
       ? DllCall("CreateIconFromResourceEx", "Ptr",&Bin, "UInt",nBytes, "Int",True, "UInt"
                 ,0x30000, "Int",W, "Int",H, "UInt",0, "UPtr") : 0            
}