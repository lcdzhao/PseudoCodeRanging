%function initinal 
%input: none
%output: setting
%function: set the runing condition
%including middle_freq,dup_freq,sample_freq,code_freq
%the bandwidth of PLL , FLL, DDLL 
%cofe_from_FLL_2_DDLL;
%the Nco_Length;
function settings = setting_canshu()
settings.middle_freq = 2.5e+6;              %������ƵƵ��
settings.dup_freq = 80;                     %������Ƶ��
settings.sample_freq = 10e+6;               %����Ƶ��
settings.code_freq = 2.046e+6;              %CB1����
settings.code_length = 2046;                %α������
settings.snr = -20;                         %�����
settings.FLL_flag = 1;                      %FLL��־����Ϊ�տ�ʼ��FLL���Գ�ʼʱFLL�ı�־Ϊ1
settings.PLL_flag = 0;                      %�������ͬ��
settings.FLL_bandwidth = 4.2;               %FLL��������
settings.PLL_bandwidth = 10;                %PLL��������
settings.DDLL_bandwidth = 2;                %�뻷�˲���������
settings.cofe_FLL_auxi_DDLL  = 1/763;       %�ز�����ϵ��,����/�ز�Ƶ��
settings.nco_Length = 32;                   %�������
settings.noise_std = 1;
% setting.length = (1:10000);
% setting.length_no = 10000;
settings.sample_t = 1/settings.sample_freq; %����ʱ��
settings.K = 1;                             %��·����
settings.transfer_coef = (2^settings.nco_Length)/settings.sample_freq;  %Ƶ����ת��ϵ����ͬʱ����������Ƶ�ʻ�������
settings.middle_freq_nco = settings.middle_freq*settings.transfer_coef;%��Ƶ��Ӧ��Ƶ����
settings.Ncoh = (settings.sample_freq / settings.code_freq)*settings.code_length;%һ���������ʱ���ڵĲ�������
settings.Tcoh = settings.Ncoh *settings.sample_t;               %�������ʱ��
settings.dot_length = [1:settings.Ncoh];                        %һ���������ʱ���ڵĲ�������
settings.code_word = settings.code_freq * settings.transfer_coef;%�뻷������
settings.fd_code = settings.dup_freq*(1/763)*settings.transfer_coef;%������ź�Դ�����ϵĶ����գ���������NCO��
%setting.fd_code = setting.dup_freq*settings.cofe_FLL_auxi_DDLL*setting.transfer_coef;%������ź�Դ�����ϵĶ����գ���������NCO��
settings.code_original_phase = (2^settings.nco_Length)/2;     %���س�ǰ��ĳ���λ���൱����ǰ��1/2����Ƭ
settings.modulate_code_bias_phsae = (2^settings.nco_Length)/8;%����ʱ������B1��ĳ���λ���൱����ǰ��1/8����Ƭ
settings.signal_phase = 0;
settings.local_phase = 0;