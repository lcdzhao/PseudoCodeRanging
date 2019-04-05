function showChannelStatus(channel, settings)
%Prints the status of all channels in a table.
%��ӡ���е�����ͨ����״̬��
%showChannelStatus(channel, settings)
%
%   Inputs:
%       channel     - data for each channel. It is used to initialize and
%                   at the processing of the signal (tracking part).

%       settings    - receiver settings
%   ���룺
%       channel     -ÿ��ͨ�������ݡ�����������ʼ�����źŴ���ģ����ٵ�һ���֣���
%       settings    - ����������
%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Peter Rinder and Nicolaj Bertelsen
% Written by Peter Rinder Nicolaj Bertelsen and Darius Plausinaitis
% Based on Peter Rinder and Nicolaj Bertelsen
% ��Ȩ���У�C��Peter Rinder and Nicolaj Bertelsen
% ������Peter Rinder Nicolaj Bertelsen and Darius Plausinaitis
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
% ������Ǹ���ѵ����������Զ����������·����/�����������������������
% GNUͨ�ù������֤������������¶�������޸ģ����֤�汾2���ߣ�����ѡ���κ�
% ���İ汾��

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
% ��Ӧ���Ѿ��յ�������һ�����GNUͨ�ù������֤�ĸ��������û�У�
%  ��д�Ÿ�������������ɷ����޹�˾����ַ��������MA02110-1301��
%  ��ʿ�٣��������ֽ�51����¥�� 
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
