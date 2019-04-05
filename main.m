% 因为CA码的周期只有1ms因此，测距最大范围为0.001光速

clc
clear
settings = initSettings();
distenses = input('Please enter distences:');
delay_times = distenses/settings.c;
PRN = 18;



%每个CA码周期的采样数，整数倍不好38192
samplesPerCode = round(settings.samplingFreq /(settings.codeFreqBasis/settings.codeLength));
% Initialize constants, settings =========================================


%计算延迟一定时间，需要使信号挪动多少个采样点
delay_points = round((delay_times/settings.CA_Period) * samplesPerCode);



% 产生伪随机码,看cacode.m
w_code=cacode(PRN);
%figure(1);
%plot(w_code);
%title('1023位gold码');
%str=['实际载波频率为=' num2str(IF)];
%disp(str);

%对CA码进行采样
samplecacodes = makeCaTable(PRN,settings.codeLength,settings.codeFreqBasis,settings.samplingFreq);
%figure(10);
%plot(samplecacodes(1:500));
%title('采样后的CA码');


for delay_point_index = 1:length(delay_points)
% 扩频，应该点乘离散的数据码
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
    % plot(spread_code(1:500));%这块注意只是取了5000个数据实际上有38192*1005个(1005ms的数据)
    % title('扩频后的数据')

    %调制
    t = (0:(length(spread_code) - 1))/settings.samplingFreq;
    sendeddata=spread_code.*cos(2*pi*settings.IF.*t);
    % figure(4);
    % plot(sendeddata(1:300));
    % title('调制后的数据');

    % 加噪声
    data= awgn(sendeddata, -10); %加-20db分贝的白噪声
    % figure(5);
    % plot(data(1:38192));
    % title('附加白噪声后的数据');


    acqResults = acquisition(data,settings);
    %figure(6);

    %channel = preRun(acqResults,settings);
    %showChannelStatus(channel,settings);
    %[trackResults, channel] = tracking(0,channel,settings,data);
    %[subFrameStart, activeChnList] = findPreambles(trackResults, settings);

    finalDistance = calculatePseudoranges(...
                acqResults.codePhase(PRN), ...
               settings);
           
           
    fprintf("真实距离 %f , 测得距离 %f 。 \n",distenses(delay_point_index),finalDistance);
    %codeError= test(PRN,data)
end

