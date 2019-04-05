function trackResult = tracking(fid, acqResult, settings,data)
%% test
loopPara = loopCanshuCalculate(settings);%���㻷·�˲�������

codeTable = cacode(settings.PRN);          %���ú���������α�����

fllNcoAdder = 0;                   %fll  NCO�ӷ�����Ӧ�����˲�����ʹ��
carrierNcoSum = 0;                 %�����ֵ�ٳ�2*pi������λ��
pllNcoAdder = 0;                   %pll  NCO�ӷ�����Ӧ�����˲�����ʹ��
loopCount = 0;                      %ѭ������
codeNcoSum = 0;                    %�����һ������λ����Ķ���
codeNcoAdder = 0;                  %ddll  NCO�ӷ�����Ӧ�����˲�����ʹ��
nIQ = 2;                            
n = 3;
outputFll(2:3) = 0;                 %����������fll��Ƶ�������
outputFilterFll(1:3) = 0;          %fll ��·�˲��������
outputFilterPll(1:3) = 0;          %pll ��·�˲��������
outputPll(2:3) = 0;                 %pll ��Ƶ�������
outputFilterDdll(1:3) = 0;         %ddll ��·�˲��������
trackResult.pllDiscrFilter = zeros(1,settings.msToProcess);



Tcoh = settings.Tcoh;          %��������ʱ��
global earlyCodeNco;      %�ǽ��ն˵ģ���Ϊ����Ļ�����ʱ������붼���Դ����ж���
earlyCodeNco = ((1 - (acqResult.codePhase-3)/settings.samplesPerCode)...
    *settings.codeLength) * 2^settings.ncoLength;
earlyCodeNco = mod(earlyCodeNco,2^settings.ncoLength*1023);
localEarlyCodeLast = localEarlycodeInitial(settings,codeTable); %�������س�ǰ�룬���ն�ʹ�ã���Ϊ����Ļ�����ʱ������붼���Դ����ж���

trackResult.carrNcoPhases = zeros(1,settings.msToProcess);       %ÿ�λ�������ǰ�ز���nco��λ,δ����ת��
trackResult.codeNcoPhases = zeros(1,settings.msToProcess);       %ÿ�λ�������ǰB1���nco��λ,δ����ת��
trackResult.carrFreq = zeros(1,settings.msToProcess);
trackResult.trackFlag = 0;                  %����ɹ���־λ
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
    trackResult.flag(loopNum) = settings.PLLFlag;         %��ʶ�ô�ѭ����û�н���PLL����
    %��ȡ��������
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
    
    %�������������ز�
    for demondNum = 1:settings.Ncoh 
        localCos(demondNum) = cos(2*pi*carrierNcoSum/2^settings.ncoLength);
        localSin(demondNum) = -sin(2*pi*carrierNcoSum/2^settings.ncoLength);
        carrierNcoSum = carrierNcoSum + settings.middleFreqNco1 + fllNcoAdder + pllNcoAdder ;%���������ز�NCO
    end
    
    codeNcoSum = codeNcoAdder + settings.codeWord ...              %���������뻷NCO,�������carrierNcoSum����һ��,2048Ϊ��׼
        + fllNcoAdder*settings.cofeFLLAuxiDDLL;                
  
     %�������س�ǰ����ʱ���ͺ���
    [localEarlyCode,localPromptCode,localLateCode,settings.localPhase]=localcodeGenerate(localEarlyCodeLast,codeNcoSum,codeTable,settings);
    localEarlyCodeLast = localEarlyCode;
    %�ز����    
    IDemonCarrier = localCos.*receiveSignal;
    QDemonCarrier = localSin.*receiveSignal;

    
    %�źŽ������������
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
% %         �����޷����м�Ƶ��
        dotFll = I_P_final(nIQ - 1) * I_P_final(nIQ) + Q_P_final(nIQ - 1) * Q_P_final(nIQ);
        crossFll = I_P_final(nIQ - 1) * Q_P_final(nIQ) - I_P_final(nIQ) * Q_P_final(nIQ - 1);
        outputFll(n) = atan2(crossFll,dotFll)/(Tcoh*2*pi); 
        trackResult.FllDiscr(loopNum) = outputFll(n);
        
        outputFilterFll(n) = (loopPara.cofeone_FLL * outputFll(n)) + (loopPara.cofetwo_FLL * outputFll(n - 1)) + (2 * outputFilterFll(n - 1)) - outputFilterFll(n - 2);
        trackResult.fllDiscrFilt(loopNum) = outputFilterFll(n);
        
        fllNcoAdder = outputFilterFll(n) * settings.transferCoef ;  %Ƶ����ת��      
        outputFll(n - 1)=outputFll(n);
        outputFilterFll(n - 2)=outputFilterFll(n - 1);
        outputFilterFll(n - 1)=outputFilterFll(n);
        
         if settings.PLLFlag == 1
            %���໷������
            outputPll(n) = atan2(Q_P_final(nIQ),I_P_final(nIQ)); 
            outputFilterPll(n) = loopPara.cofeone_PLL*outputPll(n) + loopPara.cofetwo_PLL*outputPll(n-1)+loopPara.cofethree_PLL*outputPll(n-2)+2*outputFilterPll(n-1)-outputFilterPll(n-2);
            trackResult.pllDiscr(loopNum) = outputPll(n);
            trackResult.pllDiscrFilter(loopNum) = outputFilterPll(n);
            pllNcoAdder = (outputFilterPll(n)/(2*pi)) * settings.transferCoef;  %Ƶ����ת��
            
