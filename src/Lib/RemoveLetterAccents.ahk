RemoveLetterAccents(text)
    {
        static Array := { "е" : "ё"
        , "и" : "й"
        , "у" : "ў"
        , "і" : "ї"
        , "a" : "áàâǎăãảạäåāąấầẫẩậắằẵẳặǻ"
        , "c" : "ćĉčċç"
        , "d" : "ďđð"
        , "e" : "ëéèêěĕẽẻėēęếềễểẹệ"
        , "g" : "ğĝġģ"
        , "h" : "ĥħ"
        , "i" : "íìĭîǐïĩįīỉịĵ"
        , "k" : "ķ"
        , "l" : "ĺľļłŀ"
        , "n" : "ńňñņ"
        , "o" : "óòŏôốồỗổǒöőõøǿōỏơớờỡởợọộ"
        , "p" : "ṕṗ"
        , "r" : "ŕřŗ"
        , "s" : "śŝšş"
        , "t" : "ťţŧ"
        , "u" : "úùŭûǔůüǘǜǚǖűũųūủưứừữửựụ"
        , "w" : "ẃẁŵẅ"
        , "y" : "ýỳŷÿỹỷỵ"
        , "z" : "źžż" }

        for k, v in Array
        {
            StringUpper, VU, v
            StringUpper, KU, k
            text:=RegExReplace(text,"[" v "]",k)
            text:=RegExReplace(text,"[" VU "]",KU)
        }
        Return text
    }