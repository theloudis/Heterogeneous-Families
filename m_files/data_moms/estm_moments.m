function [emp_MATCHED_c1, emp_BPS_c1, empse_MATCHED_c1, empse_BPS_c1] = ...
                        estm_moments(mC_c1, mI_c1, mEr_c1)
%{ 
    This function obtains the point estimates and the variance/covariance
    matrix of the empirical moments matched in the structural estimation.
                        
    Note that I calculate the point estimates and the covariance matrix of
    the empirical moments only over the baseline sample that appears in
    tables 4-5, or appendix tables E.1, E.5-E.7. In all other subsamples
    (e.g. net of chores and age of youngest child, wealthy households etc), 
    the moments are automatically calculated within the GMM routine, while 
    their covariance matrix is not used because I only try diagonally 
    weighted GMM in the baseline sample.

    Alexandros Theloudis
    -----------------------------------------------------------------------
%}

%   Initial statements:
global do dDir num_boots  ;


%%  1.  OBTAIN POINT-ESTIMATES OF EMPIRICAL MOMENTS
%   Deliver vectors of matched empirical moments.
%   -----------------------------------------------------------------------

%   Calculate empirical moments in the baseline dataset. 
[emp_MATCHED_c1,emp_BPS_c1] = fit_empirical_model(mC_c1, mI_c1, mEr_c1, 3, 0.15);


%%  2.  RUN BOOTSTRAP OVER MODEL - OBTAIN COVARIANCE MATRIX OF MOMENTS
%   Deliver matrices of parameters from bootstrap replications.
%   -----------------------------------------------------------------------

%   Run bootstrap:
if do.inference == 1

    %   Initialize matrices to hold results:
    mbsMatched_c1   = zeros(length(emp_MATCHED_c1),num_boots) ;
    mbsBPS_c1       = zeros(length(emp_BPS_c1),num_boots) ;

    %   Loop over bootstrap re-samples:
    for k = 1:num_boots

        %   Read bootstrap data:
        bs_dat = sprintf('_Cond1/bs_%d.csv',k) ;
        bs_err = sprintf('_Cond1/me_c1_bs_%d.csv',k) ;
        bs_avg = sprintf('_Cond1/avgrat_bs_c1_%d.csv',k) ;
        [mbsC_c1,mbsI_c1,~,~,mbsEr_c1,~,~,~] = handleData(bs_dat,bs_err,bs_avg,[]) ;

        %   Bootstrap empirical moments - place in matrices:
        [bsMatched_c1,bsBPS_c1] = fit_empirical_model(mbsC_c1, mbsI_c1, mbsEr_c1, 3, 0.15) ;
        mbsMatched_c1(:,k)      = bsMatched_c1 ;
        mbsBPS_c1(:,k)          = bsBPS_c1 ;

        %   Clear bootstrap data of this round:
        clearvars bs_* mbsC_c1 mbsI_c1 mbsE_c1 mbsP_c1 mbsEr_c1 mbsAvg_c1 mbsMed_c1 nn_c1 bsMatched_c1 bsBPS_c1

        %   Report progress:
        fprintf('Finished Bootstrap Estimation of Empirical Moments round : %u\n',k)
    end

    %   Calculate standard errors from bootstrap replications:
    mSqDevMatched_c1 = (mbsMatched_c1 - repmat(mean(mbsMatched_c1,2),1,num_boots)).^2 ;
    mSqDevBPS_c1     = (mbsBPS_c1 - repmat(mean(mbsBPS_c1,2),1,num_boots)).^2 ;
    empse_MATCHED_c1 = sqrt((sum(mSqDevMatched_c1,2)) / (num_boots-1)) ;
    empse_BPS_c1     = sqrt((sum(mSqDevBPS_c1,2)) / (num_boots-1)) ;

%   Retrieve results from hard disk:
else
    a.a1                = load(strcat(dDir,'/exports/results/moments/empse_MATCHED_c1')) ;
    a.a2                = load(strcat(dDir,'/exports/results/moments/empse_BPS_c1')) ;
    empse_MATCHED_c1    = a.a1.empse_MATCHED_c1 ;
    empse_BPS_c1        = a.a2.empse_BPS_c1 ;
end

end