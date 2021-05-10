function [Aeq,beq] = wage_eqcons(x,do_higher_moments)
%{  
    This function constructs the equality constraints imposed on the wage
    structure when moments of shocks are stationary. 
   
    It delivers matrix Aeq and vector beq which are used as 
    linear equality constraints in the fmincon procedures.

    The equality constraint is of the form 
    Aeq * x = beq
    where Aeq is an MxN matrix (M linear equality constraints, N
    parameters) and beq is an Mx1 vector.

    Alexandros Theloudis

    -----------------------------------------------------------------------
%}


%%  1.  STATIONARY VARIANCE/COVARIANCE OF PERMANENT SHOCKS
%   Define constraints
%   -----------------------------------------------------------------------

%   Aeq1: vH(1) = vH(2)
Aeq1    = zeros(1,length(x)) ;
Aeq1(1) = 1  ;
Aeq1(2) = -1 ;

%   Aeq2: vH(2) = vH(3)
Aeq2    = zeros(1,length(x)) ;
Aeq2(2) = 1  ;
Aeq2(3) = -1 ;

%   Aeq3: vH(3) = vH(4)
Aeq3    = zeros(1,length(x)) ;
Aeq3(3) = 1  ;
Aeq3(4) = -1 ;

%   Aeq4: vH(4) = vH(5)
Aeq4    = zeros(1,length(x)) ;
Aeq4(4) = 1  ;
Aeq4(5) = -1 ;

%   Aeq5: vW(1) = vW(2)
Aeq5     = zeros(1,length(x)) ;
Aeq5(12) = 1  ;
Aeq5(13) = -1 ;

%   Aeq6: vW(2) = vW(3)
Aeq6     = zeros(1,length(x)) ;
Aeq6(13) = 1  ;
Aeq6(14) = -1 ;

%   Aeq7: vW(3) = vW(4)
Aeq7     = zeros(1,length(x)) ;
Aeq7(14) = 1  ;
Aeq7(15) = -1 ;

%   Aeq8: vW(4) = vW(5)
Aeq8     = zeros(1,length(x)) ;
Aeq8(15) = 1  ;
Aeq8(16) = -1 ;

%   Aeq9: vHW(1) = vHW(2)
Aeq9     = zeros(1,length(x)) ;
Aeq9(23) = 1  ;
Aeq9(24) = -1 ;

%   Aeq10: vHW(2) = vHW(3)
Aeq10     = zeros(1,length(x)) ;
Aeq10(24) = 1  ;
Aeq10(25) = -1 ;

%   Aeq11: vHW(3) = vHW(4)
Aeq11     = zeros(1,length(x)) ;
Aeq11(25) = 1  ;
Aeq11(26) = -1 ;

%   Aeq12: vHW(4) = vHW(5)
Aeq12     = zeros(1,length(x)) ;
Aeq12(26) = 1  ;
Aeq12(27) = -1 ;


%%  2.  STATIONARY VARIANCE/COVARIANCE OF TRANSITORY SHOCKS
%   Define constraints
%   -----------------------------------------------------------------------

%   Aeq13: uH(1) = uH(2)
Aeq13    = zeros(1,length(x)) ;
Aeq13(6) = 1  ;
Aeq13(7) = -1 ;

%   Aeq14: uH(2) = uH(3)
Aeq14    = zeros(1,length(x)) ;
Aeq14(7) = 1  ;
Aeq14(8) = -1 ;

%   Aeq15: uH(3) = uH(4)
Aeq15    = zeros(1,length(x)) ;
Aeq15(8) = 1  ;
Aeq15(9) = -1 ;

%   Aeq16: uH(4) = uH(5)
Aeq16     = zeros(1,length(x)) ;
Aeq16(9)  = 1  ;
Aeq16(10) = -1 ;

%   Aeq17: uH(5) = uH(6)
Aeq17     = zeros(1,length(x)) ;
Aeq17(10) = 1  ;
Aeq17(11) = -1 ;

%   Aeq18: uW(1) = uW(2)
Aeq18     = zeros(1,length(x)) ;
Aeq18(17) = 1  ;
Aeq18(18) = -1 ;

%   Aeq19: uW(2) = uW(3)
Aeq19     = zeros(1,length(x)) ;
Aeq19(18) = 1  ;
Aeq19(19) = -1 ;

%   Aeq20: uW(3) = uW(4)
Aeq20     = zeros(1,length(x)) ;
Aeq20(19) = 1  ;
Aeq20(20) = -1 ;

%   Aeq21: uW(4) = uW(5)
Aeq21     = zeros(1,length(x)) ;
Aeq21(20) = 1  ;
Aeq21(21) = -1 ;

