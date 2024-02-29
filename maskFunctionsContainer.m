classdef maskFunctionsContainer
    methods
        %% In case the masks needed padding to increase their dimensions, we need to save them.
        % In order to save the file with the correct information, we copy info stored in the header of the QSM file
        function WriteUpdatedMasks(mask_volume, mask_dir, mask_name, QSM_name)
            info_QSM = niftiinfo( QSM_name );
            info_mask = niftiinfo( strcat( mask_dir, mask_name ) );
            info_mask.ImageSize = size( mask_volume );
            info_mask.Description = 'Image size increased via zero padding to match that of the QSM file';
            %info_mask.raw_info.ImageSize = info_QSM.raw_info.ImageSize; % [3,181,217,181,1,1,1,1];
            info_mask.Datatype = 'double';
            info_mask.raw.qform_code = info_QSM.raw.qform_code;
            info_mask.raw.sform_code = info_QSM.raw.sform_code;
            info_mask.raw.qoffset_x = info_QSM.raw.qoffset_x;
            info_mask.raw.qoffset_y = info_QSM.raw.qoffset_y;
            info_mask.raw.qoffset_z = info_QSM.raw.qoffset_z;
            info_mask.raw.srow_x = info_QSM.raw.srow_x;
            info_mask.raw.srow_y = info_QSM.raw.srow_y;
            info_mask.raw.srow_z = info_QSM.raw.srow_z;
            info_mask.TransformName = info_QSM.TransformName;
            info_mask.Transform = info_QSM.Transform;
            niftiwrite( mask_volume, strcat(mask_dir,  'modified_', mask_name), info_mask );
        end

        %% When we're adjusting the images, we need to account for the origin of the mask
        % WIP
        function adjustments = CalculateOffsetAdjustment(mask_dir, mask_name, QSM_name, padding_amount)
            info_QSM = niftiinfo( QSM_name );
            info_mask = niftiinfo( strcat( mask_dir, mask_name ) );
            difference_X = abs(info_QSM.raw.qoffset_x - info_mask.raw.qoffset_x);
            difference_Y = abs(info_QSM.raw.qoffset_y - info_mask.raw.qoffset_y);
            difference_Z = abs(info_QSM.raw.qoffset_z - info_mask.raw.qoffset_z);
            adjustment_X = difference_X - padding_amount(1);
            adjustment_Y = difference_Y - padding_amount(2);
            adjustment_Z = difference_Z - padding_amount(3);
            adjustments = [adjustment_X, adjustment_Y, adjustment_Z];
        end
    end
end