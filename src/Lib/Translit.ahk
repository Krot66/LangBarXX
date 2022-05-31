Translit(x)
{
	StringCaseSense, On

	StringReplace, x, x, а , a , All
	StringReplace, x, x, б , b , All
	StringReplace, x, x, с , c , All
	StringReplace, x, x, в , v , All
	StringReplace, x, x, г , g , All
	StringReplace, x, x, д , d , All
	StringReplace, x, x, е , e , All
	StringReplace, x, x, ё , yo , All
	StringReplace, x, x, ж , zh , All
	StringReplace, x, x, з , z , All
	StringReplace, x, x, и , i , All
	StringReplace, x, x, й , j , All
	StringReplace, x, x, к , k , All
	StringReplace, x, x, л , l , All
	StringReplace, x, x, м , m , All
	StringReplace, x, x, н , n , All
	StringReplace, x, x, о , o , All
	StringReplace, x, x, п , p , All
	StringReplace, x, x, р , r , All
	StringReplace, x, x, с , s , All
	StringReplace, x, x, т , t , All
	StringReplace, x, x, у , u , All
	StringReplace, x, x, ф , f , All
	StringReplace, x, x, х , kh , All
	StringReplace, x, x, ц , ts , All
	StringReplace, x, x, ч , ch , All
	StringReplace, x, x, ш , sh , All
	StringReplace, x, x, щ , shh , All
	StringReplace, x, x, ъ , " , All
	StringReplace, x, x, ы , y , All
	StringReplace, x, x, ь , ' , All
	StringReplace, x, x, э , eh , All
	StringReplace, x, x, ю , yu , All
	StringReplace, x, x, я , ya , All

	StringReplace, x, x, А , A , All
	StringReplace, x, x, Б , B , All
	StringReplace, x, x, С , C , All
	StringReplace, x, x, В , V , All
	StringReplace, x, x, Г , G , All
	StringReplace, x, x, Д , D , All
	StringReplace, x, x, Е , E , All
	StringReplace, x, x, Ё , Yo , All
	StringReplace, x, x, Ж , Zh , All
	StringReplace, x, x, З , Z , All
	StringReplace, x, x, И , I , All
	StringReplace, x, x, Й , J , All
	StringReplace, x, x, К , K , All
	StringReplace, x, x, Л , L , All
	StringReplace, x, x, М , M , All
	StringReplace, x, x, Н , N , All
	StringReplace, x, x, О , O , All
	StringReplace, x, x, П , P , All
	StringReplace, x, x, Р , R , All
	StringReplace, x, x, С , S , All
	StringReplace, x, x, Т , T , All
	StringReplace, x, x, У , U , All
	StringReplace, x, x, Ф , F , All
	StringReplace, x, x, Х , Kh , All
	StringReplace, x, x, Ц , Ts , All
	StringReplace, x, x, Ч , Ch , All
	StringReplace, x, x, Ш , Sh , All
	StringReplace, x, x, Щ , Shh , All
	StringReplace, x, x, Ъ , " , All
	StringReplace, x, x, Ы , Y , All
	StringReplace, x, x, Ь , ' , All
	StringReplace, x, x, Э , Eh , All
	StringReplace, x, x, Ю , Yu , All
	StringReplace, x, x, Я , Ya , All
	return x
}