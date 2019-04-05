function settings = initSettings()
%Functions initializes and saves settings. Settings can be edited inside of
%the function, updated from the command line or updated using a dedicated
%GUI - "setSettings".  
%
%All settings are described inside function code.
%
%settings = initSettings()
%
%   Inputs: none
%
%   Outputs:
%       settings     - Receiver settings (a structure). ���ջ����ã��ṹ�壩

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis
% Written by Darius Plausinaitis
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------

% CVS record:
% $Id: initSettings.m,v 1.9.2.31 2006/08/18 11:41:57 dpl Exp $

%% Processing settings ====================================================
% Number of milliseconds to be processed used 36000 + any transients (see
% below - in Nav parameters) to ensure nav subframes are provided
%
settings.msToProcess        = 1000;        %[ms]��Ҫ����ĺ�����

% Number of channels to be used for signal processing
settings.numberOfChannels   = 1;    %ͨ�����������Ǹ�����

% Move the starting point of processing. Can be used to start the signal
% processing at any point in the data record (e.g. for long records). fseek
% function is used to move the file read point, therefore advance is byte
% based only. 
%�ƶ����ݴ���Ŀ�ʼ�㡣�������ݼ�¼�е��κ�һ�㿪ʼ�źŴ���
%fseek�����ƶ��ļ��Ķ�ȡ��
settings.skipNumberOfBytes     = 0;  %�������ֽ���

%% Raw signal file name and other parameter ========ԭʼ�ź��ļ�������������=======================
% This is a "default" name of the data file (signal record) to be used in
% the post-processing mode

% Data type used to store one sample
settings.dataType           = 'int8';   %�洢һ����������������

% Intermediate, sampling and code frequencies
settings.IF                 = 9.548e6; %1.42e6 %4.123968e6;      %[Hz]   %��Ƶ
settings.samplingFreq       = 38.192e6; %5.714e6 %16.367667e6;     %[Hz] %����Ƶ�ʱ�
settings.codeFreqBasis      = 1.023e6;      %[Hz]   %��Ԫ�Ļ�Ƶ



% Define number of chips in a code period
settings.codeLength         = 1023;     %һ����Ԫ���ڵġ�Ƭ����

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
settings.CA_Period          = (1/settings.codeFreqBasis)*settings.codeLength;  % ÿ��CA�������
%% Tracking loops settings =============���ٻ�·����===================================
% Code tracking loop parameters     ����ٻ�·����
settings.dllDampingRatio         = 0.7;
settings.dllNoiseBandwidth       = 2;       %[Hz]
settings.dllCorrelatorSpacing    = 0.5;     %[chips]

% Carrier tracking loop parameters  �ز����ٻ�����
settings.pllDampingRatio         = 0.7;
settings.pllNoiseBandwidth       = 25;      %[Hz]

% Period for calculating pseudoranges and position
settings.navSolPeriod       = 500;          %[ms]

%% Plot settings ==========================================================
% Enable/disable plotting of the tracking results for each channel
settings.plotTracking       = 1;            % 0 - Off
                                            % 1 - On

                                            
%% Constants ==============================================================

settings.c                  = 299792458;    % The speed of light, [m/s]
settings.startOffset        = 0;       %[ms] Initial sign. travel time
