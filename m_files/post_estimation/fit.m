
%%  Deliver matched moments.
%
%   'Consumption Inequality across Heterogeneous Families'
%   This script exports table with preferred specification moments 
%   (empirical, and fitted) for use in paper appendix.
%
%   Alexandros Theloudis
%   LISER Luxembourg 
%   Tilburg Econometrics & Operations Research 
%   Spring 2021
%
%   =======================================================================

%   Initial statements:
global  dDir vWageHat vModelHat_c1 ;


%%  1.  OBTAIN FITTED MOMENTS
%   Deliver vectors of model moments (both those matched to empirical 
%   counterparts and several unmatched ones). 
%   -----------------------------------------------------------------------

%   Obtain theoretical moments in preferred specification:
[vPrefFitted,~] = fit_theoretical_model(vModelHat_c1.PREF, vWageHat, 6, 3) ;

%   Calculate t-stat of difference between data and empirical moment:
vPrefTstats = (vPrefFitted-emp_MATCHED_c1)./empse_MATCHED_c1 ;


%%  3.  DELIVER TABLES OF MOMENTS along with STANDARD ERRORS & T-STATS (TABLES D.4-D.6)
%   Construct tables of empirical and fitted moments for paper appendix.
%   -----------------------------------------------------------------------

%   Construct and save table of wage moments:
wwtable = [ emp_MATCHED_c1(1)   vPrefFitted(1)    vPrefTstats(1)  ;
            empse_MATCHED_c1(1)  NaN               NaN             ;
            emp_MATCHED_c1(2)   vPrefFitted(2)    vPrefTstats(2)  ;
            empse_MATCHED_c1(2)  NaN               NaN             ;
            emp_MATCHED_c1(6)   vPrefFitted(6)    vPrefTstats(6)  ;
            empse_MATCHED_c1(6)  NaN               NaN             ;
            emp_MATCHED_c1(7)   vPrefFitted(7)    vPrefTstats(7)  ;
            empse_MATCHED_c1(7)  NaN               NaN             ;
            emp_MATCHED_c1(3)   vPrefFitted(3)    vPrefTstats(3)  ;
            empse_MATCHED_c1(3)  NaN               NaN             ;
            emp_MATCHED_c1(4)   vPrefFitted(4)    vPrefTstats(4)  ;
            empse_MATCHED_c1(4)  NaN               NaN             ;
            emp_MATCHED_c1(5)   vPrefFitted(5)    vPrefTstats(5)  ;
            empse_MATCHED_c1(5)  NaN               NaN             ;
            emp_MATCHED_c1(8)   vPrefFitted(8)    vPrefTstats(8)  ;
            empse_MATCHED_c1(8)  NaN               NaN             ;
            emp_MATCHED_c1(9)   vPrefFitted(9)    vPrefTstats(9)  ;
            empse_MATCHED_c1(9)  NaN               NaN             ;
            emp_MATCHED_c1(10)  vPrefFitted(10)   vPrefTstats(10) ;
            empse_MATCHED_c1(10) NaN               NaN             ;
            emp_MATCHED_c1(17)  vPrefFitted(17)   vPrefTstats(17) ;
            empse_MATCHED_c1(17) NaN               NaN             ;
            emp_MATCHED_c1(18)  vPrefFitted(18)   vPrefTstats(18) ;
            empse_MATCHED_c1(18) NaN               NaN             ;
            emp_MATCHED_c1(19)  vPrefFitted(19)   vPrefTstats(19) ;
            empse_MATCHED_c1(19) NaN               NaN             ;
            emp_MATCHED_c1(11)  vPrefFitted(11)   vPrefTstats(11) ;
            empse_MATCHED_c1(11) NaN               NaN             ;
            emp_MATCHED_c1(12)  vPrefFitted(12)   vPrefTstats(12) ;
            empse_MATCHED_c1(12) NaN               NaN             ;
            emp_MATCHED_c1(13)  vPrefFitted(13)   vPrefTstats(13) ;
            empse_MATCHED_c1(13) NaN               NaN             ;
            emp_MATCHED_c1(14)  vPrefFitted(14)   vPrefTstats(14) ;
            empse_MATCHED_c1(14) NaN               NaN             ;
            emp_MATCHED_c1(15)  vPrefFitted(15)   vPrefTstats(15) ;
            empse_MATCHED_c1(15) NaN               NaN             ;
            emp_MATCHED_c1(16)  vPrefFitted(16)   vPrefTstats(16) ;
            empse_MATCHED_c1(16) NaN               NaN             ;
            emp_MATCHED_c1(20)  vPrefFitted(20)   vPrefTstats(20) ;
            empse_MATCHED_c1(20) NaN               NaN             ;
            emp_MATCHED_c1(21)  vPrefFitted(21)   vPrefTstats(21) ;
            empse_MATCHED_c1(21) NaN               NaN             ;
            emp_MATCHED_c1(22)  vPrefFitted(22)   vPrefTstats(22) ;
            empse_MATCHED_c1(22) NaN               NaN             ;
            emp_MATCHED_c1(23)  vPrefFitted(23)   vPrefTstats(23) ;
            empse_MATCHED_c1(23) NaN               NaN            ];