%   Aeq22: uW(5) = uW(6)
Aeq22     = zeros(1,length(x)) ;
Aeq22(21) = 1  ;
Aeq22(22) = -1 ;

%   Aeq23: uHW(1) = uHW(2)
Aeq23     = zeros(1,length(x)) ;
Aeq23(28) = 1  ;
Aeq23(29) = -1 ;

%   Aeq24: uHW(2) = uHW(3)
Aeq24     = zeros(1,length(x)) ;
Aeq24(29) = 1  ;
Aeq24(30) = -1 ;

%   Aeq25: uHW(3) = uHW(4)
Aeq25     = zeros(1,length(x)) ;
Aeq25(30) = 1  ;
Aeq25(31) = -1 ;

%   Aeq26: uHW(4) = uHW(5)
Aeq26     = zeros(1,length(x)) ;
Aeq26(31) = 1  ;
Aeq26(32) = -1 ;

%   Aeq27: uHW(5) = uHW(6)
Aeq27    = zeros(1,length(x)) ;
Aeq27(32) = 1  ;
Aeq27(33) = -1 ;


%%  3.  STATIONARY THIRD MOMENTS OF PERMANENT SHOCKS
%   Define constraints
%   -----------------------------------------------------------------------

if do_higher_moments >= 1

%   Aeq28: gvH(1) = gvH(2)
Aeq28    = zeros(1,length(x)) ;
Aeq28(45)= 1  ;
Aeq28(46)= -1 ;

%   Aeq29: gvH(2) = gvH(3)
Aeq29    = zeros(1,length(x)) ;
Aeq29(46)= 1  ;
Aeq29(47)= -1 ;

%   Aeq30: gvH(3) = gvH(4)
Aeq30    = zeros(1,length(x)) ;
Aeq30(47)= 1  ;
Aeq30(48)= -1 ;

%   Aeq31: gvH(4) = gvH(5)
Aeq31    = zeros(1,length(x)) ;
Aeq31(48)= 1  ;
Aeq31(49)= -1 ;

%   Aeq32: gvW(1) = gvW(2)
Aeq32    = zeros(1,length(x)) ;
Aeq32(56)= 1  ;
Aeq32(57)= -1 ;

%   Aeq33: gvW(2) = gvW(3)
Aeq33    = zeros(1,length(x)) ;
Aeq33(57)= 1  ;
Aeq33(58)= -1 ;

%   Aeq34: gvW(3) = gvW(4)
Aeq34    = zeros(1,length(x)) ;
Aeq34(58)= 1  ;
Aeq34(59)= -1 ;

%   Aeq35: gvW(4) = gvW(5)
Aeq35    = zeros(1,length(x)) ;
Aeq35(59)= 1  ;
Aeq35(60)= -1 ;

%   Aeq36: gvH2W(1) = gvH2W(2)
Aeq36     = zeros(1,length(x)) ;
Aeq36(67) = 1  ;
Aeq36(68) = -1 ;

%   Aeq37: gvH2W(2) = gvH2W(3)
Aeq37     = zeros(1,length(x)) ;
Aeq37(68) = 1  ;
Aeq37(69) = -1 ;

%   Aeq38: gvH2W(3) = gvH2W(4)
Aeq38     = zeros(1,length(x)) ;
Aeq38(69) = 1  ;
Aeq38(70) = -1 ;

%   Aeq39: gvH2W(4) = gvH2W(5)
Aeq39     = zeros(1,length(x)) ;
Aeq39(70) = 1  ;
Aeq39(71) = -1 ;

%   Aeq40: gvHW2(1) = gvHW2(2)
Aeq40     = zeros(1,length(x)) ;
Aeq40(78) = 1  ;
Aeq40(79) = -1 ;

%   Aeq41: gvHW2(2) = gvHW2(3)
Aeq41     = zeros(1,length(x)) ;
Aeq41(79) = 1  ;
Aeq41(80) = -1 ;

%   Aeq42: gvHW2(3) = gvHW2(4)
Aeq42     = zeros(1,length(x)) ;
Aeq42(80) = 1  ;
Aeq42(81) = -1 ;

%   Aeq43: gvHW2(4) = gvHW2(5)
Aeq43     = zeros(1,length(x)) ;
Aeq43(81) = 1  ;
Aeq43(82) = -1 ;
    
end


%%  4.  STATIONARY THIRD MOMENTS OF TRANSITORY SHOCKS
%   Define constraints
%   -----------------------------------------------------------------------

if do_higher_moments >= 1
    
%   Aeq44: guH(1) = guH(2)
Aeq44     = zeros(1,length(x)) ;
Aeq44(50) = 1  ;
Aeq44(51) = -1 ;

%   Aeq45: guH(2) = guH(3)
Aeq45     = zeros(1,length(x)) ;
Aeq45(51) = 1  ;
Aeq45(52) = -1 ;

