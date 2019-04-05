function settings = initSettings()
%% Processing settings ====================================================
% Number of milliseconds to be processed used 36000 + any transients (see
% below - in Nav parameters) to ensure nav subframes are provided
%
settings.msToProcess        = 1000;        %[ms]��Ҫ����ĺ�����

settings.PRN = 18;


%% Raw signal file name and other parameter ========ԭʼ�ź��ļ�������������=======================
% This is a "default" name of the data file (signal record) to be used in
% the post-processing mode
settings.ncoLength = 32;                   %�������


% Intermediate, sampling and code frequencies
settings.IF1                 = 9.548e6 %1.42e6 %4.123968e6;      %[Hz]   %L1��Ƶ
settings.samplingFreq       = 38.192e6 %5.714e6 %16.367667e6;     %[Hz] %����Ƶ�ʱ�
settings.codeFreqBasis      = 1.023e6;      %[Hz]   %��Ԫ�Ļ�Ƶ
settings.IF2                 = 14.548e6 %1.42e6 %4.123968e6;      %[Hz]   %L2��Ƶ
% Define number of chips in a code period
settings.codeLength         = 1023;     %һ����Ԫ���ڵġ�Ƭ����
%ÿ��CA�����ڵĲ�����������������38192
settings.samplesPerCode = round(settings.samplingFreq /(settings.codeFreqBasis/settings.codeLength));  %һ����Ԫ�ж��ٸ�������

%% Acquisition settings ==============��������=====================================
% Skips acquisition in the script postProcessing.m if set to 1
%�������Ϊ1
settings.skipAcquisition    = 0;
% List of satellites to look for. Some satellites can be excluded to speed
% up acquisition    %����Ѱ�������б������ų�һЩ�����Լӿ첶��
%settings.acqSatelliteList   = 1:32;         %[PRN numbers]  %����������б�
% Band around IF to search for satellite signal. Depends on max Doppler
%����������Ƶ�ʾ���
settings.acqSearchBand      = 10;           %[kHz]
% Threshold for the signal presence decision rule
settings.acqThreshold       = 2.5;  %�о���ֵ

%% Tracking loops settings =============���ٻ�·����===================================
% Code tracking loop parameters     ����ٻ�·����
settings.FLLFlag = 1;                      %FLL��־����Ϊ�տ�ʼ��FLL���Գ�ʼʱFLL�ı�־Ϊ1
settings.PLLFlag = 0;                      %�������ͬ��
settings.FLLBandwidth = 4.2;               %FLL��������
settings.PLLBandwidth = 10;                %PLL��������
settings.DDLLBandwidth = 2;                %�뻷�˲���������
settings.cofeFLLAuxiDDLL  = 1/763;       %�ز�����ϵ��,����/�ز�Ƶ��
settings.dllCorrelatorSpacing = 0.5;



%% Plot settings ==========================================================
% Enable/disable plotting of the tracking results for each channel
settings.plotTracking       = 1;            % 0 - Off
                                            % 1 - On

                                            
%% Constants ==============================================================

settings.c                  = 299792458;    % The speed of light, [m/s]
settings.startOffset        = 0;       %[ms] Initial sign. travel time
settings.CA_Period          = (1/settings.codeFreqBasis)*settings.codeLength;  % ÿ��CA�������

%% 

settings.dupFreq = 0;                     %������Ƶ��
settings.noiseStd = 1;
% setting.length = (1:10000);
% setting.length_no = 10000;
settings.sampleT = 1/settings.samplingFreq; %����ʱ��
settings.K = 1;                             %��·����


settings.transferCoef = (2^settings.ncoLength)/settings.samplingFreq;  %Ƶ����ת��ϵ����ͬʱ����������Ƶ�ʻ�������
settings.middleFreqNco1 = settings.IF1*settings.transferCoef;%��Ƶ1��Ӧ��Ƶ����
settings.middleFreqNco2 = settings.IF2*settings.transferCoef;%��Ƶ��Ӧ��Ƶ����
settings.Ncoh = (settings.samplingFreq / settings.codeFreqBasis )*settings.codeLength;%һ���������ʱ���ڵĲ�������
settings.Tcoh = settings.Ncoh *settings.sampleT;               %�������ʱ��
settings.dotLength = [1:settings.Ncoh];                        %һ���������ʱ���ڵĲ�������
settings.codeWord = settings.codeFreqBasis * settings.transferCoef;%�뻷������
settings.fdCode = settings.dupFreq*(1/763)*settings.transferCoef;%������ź�Դ�����ϵĶ����գ���������NCO��
%setting.fd_code = setting.dup_freq*settings.cofe_FLL_auxi_DDLL*setting.transfer_coef;%������ź�Դ�����ϵĶ����գ���������NCO��


settings.eCodeOriginalPhase = 0;         %nco��Ƶ������ĳ���λ
settings.modulateCodeBiasPhsae = 0;      %����ʱ������B1��ĳ���λ
settings.signalPhase = 0;
settings.localPhase = 0;