wwtable = round(wwtable,3) ;
xlswrite(strcat(dDir,'/tables/table_d4.csv'),wwtable,1)

%   Construct and save table of earnings & earning-wage moments:
ywtable = [ emp_MATCHED_c1(24)  vPrefFitted(24)   vPrefTstats(24) ;
            empse_MATCHED_c1(24) NaN               NaN             ;
            emp_MATCHED_c1(25)  vPrefFitted(25)   vPrefTstats(25) ;
            empse_MATCHED_c1(25) NaN               NaN             ;
            emp_MATCHED_c1(26)  vPrefFitted(26)   vPrefTstats(26) ;
            empse_MATCHED_c1(26) NaN               NaN             ;
            emp_MATCHED_c1(27)  vPrefFitted(27)   vPrefTstats(27) ;
            empse_MATCHED_c1(27) NaN               NaN             ;
            emp_MATCHED_c1(28)  vPrefFitted(28)   vPrefTstats(28) ;
            empse_MATCHED_c1(28) NaN               NaN             ;
            emp_MATCHED_c1(29)  vPrefFitted(29)   vPrefTstats(29) ;
            empse_MATCHED_c1(29) NaN               NaN             ;
            emp_MATCHED_c1(30)  vPrefFitted(30)   vPrefTstats(30) ;
            empse_MATCHED_c1(30) NaN               NaN             ;
            emp_MATCHED_c1(31)  vPrefFitted(31)   vPrefTstats(31) ;
            empse_MATCHED_c1(31) NaN               NaN             ;
            emp_MATCHED_c1(36)  vPrefFitted(36)   vPrefTstats(36) ;
            empse_MATCHED_c1(36) NaN               NaN             ;
            emp_MATCHED_c1(37)  vPrefFitted(37)   vPrefTstats(37) ;
            empse_MATCHED_c1(37) NaN               NaN             ;
            emp_MATCHED_c1(38)  vPrefFitted(38)   vPrefTstats(38) ;
            empse_MATCHED_c1(38) NaN               NaN             ;
            emp_MATCHED_c1(39)  vPrefFitted(39)   vPrefTstats(39) ;
            empse_MATCHED_c1(39) NaN               NaN             ;
            emp_MATCHED_c1(45)  vPrefFitted(45)   vPrefTstats(45) ;
            empse_MATCHED_c1(45) NaN               NaN             ;
            emp_MATCHED_c1(46)  vPrefFitted(46)   vPrefTstats(46) ;
            empse_MATCHED_c1(46) NaN               NaN             ;
            emp_MATCHED_c1(47)  vPrefFitted(47)   vPrefTstats(47) ;
            empse_MATCHED_c1(47) NaN               NaN             ;
            emp_MATCHED_c1(48)  vPrefFitted(48)   vPrefTstats(48) ;
            empse_MATCHED_c1(48) NaN               NaN             ;
            emp_MATCHED_c1(49)  vPrefFitted(49)   vPrefTstats(49) ;
            empse_MATCHED_c1(49) NaN               NaN             ;
            emp_MATCHED_c1(50)  vPrefFitted(50)   vPrefTstats(50) ;
            empse_MATCHED_c1(50) NaN               NaN             ;
            emp_MATCHED_c1(51)  vPrefFitted(51)   vPrefTstats(51) ;
            empse_MATCHED_c1(51) NaN               NaN             ;
            emp_MATCHED_c1(52)  vPrefFitted(52)   vPrefTstats(52) ;
            empse_MATCHED_c1(52) NaN               NaN             ;
            emp_MATCHED_c1(57)  vPrefFitted(57)   vPrefTstats(57) ;
            empse_MATCHED_c1(57) NaN               NaN             ;
            emp_MATCHED_c1(58)  vPrefFitted(58)   vPrefTstats(58) ;
            empse_MATCHED_c1(58) NaN               NaN             ;
            emp_MATCHED_c1(59)  vPrefFitted(59)   vPrefTstats(59) ;
            empse_MATCHED_c1(59) NaN               NaN             ;
            emp_MATCHED_c1(60)  vPrefFitted(60)   vPrefTstats(60) ;
            empse_MATCHED_c1(60) NaN               NaN             ;
            emp_MATCHED_c1(61)  vPrefFitted(61)   vPrefTstats(61) ;
            empse_MATCHED_c1(61) NaN               NaN             ;
            emp_MATCHED_c1(62)  vPrefFitted(62)   vPrefTstats(62) ;
            empse_MATCHED_c1(62) NaN               NaN             ;
            emp_MATCHED_c1(63)  vPrefFitted(63)   vPrefTstats(63) ;
            empse_MATCHED_c1(63) NaN               NaN             ;
            emp_MATCHED_c1(64)  vPrefFitted(64)   vPrefTstats(64) ;
            empse_MATCHED_c1(64) NaN               NaN             ;     
            emp_MATCHED_c1(69)  vPrefFitted(69)   vPrefTstats(69) ;
            empse_MATCHED_c1(69) NaN               NaN             ;
            emp_MATCHED_c1(70)  vPrefFitted(70)   vPrefTstats(70) ;
            empse_MATCHED_c1(70) NaN               NaN             ;
            emp_MATCHED_c1(71)  vPrefFitted(71)   vPrefTstats(71) ;
            empse_MATCHED_c1(71) NaN               NaN             ;
            emp_MATCHED_c1(72)  vPrefFitted(72)   vPrefTstats(72) ;
            empse_MATCHED_c1(72) NaN               NaN            ];
