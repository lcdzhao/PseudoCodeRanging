% ��ΪCA�������ֻ��1ms��ˣ�������ΧΪ0.001����

clc
clear
settings = initSettings();
distenses = input('Please enter distences:');
delay_times = distenses/settings.c;
PRN = 18;



%ÿ��CA�����ڵĲ�����������������38192
samplesPerCode = round(settings.samplingFreq /(settings.codeFreqBasis/settings.codeLength));
% Initialize constants, settings =========================================


%�����ӳ�һ��ʱ�䣬��Ҫʹ�ź�Ų�����ٸ�������
delay_points = round((delay_times/settings.CA_Period) * samplesPerCode);



% ����α�����,��cacode.m
w_code=cacode(PRN);
%figure(1);
%plot(w_code);
%title('1023λgold��');
%str=['ʵ���ز�Ƶ��Ϊ=' num2str(IF)];
%disp(str);

%��CA����в���
samplecacodes = makeCaTable(PRN,settings.codeLength,settings.codeFreqBasis,settings.samplingFreq);
%figure(10);
%plot(samplecacodes(1:500));
%title('�������CA��');


for delay_point_index = 1:length(delay_points)
% ��Ƶ��Ӧ�õ����ɢ��������
    spread_code= zeros(0,0);
    % spread_code=[ spread_code spread_code];
    % spread_code=[ spread_code spread_code spread_code spread_code spread_code];
    % spread_code=[ spread_code spread_code];
    % spread_code=[ spread_code spread_code spread_code spread_code spread_code];
    % spread_code=[ spread_code spread_code];
    % spread_code=[ spread_code spread_code];
    little_spread_code = [ samplecacodes(delay_points(delay_point_index)+1:samplesPerCode) samplecacodes samplecacodes samplecacodes samplecacodes samplecacodes(1:delay_points(delay_point_index)) ];
    for i = 1:201
        spread_code = [spread_code little_spread_code];
    end
    % figure(3);
    % plot(spread_code(1:500));%���ע��ֻ��ȡ��5000������ʵ������38192*1005��(1005ms������)
    % title('��Ƶ�������')

    %����
    t = (0:(length(spread_code) - 1))/settings.samplingFreq;
    sendeddata=spread_code.*cos(2*pi*settings.IF.*t);
    % figure(4);
    % plot(sendeddata(1:300));
    % title('���ƺ������');

    % ������
    data= awgn(sendeddata, -10); %��-20db�ֱ��İ�����
    % figure(5);
    % plot(data(1:38192));
    % title('���Ӱ������������');


    acqResults = acquisition(data,settings);
    %figure(6);

    %channel = preRun(acqResults,settings);
    %showChannelStatus(channel,settings);
    %[trackResults, channel] = tracking(0,channel,settings,data);
    %[subFrameStart, activeChnList] = findPreambles(trackResults, settings);

    finalDistance = calculatePseudoranges(...
                acqResults.codePhase(PRN), ...
               settings);
           
           
    fprintf("��ʵ���� %f , ��þ��� %f �� \n",distenses(delay_point_index),finalDistance);
    %codeError= test(PRN,data)
end

