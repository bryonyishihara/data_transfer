#!/bin/zsh

# calls deface_rename_bids.zsh and runs on all patients in DBS_dicom_nifti directory
# patient folders need to be sorted into ses-preop and ses-postop
# input all subject IDs

for var in "$@" ; do
    echo "${var}"
    /Users/bryony/Documents/GitHub/Data_transfer/data_transfer/deface_rename_bids.zsh ${var}
    echo "${var} preprocessing done"
done
