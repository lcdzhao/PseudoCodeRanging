function localEarlycode = localEarlycodeInitial(settings,codeTable) %%产生初始本地超前码
    global earlyCodeNco;          %这个是本地早码的相位
    codeWord = settings.codeWord;
    earlyCodeTemp=[];
    Ncoh = settings.Ncoh;
    for n=1:Ncoh
        earlyCodeNco = earlyCodeNco+ codeWord ;
        earlyCodeNco = mod(earlyCodeNco,2^32*1023);
        index=1+fix(earlyCodeNco/2^32);
        c=codeTable(index);
        earlyCodeTemp=[earlyCodeTemp,c];
    end
    localEarlycode=earlyCodeTemp;
        