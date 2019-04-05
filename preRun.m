function [channel] = preRun(acqResults, settings)
%Function initializes tracking channels from acquisition data. The acquired
%signals are sorted according to the signal strength. This function can be
%modified to use other satellite selection algorithms or to introduce
%acquired signal properties offsets for testing purposes.
%
%函数根据采集到的数据初始化跟踪通道；获得的信号被依据信号强度进行分类。可以通过调
%整这个函数来应用其他卫星选择算法或者引进采集到的用于测试目的信号属性偏移；
%[channel] = preRun(acqResults, settings)
%
%   Inputs:
%       acqResults  - results from acquisition.
%       settings    - receiver settings
%   输入：
%       acqResults  - 采集的结果
%       settings    - 接收器的设置
%   Outputs:
%       channel     - structure contains information for each channel (like
%                   properties of the tracked signal, channel status etc.).
%   输出：
%       channel     - 结构包含每个通道的信息（例如跟踪信号，通道状态等属性）

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis
% Written by Darius Plausinaitis
% Based on Peter Rinder and Nicolaj Bertelsen
% 版权所有（C）Darius Plausinaitis 
% 作者是Darius Plausinaitis
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%  这个程序是个免费的软件；你可以对它进行重新的分配，和/或者在
%  由免费软件基金会出版的GNU通用公共许可证的条款的允许下对其进行修改。
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%  这个程序的发布是希望它能够有用，但并不能完全保证；甚至没有商业性和
%  其他任何目的性的担保。有关详细信息，请阅读GNU通用公共许可证。

%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------
%  您应该已经收到随着这一程序的GNU通用公共许可证的副本；如果没有，
%  请写信给自由软件基金会股份有限公司，地址是美国，MA02110-1301，
%  波士顿，富兰克林街51号五楼。
%CVS record:
%$Id: preRun.m,v 1.8.2.20 2006/08/14 11:38:22 dpl Exp $

%% Initialize all channels ================================================
%% 初始化所有通道
channel                 = [];   % Clear, create the structure
                                % 清除，创建结构

channel.PRN             = 0;    % PRN number of the tracked satellite
                                % 跟踪卫星的PRN数据
channel.acquiredFreq    = 0;    % Used as the center frequency of the NCO
                                % 作为中心频率的“噪音管制条例”
channel.codePhase       = 0;    % Position of the C/A  start
                                % C/A的开始位置
channel.status          = '-';  % Mode/status of the tracking channel
                                % "-" - "off" - no signal to track
                                % "T" - Tracking state
                                % 跟踪通道的模式/状态
                                % "-"-"off"-没有跟踪信号
                                % "T"-跟踪状态
%--- Copy initial data to all channels -----------------------------------
%--- 把初始化数据复制到所有通道 -----------------------------------------
channel = repmat(channel, 1, settings.numberOfChannels);

%% Copy acquisition results ===============================================
%% 复制采集结果 ==================================================

%--- Sort peaks to find strongest signals, keep the peak index information
%--- 将峰值排序找到最强信号，保持峰值的索引信息
[junk, PRNindexes]          = sort(acqResults.peakMetric, 2, 'descend');

%--- Load information about each satellite --------------------------------
%--- 载入每颗卫星的信息
% Maximum number of initialized channels is number of detected signals, but
% not more as the number of channels specified in the settings.
% 初始化通道的最大数量是检测到的信号数量，但是不能再多于指定的设置的信道的数量
for ii = 1:min([settings.numberOfChannels, sum(acqResults.carrFreq > 0)])
    channel(ii).PRN          = PRNindexes(ii);
    channel(ii).acquiredFreq = acqResults.carrFreq(PRNindexes(ii));
    channel(ii).codePhase    = acqResults.codePhase(PRNindexes(ii));
    
    % Set tracking into mode (there can be more modes if needed e.g. pull-in)
    % 设置成模式跟踪（）
    channel(ii).status       = 'T';
end
