clc
clear
% Initialize constants, settings =========================================
settings = initSettings();
distenses = input('Please enter distences:');
delay_times = distenses/settings.c;
delay_points = round((delay_times/settings.CA_Period) * settings.samplesPerCode);
% 产生伪随机码,看cacode.m
w_code=cacode(settings.PRN);
%对CA码进行采样
samplecacodes = makeCaTable(settings.PRN,settings.codeLength,settings.codeFreqBasis ,settings.samplingFreq);
% 扩频，应该点乘离散的数据码
for delay_point_index = 1:length(delay_points)
    spread_code= zeros(0,0);            
    little_spread_code = [ samplecacodes(delay_points(delay_point_index) + 1:settings.samplesPerCode)...
        samplecacodes samplecacodes samplecacodes samplecacodes samplecacodes(1:delay_points(delay_point_index))];
    for i = 1:201
        spread_code = [spread_code little_spread_code];
    end
    %figure(3);
    %plot(spread_code(1:500));%这块注意只是取了5000个数据实际上有38192*2000个(2000ms的数据)
    %title('扩频后的数据')

    %调制
    t = (0:(length(spread_code) - 1))/settings.samplingFreq;
    sendeddataL1=spread_code.*cos(2*pi*settings.IF1.*t);     %L1,搭载伪码
    sendeddataL2=cos(2*pi*settings.IF2.*t);                  %L2,不搭载伪码
    sendeddata = sendeddataL1 + sendeddataL2;
    % 加噪声
    data= awgn(sendeddata, -10); 

    acqResult = acquisition(data,settings);

    trackResult = tracking(1,acqResult,settings,data);
    finalDistance = calculatePseudoranges(...
                trackResult.codePhase, ...
               settings);
    fprintf("真实距离 %f , 测得距离 %f，误差为 %f。 \n",...
        distenses(delay_point_index),finalDistance,  finalDistance - distenses(delay_point_index));
end