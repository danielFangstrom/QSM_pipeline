clear;
subject_list = [1:4, 6:8, 11:23, 25:34, 36, 38, 39, 42:46, 48:50, 101, 103:109, ...
    111, 113, 115:122, 124, 127, 130:133, 135:146, 148, 149];
nifti_dir = '/data/pt_01923/TmpOut/final_script/Nifti/';
figure_no = 1;
all_data = cell(3, length( subject_list ) );
all_comparisons = cell( (length( subject_list ) + 1), ( length( subject_list ) + 1) );

color_list = ["red", "green", "blue", "cyan", "magenta", "yellow", "black", "#7E2F8E"];

for isub = 1:length( subject_list )
      
    if mod( isub, 16) == 1
        figure( figure_no )
        figure_no = figure_no + 1;
    end
    current_color = color_list( (1 + mod( isub, 8 ) ) );
    current_position = mod( isub, 16 );
    if current_position == 0
        current_position = 16;
    end
    
    subject = subject_list( isub );
    UNIDEN_05 = load_nifti( strcat( nifti_dir, 'sub-', sprintf( '%03d', subject ), '/ses-1/other/', 'memp2rage_wip900D_UNI_DEN_00005.nii' ) );
    vectorized = reshape( UNIDEN_05.vol, 1, [] );
    all_data{1, isub} = subject;
    all_data{2, isub} = vectorized;
    
    subplot( 4, 4, current_position )
    hist_vect = histfit( vectorized )
    hist_vect(1).FaceColor = current_color;
    set(gca, 'YScale', 'log')
    ylim( [0 1000000] )
    xlim( [-50 3700] )
    title( sprintf( '%03d', subject ) )
    
    all_data{3, isub} = kstest( vectorized );
    
    all_comparisons{1, isub} = subject;
    all_comparisons{isub, 1} = subject;
    all_comparisons{isub, isub} = "NA";
end

for isub = 1:length( subject_list )
    for testsub = 1: length( subject_list )
        all_comparisons{ (isub + 1), (testsub + 1) } = kstest2( all_data{2, isub}, all_data{2, testsub} );
    end
end
% [weight_by_subject, subjects] = fitdist(all_data{2,:}','weibull','by',all_data{1,:}');
% [normal_by_subject, subjects] = fitdist(all_data{2,:}','normal','by',all_data{1,:}');
% [logistic_by_subject, subjects] = fitdist(all_data{2,:},'logistic','by',all_data{1,:});
% [kernel_by_subject, subjects] = fitdist(all_data{2,:},'kernel','by',all_data{1,:});