%   Aeq46: guH(3) = guH(4)
Aeq46     = zeros(1,length(x)) ;
Aeq46(52) = 1  ;
Aeq46(53) = -1 ;

%   Aeq47: guH(4) = guH(5)
Aeq47     = zeros(1,length(x)) ;
Aeq47(53) = 1  ;
Aeq47(54) = -1 ;

%   Aeq48: guH(5) = guH(6)
Aeq48     = zeros(1,length(x)) ;
Aeq48(54) = 1  ;
Aeq48(55) = -1 ;

%   Aeq49: guW(1) = guW(2)
Aeq49     = zeros(1,length(x)) ;
Aeq49(61) = 1  ;
Aeq49(62) = -1 ;

%   Aeq50: guW(2) = guW(3)
Aeq50     = zeros(1,length(x)) ;
Aeq50(62) = 1  ;
Aeq50(63) = -1 ;

%   Aeq51: guW(3) = guW(4)
Aeq51     = zeros(1,length(x)) ;
Aeq51(63) = 1  ;
Aeq51(64) = -1 ;

%   Aeq52: guW(4) = guW(5)
Aeq52     = zeros(1,length(x)) ;
Aeq52(64) = 1  ;
Aeq52(65) = -1 ;

%   Aeq53: guW(5) = guW(6)
Aeq53     = zeros(1,length(x)) ;
Aeq53(65) = 1  ;
Aeq53(66) = -1 ;

%   Aeq54: guH2W(1) = guH2W(2)
Aeq54     = zeros(1,length(x)) ;
Aeq54(72) = 1  ;
Aeq54(73) = -1 ;

%   Aeq55: guH2W(2) = guH2W(3)
Aeq55     = zeros(1,length(x)) ;
Aeq55(73) = 1  ;
Aeq55(74) = -1 ;

%   Aeq56: guH2W(3) = guH2W(4)
Aeq56     = zeros(1,length(x)) ;
Aeq56(74) = 1  ;
Aeq56(75) = -1 ;

%   Aeq57: guH2W(4) = guH2W(5)
Aeq57     = zeros(1,length(x)) ;
Aeq57(75) = 1  ;
Aeq57(76) = -1 ;

%   Aeq58: guH2W(5) = guH2W(6)
Aeq58     = zeros(1,length(x)) ;
Aeq58(76) = 1  ;
Aeq58(77) = -1 ;

%   Aeq59: guHW2(1) = guHW2(2)
Aeq59     = zeros(1,length(x)) ;
Aeq59(83) = 1  ;
Aeq59(84) = -1 ;

%   Aeq60: guHW2(2) = guHW2(3)
Aeq60     = zeros(1,length(x)) ;
Aeq60(84) = 1  ;
Aeq60(85) = -1 ;

%   Aeq61: guHW2(3) = guHW2(4)
Aeq61     = zeros(1,length(x)) ;
Aeq61(85) = 1  ;
Aeq61(86) = -1 ;

%   Aeq62: guHW2(4) = guHW2(5)
Aeq62     = zeros(1,length(x)) ;
Aeq62(86) = 1  ;
Aeq62(87) = -1 ;

%   Aeq63: guHW2(5) = guHW2(6)
Aeq63     = zeros(1,length(x)) ;
Aeq63(87) = 1  ;
Aeq63(88) = -1 ;

end


%%  5.  DELIVER
%   Stack constraints together
%   -----------------------------------------------------------------------

Aeq = [ Aeq1;   Aeq2;   Aeq3;   Aeq4;   Aeq5;   Aeq6;   Aeq7;   Aeq8;   Aeq9;   Aeq10; ...
        Aeq11;  Aeq12;  Aeq13;  Aeq14;  Aeq15;  Aeq16;  Aeq17;  Aeq18;  Aeq19;  Aeq20; ... 
        Aeq21;  Aeq22;  Aeq23;  Aeq24;  Aeq25;  Aeq26;  Aeq27 ] ;
A3eq= [ Aeq28;  Aeq29;  Aeq30; ... 
        Aeq31;  Aeq32;  Aeq33;  Aeq34;  Aeq35;  Aeq36;  Aeq37;  Aeq38;  Aeq39;  Aeq40; ...
        Aeq41;  Aeq42;  Aeq43;  Aeq44;  Aeq45;  Aeq46;  Aeq47;  Aeq48;  Aeq49;  Aeq50; ...
        Aeq51;  Aeq52;  Aeq53;  Aeq54;  Aeq55;  Aeq56;  Aeq57;  Aeq58;  Aeq59;  Aeq60; ...
        Aeq61;  Aeq62;  Aeq63 ] ;
Aeq = [Aeq;A3eq] ;

beq = zeros(size(Aeq,1),1) ;

end