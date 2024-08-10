clc;
clear;
close all

P_boiler_initial = 15e6;
P_condenser_initial = 10e3;

dP1 = (15e6 - 12e6)/100;
dP2 = (10e3 - 5e3)/100;

work_output1 = [];
work_output2 = [];
pb_array = [];
pc_array = [];

i = 1;
while P_boiler_initial > 12e6
    pb_array(i) = P_boiler_initial;
    work_output1(i) = variation(P_boiler_initial,P_condenser_initial);
    P_boiler_initial = P_boiler_initial - dP1;
    i = i + 1;
end


j = 1;
P_boiler_initial = 15e6;
while P_condenser_initial > 5e3
    work_output2(j) = variation(P_boiler_initial,P_condenser_initial);
    pc_array(j) = P_condenser_initial;
    P_condenser_initial = P_condenser_initial - dP2;
    j = j + 1;
end

figure();

plot(pb_array, work_output1);
xlabel('Boiler Pressure (in Pa)');
ylabel('Work Output of the Cycle');
title('Work output V/S Boiler Pressure');

figure();

plot(pc_array,work_output2);
xlabel('Condenser Pressure (in Pa)');
ylabel('Work output of the cycle');
title('Work output V/S Condenser Pressure');


function w = variation(p_b,p_c)                % P_b is the Boiler pressure and P_c is the condenser pressure

w=Solution('liquidvapor.xml','water');
% setting state to 9

p9 = p_b;
T9 = 500+273.15;

set(w,'P',p9,'T',T9);
s9 = entropy_mass(w);
h9 = enthalpy_mass(w);

% setting state to 13

x13 = 0.85;
p13 = p_c;

setState_Psat(w,[p13,x13]);
s13 = entropy_mass(w);
h13 = enthalpy_mass(w);

% setting state to 11

s11 = s13;
T11 = 500+273.15;

setState_ST(w,[s11,T11]);
p11 = pressure(w);
h11 = enthalpy_mass(w);

% setting state to 12

s12 = s13;
p12 = 3.9219e+05;

setState_SP(w,[s12,p12]);
h12 = enthalpy_mass(w);

% setting state to 10

s10 = s9;
p10 = p11;

setState_SP(w,[s10,p10]);
h10 = enthalpy_mass(w);

% setting state to 1

p1 = p_c;
x1 = 0;

setState_Psat(w,[p1,x1]);
s1 = entropy_mass(w);
h1 = enthalpy_mass(w);

% setting state to 2

p2 = p12;
s2 = s1;

setState_SP(w,[s1,p1]);
h2 = enthalpy_mass(w);

% setting state to 3

p3 = p2;
x3 = 0;

setState_Psat(w,[p3,x3]);
h3 = enthalpy_mass(w);
s3 = entropy_mass(w);

% setting state to 4

p4 = p_b;
s4 = s3;

setState_SP(w,[s4,p4]);
h4 = enthalpy_mass(w);

% setting state to 6

p6 = p10;
x6 = 0;

setState_Psat(w,[p6,x6]);
h6 = enthalpy_mass(w);
s6 = entropy_mass(w);

% setting state to 7

s7 = s6;
p7 = p9;

setState_SP(w,[s7,p7]);
h7 = enthalpy_mass(w);

% set state to 5

h5 = h6;
p5 = p_b;

setState_HP(w,[h5,p5]);

y=(h5-h4)/(h10-h4);
z=(1-y)*(h3-h2)/(h12-h2);

% setting state to 8

h8=(1-y)*h5+y*h7;
p8 = p_b;

% Various heats/works

q_abs=(h9-h8)+(1-y)*(h11-h10);% Net heat absorbed

q_rej=(1-y-z)*(h13-h1);% net heat rejected

n=1-(q_rej)/q_abs;

w = q_abs - q_rej;
end

%% for obatining quality=85%
