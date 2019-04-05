function loopCanshu = loopCanshuCalculate (settings)
WnF = 1.89 * settings.FLLBandwidth;%锁频环路的自然频率
WnP = 1.27 * settings.PLLBandwidth; %锁相环路的自然频率
WnD = 1.89 * settings.DDLLBandwidth; %码环环路滤波器的自然角频率

Tcoh = settings.Tcoh;%环路积分时间
K = settings.K;
carrierK=0.25;
loopCanshu.cofeone_FLL = (sqrt(2)*WnF*Tcoh+WnF^2*Tcoh^2)/carrierK;
loopCanshu.cofetwo_FLL = -(sqrt(2)*WnF*Tcoh)/carrierK;
loopCanshu.cofeone_PLL = (2*WnP+2*WnP^2*Tcoh+WnP^3*Tcoh^2)/carrierK;
loopCanshu.cofetwo_PLL = -(4*WnP+2*WnP^2*Tcoh)/carrierK;
loopCanshu.cofethree_PLL = 2*WnP/carrierK;
loopCanshu.cofeone_DDLL = (sqrt(2)*WnD+WnD^2*Tcoh)/K;
loopCanshu.cofetwo_DDLL = -sqrt(2)*WnD/K;