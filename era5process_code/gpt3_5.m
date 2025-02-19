 function [p,T,dT,Tm,e,ah,aw,la,undu,Gn_h,Ge_h,Gn_w,Ge_w] = gpt3_5 (grd_path,mjd,lat,lon,h_ell,it)

% gpt3_5.m
%
% (c) Department of Geodesy and Geoinformation, Vienna University of
% Technology, 2017
%
%
% This subroutine determines pressure, temperature, temperature lapse rate, 
% mean temperature of the water vapor, water vapour pressure, hydrostatic 
% and wet mapping function coefficients ah and aw, water vapour decrease
% factor, geoid undulation and empirical tropospheric gradients for 
% specific sites near the earth's surface.
% It is based on a 5 x 5 degree external grid file ('gpt3_5.grd') with mean
% values as well as sine and cosine amplitudes for the annual and
% semiannual variation of the coefficients.
% As the .grd file is opened anew every time this function is called, the
% process is fairly time-consuming for a longer set of mjd's. For 
% improved calculation performance, see gpt3_5_fast.m.
%
%
% Reference:
% D. Landskron, J. B枚hm (2018), VMF3/GPT3: Refined Discrete and Empirical Troposphere Mapping Functions, 
% J Geod (2018) 92: 349., doi: 10.1007/s00190-017-1066-2. 
% Download at: https://link.springer.com/content/pdf/10.1007%2Fs00190-017-1066-2.pdf
%
%
% input parameters:
% 
% mjd:   modified Julian date (scalar, only one epoch per call is
% possible)儒略日期
% lat:   ellipsoidal latitude in radians [-pi/2:+pi/2] (vector)
% lon:   longitude in radians [-pi:pi] or [0:2pi] (vector)
% h_ell: ellipsoidal height in m (vector)
% it:    case 1: no time variation but static quantities
%        case 0: with time variation (annual and semiannual terms)
% 
% output parameters:
%
% p:    pressure in hPa (vector) 
% T:    temperature in degrees Celsius (vector)
% dT:   temperature lapse rate in degrees per km (vector)
% Tm:   mean temperature weighted with the water vapor in degrees Kelvin (vector) 
% e:    water vapour pressure in hPa (vector)
% ah:   hydrostatic mapping function coefficient at zero height (VMF1) (vector)
% aw:   wet mapping function coefficient (VMF1) (vector)
% la:   water vapour decrease factor (vector)
% undu: geoid undulation in m (vector)
% Gn_h: hydrostatic north gradient in m (vector)
% Ge_h: hydrostatic east gradient in m (vector)
% Gn_w: wet north gradient in m (vector)
% Ge_w: wet east gradient in m (vector)
%
%
% The hydrostatic mapping function coefficients have to be used with the
% height dependent Vienna Mapping Function 3 (vmf3_ht.m) because the
% coefficients refer to zero height.
%

% otherwise must correct to zero height(the coast high) .


% File created by Daniel Landskron, 2016/04/27
% 
% =========================================================================