ywtable = round(ywtable,3) ;
xlswrite(strcat(dDir,'/tables/table_d5.csv'),ywtable,1)

%   Construct and save table of consumption moments:
yctable = [ emp_MATCHED_c1(32)  vPrefFitted(32)   vPrefTstats(32) ;
            empse_MATCHED_c1(32) NaN               NaN             ;
            emp_MATCHED_c1(33)  vPrefFitted(33)   vPrefTstats(33) ;
            empse_MATCHED_c1(33) NaN               NaN             ;
            emp_MATCHED_c1(34)  vPrefFitted(34)   vPrefTstats(34) ;
            empse_MATCHED_c1(34) NaN               NaN             ;
            emp_MATCHED_c1(35)  vPrefFitted(35)   vPrefTstats(35) ;
            empse_MATCHED_c1(35) NaN               NaN             ;
            emp_MATCHED_c1(40)  vPrefFitted(40)   vPrefTstats(40) ;
            empse_MATCHED_c1(40) NaN               NaN             ;
            emp_MATCHED_c1(41)  vPrefFitted(41)   vPrefTstats(41) ;
            empse_MATCHED_c1(41) NaN               NaN             ;
            emp_MATCHED_c1(42)  vPrefFitted(42)   vPrefTstats(42) ;
            empse_MATCHED_c1(42) NaN               NaN             ;
            emp_MATCHED_c1(43)  vPrefFitted(43)   vPrefTstats(43) ;
            empse_MATCHED_c1(43) NaN               NaN             ;
            emp_MATCHED_c1(44)  vPrefFitted(44)   vPrefTstats(44) ;
            empse_MATCHED_c1(44) NaN               NaN             ;
            emp_MATCHED_c1(53)  vPrefFitted(53)   vPrefTstats(53) ;
            empse_MATCHED_c1(53) NaN               NaN             ;
            emp_MATCHED_c1(54)  vPrefFitted(54)   vPrefTstats(54) ;
            empse_MATCHED_c1(54) NaN               NaN             ;
            emp_MATCHED_c1(55)  vPrefFitted(55)   vPrefTstats(55) ;
            empse_MATCHED_c1(55) NaN               NaN             ;
            emp_MATCHED_c1(56)  vPrefFitted(56)   vPrefTstats(56) ;
            empse_MATCHED_c1(56) NaN               NaN             ;
            emp_MATCHED_c1(65)  vPrefFitted(65)   vPrefTstats(65) ;
            empse_MATCHED_c1(65) NaN               NaN             ;
            emp_MATCHED_c1(66)  vPrefFitted(66)   vPrefTstats(66) ;
            empse_MATCHED_c1(66) NaN               NaN             ;
            emp_MATCHED_c1(67)  vPrefFitted(67)   vPrefTstats(67) ;
            empse_MATCHED_c1(67) NaN               NaN             ;
            emp_MATCHED_c1(68)  vPrefFitted(68)   vPrefTstats(68) ;
            empse_MATCHED_c1(68) NaN               NaN             ;
            emp_MATCHED_c1(73)  vPrefFitted(73)   vPrefTstats(73) ;
            empse_MATCHED_c1(73) NaN               NaN             ;
            emp_MATCHED_c1(74)  vPrefFitted(74)   vPrefTstats(74) ;
            empse_MATCHED_c1(74) NaN               NaN             ;
            emp_MATCHED_c1(75)  vPrefFitted(75)   vPrefTstats(75) ;
            empse_MATCHED_c1(75) NaN               NaN             ;
            emp_MATCHED_c1(76)  vPrefFitted(76)   vPrefTstats(76) ;
            empse_MATCHED_c1(76) NaN               NaN             ;  
            emp_MATCHED_c1(77)  vPrefFitted(77)   vPrefTstats(77) ;
            empse_MATCHED_c1(77) NaN               NaN             ;
            emp_MATCHED_c1(78)  vPrefFitted(78)   vPrefTstats(78) ;
            empse_MATCHED_c1(78) NaN               NaN             ;
            emp_MATCHED_c1(79)  vPrefFitted(79)   vPrefTstats(79) ;
            empse_MATCHED_c1(79) NaN               NaN             ;
            emp_MATCHED_c1(80)  vPrefFitted(80)   vPrefTstats(80) ;
            empse_MATCHED_c1(80) NaN               NaN            ];
yctable = round(yctable,3) ;
xlswrite(strcat(dDir,'/tables/table_d6.csv'),yctable,1)

%   Clear workspace:
clearvars wwtable ywtable yctable vPrefFitted vPrefTstats