function [receivedL1,receivedL2]=separateSignal(data,SampleFre)
%ʹ���˲����ֿ��������ź�
%��ͨ�˲���
fp = 10e6;
fs = 11e6;
wp=fp/(SampleFre/2);ws=fs/(SampleFre/2);
[N,wc]=buttord(wp,ws,1,30);%�����ʲ����Ľ�����3dB��ֹƵ��
[B,A]=butter(N,wc);%�����˲���ϵͳ�������ӷ�ĸ����ʽ
receivedL1 = filter(B,A,data);

%��ͨ�˲���
fp = 14e6;
fs = 15e6;
wp=fp/(SampleFre/2);ws=fs/(SampleFre/2);
[N,wc]=buttord(wp,ws,1,30);%�����ʲ����Ľ�����3dB��ֹƵ��
[B,A]=butter(N,wc,'high');%�����˲���ϵͳ�������ӷ�ĸ����ʽ
receivedL2 = filter(B,A,data);
