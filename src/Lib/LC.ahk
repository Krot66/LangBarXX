; From libcrypt https://github.com/ahkscript/libcrypt.ahk

LC_Base64_EncodeText(Text,Encoding="UTF-8")
{
	VarSetCapacity(Bin, StrPut(Text, Encoding))
	LC_Base64_Encode(Base64, Bin, StrPut(Text, &Bin, Encoding)-1)
	return Base64
}

LC_Base64_DecodeText(Text,Encoding="UTF-8")
{
	Len := LC_Base64_Decode(Bin, Text)
	return StrGet(&Bin, Len, Encoding)
}

LC_Base64_Encode(ByRef Out, ByRef In, InLen)
{
	return LC_Bin2Str(Out, In, InLen, 0x40000001)
}

LC_Base64_Decode(ByRef Out, ByRef In)
{
	return LC_Str2Bin(Out, In, 0x1)
}


LC_Bin2Hex(ByRef Out, ByRef In, InLen, Pretty=False)
{
	return LC_Bin2Str(Out, In, InLen, Pretty ? 0xb : 0x4000000c)
}

LC_Hex2Bin(ByRef Out, ByRef In)
{
	return LC_Str2Bin(Out, In, 0x8)
}

LC_Bin2Str(ByRef Out, ByRef In, InLen, Flags)
{
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", Flags, "Ptr", 0, "UInt*", OutLen)
	VarSetCapacity(Out, OutLen * (1+A_IsUnicode))
	DllCall("Crypt32.dll\CryptBinaryToString", "Ptr", &In
	, "UInt", InLen, "UInt", Flags, "Str", Out, "UInt*", OutLen)
	return OutLen
}

LC_Str2Bin(ByRef Out, ByRef In, Flags)
{
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", Flags, "Ptr", 0, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	VarSetCapacity(Out, OutLen)
	DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &In, "UInt", StrLen(In)
	, "UInt", Flags, "Str", Out, "UInt*", OutLen, "Ptr", 0, "Ptr", 0)
	return OutLen
}