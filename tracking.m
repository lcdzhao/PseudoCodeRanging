function trackResult = tracking(fid, acqResult, settings,data)
%% test
loopPara = loopCanshuCalculate(settings);%计算环路滤波器参数

codeTable = cacode(settings.PRN);          %调用函数，产生伪随机码

fllNcoAdder = 0;                   %fll  NCO加法器，应该在滤波器中使用
carrierNcoSum = 0;                 %给这个值再乘2*pi就是相位了
pllNcoAdder = 0;                   %pll  NCO加法器，应该在滤波器中使用
loopCount = 0;                      %循环次数
codeNcoSum = 0;                    %大概是一个和相位很像的东西
codeNcoAdder = 0;                  %ddll  NCO加法器，应该在滤波器中使用
nIQ = 2;                            
n = 3;
outputFll(2:3) = 0;                 %这里面大概是fll鉴频器的输出
outputFilterFll(1:3) = 0;          %fll 环路滤波器的输出
outputFilterPll(1:3) = 0;          %pll 环路滤波器的输出
outputPll(2:3) = 0;                 %pll 鉴频器的输出
outputFilterDdll(1:3) = 0;         %ddll 环路滤波器的输出
trackResult.pllDiscrFilter = zeros(1,settings.msToProcess);



Tcoh = settings.Tcoh;          %积分清零时间
global earlyCodeNco;      %是接收端的，因为早码的话，即时码和晚码都可以从其中而来
earlyCodeNco = ((1 - (acqResult.codePhase-3)/settings.samplesPerCode)...
    *settings.codeLength) * 2^settings.ncoLength;
earlyCodeNco = mod(earlyCodeNco,2^settings.ncoLength*1023);
localEarlyCodeLast = localEarlycodeInitial(settings,codeTable); %产生本地超前码，接收端使用，因为早码的话，即时码和晚码都可以从其中而来

trackResult.carrNcoPhases = zeros(1,settings.msToProcess);       %每次积分清零前载波的nco相位,未经过转换
trackResult.codeNcoPhases = zeros(1,settings.msToProcess);       %每次积分清零前B1码的nco相位,未经过转换
trackResult.carrFreq = zeros(1,settings.msToProcess);
trackResult.trackFlag = 0;                  %捕获成功标志位
blksize = settings.samplesPerCode;
startCountPhase = -100;
carrStartPhaseSum = 0;
codeStartPhaseSum = 0;
for loopNum = 1 : settings.msToProcess
    
    
    
    
    carrNcoPhase = mod(carrierNcoSum,2^settings.ncoLength) * 2 * pi;  
    if carrNcoPhase > pi*2^settings.ncoLength
        trackResult.carrNcoPhases(loopNum) = ...
             ((carrNcoPhase - 2*pi*2^settings.ncoLength)/2*pi);
    else
        trackResult.carrNcoPhases(loopNum) = (carrNcoPhase/2*pi);
    end
    trackResult.codeNcoPhases(loopNum) = ...
        ((((earlyCodeNco)/settings.codeLength)*settings.samplesPerCode...
         -2.5*2^settings.ncoLength) /settings.samplesPerCode)*settings.codeLength;       
    trackResult.carrFreq(loopNum) = ...
         (settings.middleFreqNco1 + fllNcoAdder + pllNcoAdder)/settings.transferCoef;
    trackResult.flag(loopNum) = settings.PLLFlag;         %标识该次循环有没有进行PLL锁定
    %读取接收数据
    receiveSignal = data(fid:fid + blksize - 1);
    fid = fid + blksize ;

    if 1 == settings.PLLFlag
        startCountPhase = startCountPhase + 1;
        if startCountPhase >= 1
            carrStartPhaseSum = carrStartPhaseSum + trackResult.carrNcoPhases(loopNum);
            codeStartPhaseSum = codeStartPhaseSum + trackResult.codeNcoPhases(loopNum);
        end
    else     
        if startCountPhase >= -10
            startCountPhase = -15;
            carrStartPhaseSum = 0;
            codeStartPhaseSum = 0;
        end
    end
    
    %产生本地再生载波
    for demondNum = 1:settings.Ncoh 
        localCos(demondNum) = cos(2*pi*carrierNcoSum/2^settings.ncoLength);
        localSin(demondNum) = -sin(2*pi*carrierNcoSum/2^settings.ncoLength);
        carrierNcoSum = carrierNcoSum + settings.middleFreqNco1 + fllNcoAdder + pllNcoAdder ;%本地再生载波NCO
    end
    
    codeNcoSum = codeNcoAdder + settings.codeWord ...              %本地再生码环NCO,和上面的carrierNcoSum作用一样,2048为基准
        + fllNcoAdder*settings.cofeFLLAuxiDDLL;                
  
     %产生本地超前，即时，滞后码
    [localEarlyCode,localPromptCode,localLateCode,settings.localPhase]=localcodeGenerate(localEarlyCodeLast,codeNcoSum,codeTable,settings);
    localEarlyCodeLast = localEarlyCode;
    %载波解调    
    IDemonCarrier = localCos.*receiveSignal;
    QDemonCarrier = localSin.*receiveSignal;

    
    %信号解扩并积分清除
    I_E_final = sum(IDemonCarrier.*localEarlyCode);
    Q_E_final = sum(QDemonCarrier.*localEarlyCode);
    I_P_final(nIQ) = sum(IDemonCarrier.*localPromptCode);
    Q_P_final(nIQ) = sum(QDemonCarrier.*localPromptCode);
    I_L_final = sum(IDemonCarrier.*localLateCode);
    Q_L_final = sum(QDemonCarrier.*localLateCode);
    
    