% read .grd-file
fid = fopen(grd_path,'r');
C = textscan( fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines', 1 , 'CollectOutput', true );
C = C{1};
fclose (fid);


%CollectOput---合并输出

p_grid    = C(:,3:7);          % pressure in Pascal---气压
T_grid    = C(:,8:12);         % temperature in Kelvin---温度
Q_grid    = C(:,13:17)/1000;   % specific humidity in kg/kg---比湿
dT_grid   = C(:,18:22)/1000;   % temperature lapse rate in Kelvin/m---温度递减率
u_grid    = C(:,23);           % geoid undulation in m---大地水准面波动
Hs_grid   = C(:,24);           % orthometric grid height in m---正交点格网高度
ah_grid   = C(:,25:29)/1000;   % hydrostatic mapping function coefficient, dimensionless---无量纲的干映射函数系数
aw_grid   = C(:,30:34)/1000;   % wet mapping function coefficient, dimensionless---无量纲的湿映射函数系数
la_grid   = C(:,35:39);     	  % water vapor decrease factor, dimensionless---水汽递减因子
Tm_grid   = C(:,40:44);        % mean temperature in Kelvin---水汽压加权平均温度
Gn_h_grid = C(:,45:49)/100000;    % hydrostatic north gradient in m
Ge_h_grid = C(:,50:54)/100000;    % hydrostatic east gradient in m
Gn_w_grid = C(:,55:59)/100000;    % wet north gradient in m
Ge_w_grid = C(:,60:64)/100000;    % wet east gradient in m


% convert mjd to doy
hour = floor((mjd-floor(mjd))*24);   % get hours
minu = floor((((mjd-floor(mjd))*24)-hour)*60);   % get minutes
sec = (((((mjd-floor(mjd))*24)-hour)*60)-minu)*60;   % get seconds


%floor（x）---Orient down不超过x的最大整数---往负无穷方向取整


% change secs, min hour whose sec==60
minu(sec==60) = minu(sec==60)+1;
sec(sec==60) = 0;
hour(minu==60) = hour(minu==60)+1;
minu(minu==60)=0;

% calc jd (yet wrong for hour==24)
jd = mjd+2400000.5;

% if hr==24, correct jd and set hour==0
jd(hour==24)=jd(hour==24)+1;
hour(hour==24)=0;

% integer julian date
jd_int = floor(jd+0.5);

aa = jd_int+32044;
bb = floor((4*aa+3)/146097);
cc = aa-floor((bb*146097)/4);
dd = floor((4*cc+3)/1461);
ee = cc-floor((1461*dd)/4);
mm = floor((5*ee+2)/153);

day = ee-floor((153*mm+2)/5)+1;
month = mm+3-12*floor(mm/10);
year = bb*100+dd-4800+floor(mm/10);



% first check if the specified year is leap year or not (logical output) 
leapYear = ((mod(year,4) == 0 & mod(year,100) ~= 0) | mod(year,400) == 0);

%mod---Remainder after division (modulo operation)

days = [31 28 31 30 31 30 31 31 30 31 30 31];
doy = sum(days(1:month-1)) + day;
if leapYear == 1 && month > 2
    doy = doy + 1;
end
doy = doy + mjd-floor(mjd);   % add decimal places


%The leapYear of second month is 29 days   

%turning time end





% determine the GPT3 coefficients

% mean gravity in m/s**2
gm = 9.80665;
% molar mass of dry air in kg/mol
dMtr = 28.965*10^-3;
% universal gas constant in J/K/mol
Rg = 8.3143;

% factors for amplitudes
if (it==1) % then  constant parameters
    cosfy = 0;
    coshy = 0;
    sinfy = 0;
    sinhy = 0;
else 
    cosfy = cos(doy/365.25*2*pi);   % coefficient for A1
    coshy = cos(doy/365.25*4*pi);   % coefficient for B1
    sinfy = sin(doy/365.25*2*pi);   % coefficient for A2
    sinhy = sin(doy/365.25*4*pi);   % coefficient for B2
end

% determine the number of stations
nstat = length(lat);

% initialization
p    = zeros([nstat , 1]);
T    = zeros([nstat , 1]);
dT   = zeros([nstat , 1]);
Tm   = zeros([nstat , 1]);
e    = zeros([nstat , 1]);
ah   = zeros([nstat , 1]);
aw   = zeros([nstat , 1]);
la   = zeros([nstat , 1]);
undu = zeros([nstat , 1]);
Gn_h = zeros([nstat , 1]);
Ge_h = zeros([nstat , 1]);
Gn_w = zeros([nstat , 1]);
Ge_w = zeros([nstat , 1]);


% loop over stations
for k = 1:nstat
    
    % only positive longitude in degrees
    if lon(k) < 0
        plon = (lon(k) + 2*pi)*180/pi;
    else
        plon = lon(k)*180/pi;
    end
    % transform to polar distance in degrees
    ppod = (-lat(k) + pi/2)*180/pi; 

    % find the index (line in the grid file) of the nearest point
    ipod = floor((ppod+5)/5); 
    ilon = floor((plon+5)/5);
    
    
    %ipd\ilon---位于待求点正方向的点
    
    
    % normalized (to one) differences, can be positive or negative
    diffpod = (ppod - (ipod*5 - 2.5))/5;
    difflon = (plon - (ilon*5 - 2.5))/5;
    
   %距离各网点1/2 处的距离
    
    if ipod == 37
        ipod = 36;
    end
    if ilon == 73
		ilon = 1;
    end
    if ilon == 0
        ilon = 72;
    end

    % get the number of the corresponding line
    indx(1) = (ipod - 1)*72 + ilon;
    
    % near the poles: nearest neighbour interpolation, otherwise:bilinear
    % 靠近极点最近邻，否则双线性
    
    
    bilinear = 0;
    if ppod > 2.5 && ppod < 177.5 
           bilinear = 1;          
    end          
    
    % case of nearest neighbourhood
    if bilinear == 0

        ix = indx(1);
        
        % transforming ellipsoidial height to orthometric height
        undu(k) = u_grid(ix);
        hgt = h_ell(k)-undu(k);
         
        %去除大地水准面波动
        
        
        % pressure, temperature at the heigtht of the grid
        T0 = T_grid(ix,1) + T_grid(ix,2)*cosfy + T_grid(ix,3)*sinfy + T_grid(ix,4)*coshy + T_grid(ix,5)*sinhy;
        p0 = p_grid(ix,1) + p_grid(ix,2)*cosfy + p_grid(ix,3)*sinfy + p_grid(ix,4)*coshy + p_grid(ix,5)*sinhy;
         
        % specific humidity
        Q = Q_grid(ix,1) + Q_grid(ix,2)*cosfy + Q_grid(ix,3)*sinfy + Q_grid(ix,4)*coshy + Q_grid(ix,5)*sinhy;
            
        % lapse rate of the temperature
        dT(k) = dT_grid(ix,1) + dT_grid(ix,2)*cosfy + dT_grid(ix,3)*sinfy + dT_grid(ix,4)*coshy + dT_grid(ix,5)*sinhy; 

        % station height - grid height
        redh = hgt - Hs_grid(ix);

        % temperature at station height in Celsius
        T(k) = T0 + dT(k)*redh - 273.15;
        
        % temperature lapse rate in degrees / km
        dT(k) = dT(k)*1000;

        % virtual temperature in Kelvin
        Tv = T0*(1+0.6077*Q);
        
        c = gm*dMtr/(Rg*Tv);
        
        % pressure in hPa
        p(k) = (p0*exp(-c*redh))/100;
            
        % hydrostatic and wet coefficients ah and aw 
        ah(k) = ah_grid(ix,1) + ah_grid(ix,2)*cosfy + ah_grid(ix,3)*sinfy + ah_grid(ix,4)*coshy + ah_grid(ix,5)*sinhy;
        aw(k) = aw_grid(ix,1) + aw_grid(ix,2)*cosfy + aw_grid(ix,3)*sinfy + aw_grid(ix,4)*coshy + aw_grid(ix,5)*sinhy;
		
		% water vapour decrease factor la
        la(k) = la_grid(ix,1) + ...
                la_grid(ix,2)*cosfy + la_grid(ix,3)*sinfy + ...
                la_grid(ix,4)*coshy + la_grid(ix,5)*sinhy; 
		
		% mean temperature of the water vapor Tm
        Tm(k) = Tm_grid(ix,1) + ...
                Tm_grid(ix,2)*cosfy + Tm_grid(ix,3)*sinfy + ...
                Tm_grid(ix,4)*coshy + Tm_grid(ix,5)*sinhy;
            
        % north and east gradients (total, hydrostatic and wet)
        Gn_h(k) = Gn_h_grid(ix,1) + Gn_h_grid(ix,2)*cosfy + Gn_h_grid(ix,3)*sinfy + Gn_h_grid(ix,4)*coshy + Gn_h_grid(ix,5)*sinhy;
        Ge_h(k) = Ge_h_grid(ix,1) + Ge_h_grid(ix,2)*cosfy + Ge_h_grid(ix,3)*sinfy + Ge_h_grid(ix,4)*coshy + Ge_h_grid(ix,5)*sinhy;
        Gn_w(k) = Gn_w_grid(ix,1) + Gn_w_grid(ix,2)*cosfy + Gn_w_grid(ix,3)*sinfy + Gn_w_grid(ix,4)*coshy + Gn_w_grid(ix,5)*sinhy;
        Ge_w(k) = Ge_w_grid(ix,1) + Ge_w_grid(ix,2)*cosfy + Ge_w_grid(ix,3)*sinfy + Ge_w_grid(ix,4)*coshy + Ge_w_grid(ix,5)*sinhy;
		
		% water vapor pressure in hPa
		e0 = Q*p0/(0.622+0.378*Q)/100; % on the grid
		e(k) = e0*(100*p(k)/p0)^(la(k)+1);   % on the station height - (14) Askne and Nordius, 1987
		
     else % bilinear interpolation
        
        ipod1 = ipod + sign(diffpod);
        ilon1 = ilon + sign(difflon);
        
        %重新判断待求点周围的格网点
        
        if ilon1 == 73
            ilon1 = 1;
        end
        if ilon1 == 0
            ilon1 = 72;
        end
        
        % get the number of the line
        indx(2) = (ipod1 - 1)*72 + ilon;  % along same longitude
        indx(3) = (ipod  - 1)*72 + ilon1; % along same polar distance
        indx(4) = (ipod1 - 1)*72 + ilon1; % diagonal
                
        % transforming ellipsoidial height to orthometric height: Hortho = -N + Hell
        undul = u_grid(indx);
        hgt = h_ell(k)-undul;
        
        % pressure, temperature at the heigtht of the grid
        T0 = T_grid(indx,1) + T_grid(indx,2)*cosfy + T_grid(indx,3)*sinfy + T_grid(indx,4)*coshy + T_grid(indx,5)*sinhy;
        p0 = p_grid(indx,1) + p_grid(indx,2)*cosfy + p_grid(indx,3)*sinfy + p_grid(indx,4)*coshy + p_grid(indx,5)*sinhy;
        
        % humidity
        Ql = Q_grid(indx,1) + Q_grid(indx,2)*cosfy + Q_grid(indx,3)*sinfy + Q_grid(indx,4)*coshy + Q_grid(indx,5)*sinhy;
        
        % reduction = stationheight - gridheight
        Hs1 = Hs_grid(indx);
        redh = hgt - Hs1;
        
        % lapse rate of the temperature in degree / m
        dTl = dT_grid(indx,1) + dT_grid(indx,2)*cosfy + dT_grid(indx,3)*sinfy + dT_grid(indx,4)*coshy + dT_grid(indx,5)*sinhy;
        
        % temperature reduction to station height
        Tl = T0 + dTl.*redh - 273.15;
        
        % virtual temperature
        Tv = T0.*(1+0.6077*Ql);
        c = gm*dMtr./(Rg*Tv);
        
        % pressure in hPa
        pl = (p0.*exp(-c.*redh))/100;
        
        % hydrostatic and wet coefficients ah and aw
        ahl = ah_grid(indx,1) + ah_grid(indx,2)*cosfy + ah_grid(indx,3)*sinfy + ah_grid(indx,4)*coshy + ah_grid(indx,5)*sinhy;
        awl = aw_grid(indx,1) + aw_grid(indx,2)*cosfy + aw_grid(indx,3)*sinfy + aw_grid(indx,4)*coshy + aw_grid(indx,5)*sinhy;
        
        % water vapour decrease factor la
        lal = la_grid(indx,1) + la_grid(indx,2)*cosfy + la_grid(indx,3)*sinfy + la_grid(indx,4)*coshy + la_grid(indx,5)*sinhy;
        
        % mean temperature of the water vapor Tm
        Tml = Tm_grid(indx,1) + Tm_grid(indx,2)*cosfy + Tm_grid(indx,3)*sinfy + Tm_grid(indx,4)*coshy + Tm_grid(indx,5)*sinhy;
        
        % north and east gradients (total, hydrostatic and wet)
        Gn_hl = Gn_h_grid(indx,1) + Gn_h_grid(indx,2)*cosfy + Gn_h_grid(indx,3)*sinfy + Gn_h_grid(indx,4)*coshy + Gn_h_grid(indx,5)*sinhy;
        Ge_hl = Ge_h_grid(indx,1) + Ge_h_grid(indx,2)*cosfy + Ge_h_grid(indx,3)*sinfy + Ge_h_grid(indx,4)*coshy + Ge_h_grid(indx,5)*sinhy;
        Gn_wl = Gn_w_grid(indx,1) + Gn_w_grid(indx,2)*cosfy + Gn_w_grid(indx,3)*sinfy + Gn_w_grid(indx,4)*coshy + Gn_w_grid(indx,5)*sinhy;
        Ge_wl = Ge_w_grid(indx,1) + Ge_w_grid(indx,2)*cosfy + Ge_w_grid(indx,3)*sinfy + Ge_w_grid(indx,4)*coshy + Ge_w_grid(indx,5)*sinhy;
        
        % water vapor pressure in hPa
        e0 = Ql.*p0./(0.622+0.378*Ql)/100; % on the grid
        el = e0.*(100.*pl./p0).^(lal+1);  % on the station height - (14) Askne and Nordius, 1987
			
            
        dnpod1 = abs(diffpod); % distance nearer point----abs(absolut value)
        dnpod2 = 1 - dnpod1;   % distance to distant point
        dnlon1 = abs(difflon);
        dnlon2 = 1 - dnlon1;
        
        %双线性内插最近四个点对其的综合影响
        
        
        % pressure
        R1 = dnpod2*pl(1)+dnpod1*pl(2);
        R2 = dnpod2*pl(3)+dnpod1*pl(4);
        p(k) = dnlon2*R1+dnlon1*R2;
            
        % temperature
        R1 = dnpod2*Tl(1)+dnpod1*Tl(2);
        R2 = dnpod2*Tl(3)+dnpod1*Tl(4);
        T(k) = dnlon2*R1+dnlon1*R2;
        
        % temperature in degree per km
        R1 = dnpod2*dTl(1)+dnpod1*dTl(2);
        R2 = dnpod2*dTl(3)+dnpod1*dTl(4);
        dT(k) = (dnlon2*R1+dnlon1*R2)*1000;
            
        % water vapor pressure in hPa
		R1 = dnpod2*el(1)+dnpod1*el(2);
        R2 = dnpod2*el(3)+dnpod1*el(4);
        e(k) = dnlon2*R1+dnlon1*R2;
            
        % ah and aw
        R1 = dnpod2*ahl(1)+dnpod1*ahl(2);
        R2 = dnpod2*ahl(3)+dnpod1*ahl(4);
        ah(k) = dnlon2*R1+dnlon1*R2;
        R1 = dnpod2*awl(1)+dnpod1*awl(2);
        R2 = dnpod2*awl(3)+dnpod1*awl(4);
        aw(k) = dnlon2*R1+dnlon1*R2;
        
        % undulation
        R1 = dnpod2*undul(1)+dnpod1*undul(2);
        R2 = dnpod2*undul(3)+dnpod1*undul(4);
        undu(k) = dnlon2*R1+dnlon1*R2;
		
		% water vapour decrease factor
        R1 = dnpod2*lal(1)+dnpod1*lal(2);
        R2 = dnpod2*lal(3)+dnpod1*lal(4);
        la(k) = dnlon2*R1+dnlon1*R2;
        
        % gradients
        R1 = dnpod2*Gn_hl(1)+dnpod1*Gn_hl(2);
        R2 = dnpod2*Gn_hl(3)+dnpod1*Gn_hl(4);
        Gn_h(k) = (dnlon2*R1 + dnlon1*R2);
        R1 = dnpod2*Ge_hl(1)+dnpod1*Ge_hl(2);
        R2 = dnpod2*Ge_hl(3)+dnpod1*Ge_hl(4);
        Ge_h(k) = (dnlon2*R1 + dnlon1*R2);
        R1 = dnpod2*Gn_wl(1)+dnpod1*Gn_wl(2);
        R2 = dnpod2*Gn_wl(3)+dnpod1*Gn_wl(4);
        Gn_w(k) = (dnlon2*R1 + dnlon1*R2);
        R1 = dnpod2*Ge_wl(1)+dnpod1*Ge_wl(2);
        R2 = dnpod2*Ge_wl(3)+dnpod1*Ge_wl(4);
        Ge_w(k) = (dnlon2*R1 + dnlon1*R2);
		
		% mean temperature of the water vapor Tm
        R1 = dnpod2*Tml(1)+dnpod1*Tml(2);
        R2 = dnpod2*Tml(3)+dnpod1*Tml(4);
        Tm(k) = dnlon2*R1+dnlon1*R2;
                    
    end 
end

  
