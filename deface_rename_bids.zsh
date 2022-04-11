#!/bin/zsh

#${1} = surgery date 'yyyy-mm-dd'
# run from ses-preop directory

#defaces and renames images in bids format

# reorient all nifti images
for file in *.nii.gz ; do
  fslreorient2std ${file}
  echo "${file} reoriented"
done

# deface reoriented T1 and FLAIR images and rename all nifti files to image type
# moves files to anat and dwi folders

mkdir anat
mkdir dwi

for file in *.nii.gz ; do
  if [[ "${file}" == *"MPRAGE"* ]] || [[ "${file}" == *"T1"* ]] ; then
    fsl_deface ${file} sub-${1}_ses-preop_mprage.nii.gz
    echo "MPRAGE defaced and renamed"
    mv sub-${1}_ses-preop_mprage.nii.gz anat
  elif [[ "${file}" == *"FLAIR"* ]] ; then
    fsl_deface ${file} sub-${1}_ses-preop_flair.nii.gz
    echo "FLAIR defaced and renamed"
    mv sub-${1}_ses-preop_flair.nii.gz anat
  elif [[ "${file}" == *"T2"* ]] ; then
    mv ${file} sub-${1}_ses-preop_t2.nii.gz
    echo "T2 renamed"
    mv sub-${1}_ses-preop_t2.nii.gz anat
  elif [[ "${file}" == *"FGATIR"* ]] ; then
    mv ${file} sub-${1}_ses-preop_fgatir.nii.gz
    echo "FGATIR renamed"
    mv sub-${1}_ses-preop_fgatir.nii.gz anat
  elif [[ "${file}" == *"SWI"* ]] ; then
    mv ${file} sub-${1}_ses-preop_swi.nii.gz
    echo "SWI renamed"
    mv sub-${1}_ses-preop_swi.nii.gz anat
  else mv ${file} dwi
  fi
done

mv *.bval dwi
mv *.bvec dwi

# anonymises and renames .json files

for file in *.json ; do
  if [[ "${file}" == *"MPRAGE"* ]] || [[ "${file}" == *"T1"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > sub-${1}_ses-preop_mprage.json && rm ${file}
    echo "${file} anonymised"
    mv sub-${1}_ses-preop_mprage.json anat
  elif [[ "${file}" == *"FLAIR"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > sub-${1}_ses-preop_flair.json && rm ${file}
    echo "${file} anonymised"
    mv sub-${1}_ses-preop_flair.json anat
  elif [[ "${file}" == *"T2"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > sub-${1}_ses-preop_t2.json && rm ${file}
    echo "${file} anonymised"
    mv sub-${1}_ses-preop_t2.json anat
  elif [[ "${file}" == *"FGATIR"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > sub-${1}_ses-preop_fgatir.json && rm ${file}
    echo "${file} anonymised"
    mv sub-${1}_ses-preop_fgatir.json anat
  elif [[ "${file}" == *"SWI"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > sub-${1}_ses-preop_swi.json && rm ${file}
    echo "${file} anonymised"
    mv sub-${1}_ses-preop_swi.json anat
  else mv ${file} dwi
  fi
done

for file in $PWD/dwi/*.json ; do
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > $PWD/dwi/"${file/PAT01/}" && rm ${file}
    echo "${file} anonymised"
done

for file in $PWD/../ses-postop/*.json ; do
  jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > $PWD/../ses-postop/sub-${1}_ses-postop_CT.json && rm ${file}
  echo "${file} anonymised"
done

for file in $PWD/../ses-postop/*.nii.gz ; do
    mv ${file} $PWD/../ses-postop/sub-${1}_ses-postop_CT.nii.gz
    echo "${file} renamed"
done
