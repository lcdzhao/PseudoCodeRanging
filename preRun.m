function [channel] = preRun(acqResults, settings)
%Function initializes tracking channels from acquisition data. The acquired
%signals are sorted according to the signal strength. This function can be
%modified to use other satellite selection algorithms or to introduce
%acquired signal properties offsets for testing purposes.
%
%�������ݲɼ��������ݳ�ʼ������ͨ������õ��źű������ź�ǿ�Ƚ��з��ࡣ����ͨ����
%�����������Ӧ����������ѡ���㷨���������ɼ��������ڲ���Ŀ���ź�����ƫ�ƣ�
%[channel] = preRun(acqResults, settings)
%
%   Inputs:
%       acqResults  - results from acquisition.
%       settings    - receiver settings
%   ���룺
%       acqResults  - �ɼ��Ľ��
%       settings    - ������������
%   Outputs:
%       channel     - structure contains information for each channel (like
%                   properties of the tracked signal, channel status etc.).
%   �����
%       channel     - �ṹ����ÿ��ͨ������Ϣ����������źţ�ͨ��״̬�����ԣ�

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis
% Written by Darius Plausinaitis
% Based on Peter Rinder and Nicolaj Bertelsen
% ��Ȩ���У�C��Darius Plausinaitis 
% ������Darius Plausinaitis
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%  ��������Ǹ���ѵ����������Զ����������µķ��䣬��/������
%  �����������������GNUͨ�ù������֤������������¶�������޸ġ�
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%  �������ķ�����ϣ�����ܹ����ã�����������ȫ��֤������û����ҵ�Ժ�
%  �����κ�Ŀ���Եĵ������й���ϸ��Ϣ�����Ķ�GNUͨ�ù������֤��

%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------
%  ��Ӧ���Ѿ��յ�������һ�����GNUͨ�ù������֤�ĸ��������û�У�
%  ��д�Ÿ�������������ɷ����޹�˾����ַ��������MA02110-1301��
%  ��ʿ�٣��������ֽ�51����¥��
%CVS record:
%$Id: preRun.m,v 1.8.2.20 2006/08/14 11:38:22 dpl Exp $

%% Initialize all channels ================================================
%% ��ʼ������ͨ��
channel                 = [];   % Clear, create the structure
                                % ����������ṹ

channel.PRN             = 0;    % PRN number of the tracked satellite
                                % �������ǵ�PRN����
channel.acquiredFreq    = 0;    % Used as the center frequency of the NCO
                                % ��Ϊ����Ƶ�ʵġ���������������
channel.codePhase       = 0;    % Position of the C/A  start
                                % C/A�Ŀ�ʼλ��
channel.status          = '-';  % Mode/status of the tracking channel
                                % "-" - "off" - no signal to track
                                % "T" - Tracking state
                                % ����ͨ����ģʽ/״̬
                                % "-"-"off"-û�и����ź�
                                % "T"-����״̬
%--- Copy initial data to all channels -----------------------------------
%--- �ѳ�ʼ�����ݸ��Ƶ�����ͨ�� -----------------------------------------
channel = repmat(channel, 1, settings.numberOfChannels);

%% Copy acquisition results ===============================================
%% ���Ʋɼ���� ==================================================

%--- Sort peaks to find strongest signals, keep the peak index information
%--- ����ֵ�����ҵ���ǿ�źţ����ַ�ֵ��������Ϣ
[junk, PRNindexes]          = sort(acqResults.peakMetric, 2, 'descend');

%--- Load information about each satellite --------------------------------
%--- ����ÿ�����ǵ���Ϣ
% Maximum number of initialized channels is number of detected signals, but
% not more as the number of channels specified in the settings.
% ��ʼ��ͨ������������Ǽ�⵽���ź����������ǲ����ٶ���ָ�������õ��ŵ�������
for ii = 1:min([settings.numberOfChannels, sum(acqResults.carrFreq > 0)])
    channel(ii).PRN          = PRNindexes(ii);
    channel(ii).acquiredFreq = acqResults.carrFreq(PRNindexes(ii));
    channel(ii).codePhase    = acqResults.codePhase(PRNindexes(ii));
    
    % Set tracking into mode (there can be more modes if needed e.g. pull-in)
    % ���ó�ģʽ���٣���
    channel(ii).status       = 'T';
end
