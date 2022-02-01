#!/bin/zsh

# reorient all nifti images
for file in *.nii.gz ; do
  fslreorient2std ${file}
  echo "${file} reoriented"
done

# deface reoriented T1 and FLAIR images and rename all nifti files to image type
for file in *.nii.gz ; do
  if [[ "${file}" == *"MPRAGE"* ]] || [[ "${file}" == *"T1"* ]] ; then
    fsl_deface ${file} MPRAGE.nii.gz
    echo "MPRAGE defaced and renamed"
  elif [[ "${file}" == *"FLAIR"* ]] ; then
    fsl_deface ${file} FLAIR.nii.gz
    echo "FLAIR defaced and renamed"
  elif [[ "${file}" == *"T2"* ]] ; then
    mv ${file} T2.nii.gz
    echo "T2 renamed"
  elif [[ "${file}" == *"FGATIR"* ]] ; then
    mv ${file} FGATIR.nii.gz
    echo "FGATIR renamed"
  elif [[ "${file}" == *"SWI"* ]] ; then
    mv ${file} SWI.nii.gz
    echo "SWI renamed"
  else echo "done"
  fi
done
