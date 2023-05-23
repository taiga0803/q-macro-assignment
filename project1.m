clc
clear all
close all

f = fred
startdate = '01/01/199';
enddate = '01/01/2022';

JPY = fetch(f,'JPNRGDPEXP',startdate,enddate)
AUS = fetch(f,'NGDPRSAXDCAUQ',startdate,enddate)
jpy = log(JPY.Data(:,2));
aus = log(AUS.Data(:,2));
q = JPY.Data(:,1);

T = size(jpy,1);

% Hodrick-Prescott filter for Japan
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end



% HPフィルターを適用してトレンドを除去
trend_jpy = A\jpy;
trend_aus = A\aus;
gdp_jpy = jpy - trend_jpy;
gdp_aus = aus - trend_aus;

% GDPの標準偏差を計算
jpytilde = std(gdp_jpy);
idytilde = std(gdp_aus);

% 互いのGDPの相関係数を計算
corr_coef = corrcoef(gdp_jpy, gdp_aus);
corr_jpy_aus = corr_coef(1, 2);

% グラフを作成
figure;
plot(q, gdp_jpy, 'b-', 'LineWidth', 2);
hold on;
plot(q, gdp_aus, 'r-', 'LineWidth', 2);
legend('Japan', 'Australia');
xlabel('Year');
ylabel('Log Real GDP');
title('Trend-Removed Real GDP');