%             outputPll(1:2) = outputPll(2:3);
%             outputFilterPll(1:2) = outputFilterPll(2:3);
            outputPll(n-2) = outputPll(n-1);
            outputPll(n-1) = outputPll(n);
            outputFilterPll(n-2) = outputFilterPll(n-1);
            outputFilterPll(n-1) = outputFilterPll(n);
         end
        
        I_P_final(nIQ - 1) = I_P_final(nIQ);
        Q_P_final(nIQ - 1) = Q_P_final(nIQ);
       if 0 == settings.PLLFlag  && abs(outputFll(n))<10  %��Ƶ������״̬�£��ź��뱾��Ƶ��С��10ʱ
            loopCount = loopCount + 1;
            if  loopCount>200            
                   settings.PLLFlag = 1;
            end
       elseif  1 == settings.PLLFlag && abs(outputFll(n))>30      %�����໷����״̬�£���Ƶ�����������ź��뱾��Ƶ�����30ʱ
            loopCount = loopCount-1;
            if  0 == loopCount
                settings.PLLFlag = 0;
            end
       end
    end
 %�뻷������
    outputDdll(n) = ((I_E_final - I_L_final)*I_P_final(nIQ) + (Q_E_final - Q_L_final)*Q_P_final(nIQ) )/((I_P_final(nIQ)^2 + Q_P_final(nIQ)^2)*2);  % DDLL_discri_1      
    trackResult.dllDiscr(loopNum) = outputDdll(n);
    %�뻷�˲��������ף�
    outputFilterDdll(n) = outputFilterDdll(n -1) + (loopPara.cofeone_DDLL*outputDdll(n)) + loopPara.cofetwo_DDLL*outputDdll(n - 1);
    trackResult.dllDiscrFilter(loopNum) = outputFilterDdll(n);
    % ת����Ƶ�ʿ�����
    codeNcoAdder = outputFilterDdll(n) * settings.transferCoef ; %Ƶ����ת��
    outputDdll(n - 1)=outputDdll(n);
    outputFilterDdll(n - 1) = outputFilterDdll(n);
    
    
end

trackResult.carrPhase = carrStartPhaseSum / startCountPhase;
trackResult.codePhase = codeStartPhaseSum / startCountPhase;
if  startCountPhase > 0
    trackResult.trackFlag = 1;
end