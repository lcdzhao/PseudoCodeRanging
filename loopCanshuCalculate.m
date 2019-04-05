function loopCanshu = loopCanshuCalculate (settings)
WnF = 1.89 * settings.FLLBandwidth;%��Ƶ��·����ȻƵ��
WnP = 1.27 * settings.PLLBandwidth; %���໷·����ȻƵ��
WnD = 1.89 * settings.DDLLBandwidth; %�뻷��·�˲�������Ȼ��Ƶ��

Tcoh = settings.Tcoh;%��·����ʱ��
K = settings.K;
carrierK=0.25;
loopCanshu.cofeone_FLL = (sqrt(2)*WnF*Tcoh+WnF^2*Tcoh^2)/carrierK;
loopCanshu.cofetwo_FLL = -(sqrt(2)*WnF*Tcoh)/carrierK;
loopCanshu.cofeone_PLL = (2*WnP+2*WnP^2*Tcoh+WnP^3*Tcoh^2)/carrierK;
loopCanshu.cofetwo_PLL = -(4*WnP+2*WnP^2*Tcoh)/carrierK;
loopCanshu.cofethree_PLL = 2*WnP/carrierK;
loopCanshu.cofeone_DDLL = (sqrt(2)*WnD+WnD^2*Tcoh)/K;
loopCanshu.cofetwo_DDLL = -sqrt(2)*WnD/K;