%     I_P_final(nIQ) = sum(IDemonCarrier);
%     Q_P_final(nIQ) = sum(QDemonCarrier);
    
    
    if  1 == loopNum
        I_P_final(nIQ - 1) = I_P_final(nIQ);
        Q_P_final(nIQ - 1) = Q_P_final(nIQ);
    else
% %         四象限反正切鉴频器
        dotFll = I_P_final(nIQ - 1) * I_P_final(nIQ) + Q_P_final(nIQ - 1) * Q_P_final(nIQ);
        crossFll = I_P_final(nIQ - 1) * Q_P_final(nIQ) - I_P_final(nIQ) * Q_P_final(nIQ - 1);
        outputFll(n) = atan2(crossFll,dotFll)/(Tcoh*2*pi); 
        trackResult.FllDiscr(loopNum) = outputFll(n);
        
        outputFilterFll(n) = (loopPara.cofeone_FLL * outputFll(n)) + (loopPara.cofetwo_FLL * outputFll(n - 1)) + (2 * outputFilterFll(n - 1)) - outputFilterFll(n - 2);
        trackResult.fllDiscrFilt(loopNum) = outputFilterFll(n);
        
        fllNcoAdder = outputFilterFll(n) * settings.transferCoef ;  %频率字转换      
        outputFll(n - 1)=outputFll(n);
        outputFilterFll(n - 2)=outputFilterFll(n - 1);
        outputFilterFll(n - 1)=outputFilterFll(n);
        
         if settings.PLLFlag == 1
            %锁相环鉴相器
            outputPll(n) = atan2(Q_P_final(nIQ),I_P_final(nIQ)); 
            outputFilterPll(n) = loopPara.cofeone_PLL*outputPll(n) + loopPara.cofetwo_PLL*outputPll(n-1)+loopPara.cofethree_PLL*outputPll(n-2)+2*outputFilterPll(n-1)-outputFilterPll(n-2);
            trackResult.pllDiscr(loopNum) = outputPll(n);
            trackResult.pllDiscrFilter(loopNum) = outputFilterPll(n);
            pllNcoAdder = (outputFilterPll(n)/(2*pi)) * settings.transferCoef;  %频率字转换
            
%             outputPll(1:2) = outputPll(2:3);
%             outputFilterPll(1:2) = outputFilterPll(2:3);
            outputPll(n-2) = outputPll(n-1);
            outputPll(n-1) = outputPll(n);
            outputFilterPll(n-2) = outputFilterPll(n-1);
            outputFilterPll(n-1) = outputFilterPll(n);
         end
        
        I_P_final(nIQ - 1) = I_P_final(nIQ);
        Q_P_final(nIQ - 1) = Q_P_final(nIQ);
       if 0 == settings.PLLFlag  && abs(outputFll(n))<10  %锁频环工作状态下，信号与本地频差小于10时
            loopCount = loopCount + 1;
            if  loopCount>200            
                   settings.PLLFlag = 1;
            end
       elseif  1 == settings.PLLFlag && abs(outputFll(n))>30      %在锁相环工作状态下，锁频环所鉴出的信号与本地频差大于30时
            loopCount = loopCount-1;
            if  0 == loopCount
                settings.PLLFlag = 0;
            end
       end
    end
 %码环鉴别器
    outputDdll(n) = ((I_E_final - I_L_final)*I_P_final(nIQ) + (Q_E_final - Q_L_final)*Q_P_final(nIQ) )/((I_P_final(nIQ)^2 + Q_P_final(nIQ)^2)*2);  % DDLL_discri_1      
    trackResult.dllDiscr(loopNum) = outputDdll(n);
    %码环滤波器（二阶）
    outputFilterDdll(n) = outputFilterDdll(n -1) + (loopPara.cofeone_DDLL*outputDdll(n)) + loopPara.cofetwo_DDLL*outputDdll(n - 1);
    trackResult.dllDiscrFilter(loopNum) = outputFilterDdll(n);
    % 转换成频率控制字
    codeNcoAdder = outputFilterDdll(n) * settings.transferCoef ; %频率字转换
    outputDdll(n - 1)=outputDdll(n);
    outputFilterDdll(n - 1) = outputFilterDdll(n);
    
    
end

trackResult.carrPhase = carrStartPhaseSum / startCountPhase;
trackResult.codePhase = codeStartPhaseSum / startCountPhase;
if  startCountPhase > 0
    trackResult.trackFlag = 1;
end