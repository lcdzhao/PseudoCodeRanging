function [receivedL1,receivedL2]=separateSignal(data,SampleFre)
%使用滤波器分开这两个信号
%低通滤波器
fp = 10e6;
fs = 11e6;
wp=fp/(SampleFre/2);ws=fs/(SampleFre/2);
[N,wc]=buttord(wp,ws,1,30);%计算率波器的阶数和3dB截止频率
[B,A]=butter(N,wc);%计算滤波器系统函数分子分母多项式
receivedL1 = filter(B,A,data);

%高通滤波器
fp = 14e6;
fs = 15e6;
wp=fp/(SampleFre/2);ws=fs/(SampleFre/2);
[N,wc]=buttord(wp,ws,1,30);%计算率波器的阶数和3dB截止频率
[B,A]=butter(N,wc,'high');%计算滤波器系统函数分子分母多项式
receivedL2 = filter(B,A,data);
