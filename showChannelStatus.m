function showChannelStatus(channel, settings)
%Prints the status of all channels in a table.
%打印表中的所有通道的状态。
%showChannelStatus(channel, settings)
%
%   Inputs:
%       channel     - data for each channel. It is used to initialize and
%                   at the processing of the signal (tracking part).

%       settings    - receiver settings
%   输入：
%       channel     -每个通道的数据。它是用来初始化和信号处理的（跟踪的一部分）。
%       settings    - 接收器设置
%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Peter Rinder and Nicolaj Bertelsen
% Written by Peter Rinder Nicolaj Bertelsen and Darius Plausinaitis
% Based on Peter Rinder and Nicolaj Bertelsen
% 版权所有（C）Peter Rinder and Nicolaj Bertelsen
% 作者是Peter Rinder Nicolaj Bertelsen and Darius Plausinaitis
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
% 这程序是个免费的软件：你可以对它进行重新分配和/或者在由免费软件基金会出版的
% GNU通用公共许可证的条款的允许下对其进行修改；许可证版本2或者（由你选择）任何
% 随后的版本。

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
% 您应该已经收到随着这一程序的GNU通用公共许可证的副本；如果没有，
%  请写信给自由软件基金会股份有限公司，地址是美国，MA02110-1301，
%  波士顿，富兰克林街51号五楼。 
%--------------------------------------------------------------------------

%CVS record:
%$Id: showChannelStatus.m,v 1.4.2.8 2006/08/14 11:38:22 dpl Exp $


fprintf('\n*=========*=====*===============*===========*=============*========*\n');
fprintf(  '|PRN |   Frequency   |  Doppler  | Code Offset | Status |\n');
fprintf(  '*=========*=====*===============*===========*=============*========*\n');

    if (channel.status ~= '-')
        fprintf('|   %3d |  %2.5e |   %5.0f   |    %6d   |     %1s  |\n', ...
                channel.PRN, ...
                channel.acquiredFreq, ...
                channel.acquiredFreq -  settings.IF, ...
                channel.codePhase, ...
                channel.status);
    else
        fprintf('  channel Off  |\n');
    end


fprintf('*=========*=====*===============*===========*=============*========*\n\n');
