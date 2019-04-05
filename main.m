clc
clear
% Initialize constants, settings =========================================
settings = initSettings();
distenses = input('Please enter distences:');
delay_times = distenses/settings.c;
delay_points = round((delay_times/settings.CA_Period) * settings.samplesPerCode);
% ����α�����,��cacode.m
w_code=cacode(settings.PRN);
%��CA����в���
samplecacodes = makeCaTable(settings.PRN,settings.codeLength,settings.codeFreqBasis ,settings.samplingFreq);
% ��Ƶ��Ӧ�õ����ɢ��������
for delay_point_index = 1:length(delay_points)
    spread_code= zeros(0,0);            
    little_spread_code = [ samplecacodes(delay_points(delay_point_index) + 1:settings.samplesPerCode)...
        samplecacodes samplecacodes samplecacodes samplecacodes samplecacodes(1:delay_points(delay_point_index))];
    for i = 1:201
        spread_code = [spread_code little_spread_code];
    end
    %figure(3);
    %plot(spread_code(1:500));%���ע��ֻ��ȡ��5000������ʵ������38192*2000��(2000ms������)
    %title('��Ƶ�������')

    %����
    t = (0:(length(spread_code) - 1))/settings.samplingFreq;
    sendeddataL1=spread_code.*cos(2*pi*settings.IF1.*t);     %L1,����α��
    sendeddataL2=cos(2*pi*settings.IF2.*t);                  %L2,������α��
    sendeddata = sendeddataL1 + sendeddataL2;
    % ������
    data= awgn(sendeddata, -10); 

    acqResult = acquisition(data,settings);

    trackResult = tracking(1,acqResult,settings,data);
    finalDistance = calculatePseudoranges(...
                trackResult.codePhase, ...
               settings);
    fprintf("��ʵ���� %f , ��þ��� %f�����Ϊ %f�� \n",...
        distenses(delay_point_index),finalDistance,  finalDistance - distenses(delay_point_index));
end