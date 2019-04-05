%function initinal 
%input: none
%output: setting
%function: set the runing condition
%including middle_freq,dup_freq,sample_freq,code_freq
%the bandwidth of PLL , FLL, DDLL 
%cofe_from_FLL_2_DDLL;
%the Nco_Length;
function settings = setting_canshu()
settings.middle_freq = 2.5e+6;              %数字中频频率
settings.dup_freq = 80;                     %多普勒频率
settings.sample_freq = 10e+6;               %采样频率
settings.code_freq = 2.046e+6;              %CB1码率
settings.code_length = 2046;                %伪码周期
settings.snr = -20;                         %信噪比
settings.FLL_flag = 1;                      %FLL标志，因为刚开始用FLL所以初始时FLL的标志为1
settings.PLL_flag = 0;                      %和上面的同理
settings.FLL_bandwidth = 4.2;               %FLL噪声带宽
settings.PLL_bandwidth = 10;                %PLL噪声带宽
settings.DDLL_bandwidth = 2;                %码环滤波噪声带宽
settings.cofe_FLL_auxi_DDLL  = 1/763;       %载波辅助系数,码率/载波频率
settings.nco_Length = 32;                   %方便计算
settings.noise_std = 1;
% setting.length = (1:10000);
% setting.length_no = 10000;
settings.sample_t = 1/settings.sample_freq; %采样时间
settings.K = 1;                             %环路增益
settings.transfer_coef = (2^settings.nco_Length)/settings.sample_freq;  %频率字转换系数，同时，将采样的频率还在其中
settings.middle_freq_nco = settings.middle_freq*settings.transfer_coef;%中频对应的频率字
settings.Ncoh = (settings.sample_freq / settings.code_freq)*settings.code_length;%一个积分清除时间内的采样点数
settings.Tcoh = settings.Ncoh *settings.sample_t;               %积分清除时间
settings.dot_length = [1:settings.Ncoh];                        %一个积分清除时间内的采样点数
settings.code_word = settings.code_freq * settings.transfer_coef;%码环控制字
settings.fd_code = settings.dup_freq*(1/763)*settings.transfer_coef;%添加在信号源的码上的多普勒，体现在码NCO上
%setting.fd_code = setting.dup_freq*settings.cofe_FLL_auxi_DDLL*setting.transfer_coef;%添加在信号源的码上的多普勒，体现在码NCO上
settings.code_original_phase = (2^settings.nco_Length)/2;     %本地超前码的初相位，相当于提前了1/2个码片
settings.modulate_code_bias_phsae = (2^settings.nco_Length)/8;%调制时，本地B1码的初相位，相当于提前了1/8个码片
settings.signal_phase = 0;
settings.local_phase = 0;