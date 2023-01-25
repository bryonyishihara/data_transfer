#!/bin/zsh

# for DBS data with preop mri and postop CT
#${1} = subject ID
# have files sorted into ses-preop and ses-postop
# run from DBS_dicom_nifti directory containing all sub-yyyy-mm-dd folders

#defaces and renames images in bids format and anonymises .json files

preop_path=${PWD}/sub-${1}/ses-preop
postop_path=${PWD}/sub-${1}/ses-postop

# reorient all nifti images
for file in ${preop_path}/*.nii.gz ; do
  fslreorient2std ${file}
  echo "${file} reoriented"
done

# deface reoriented T1 and FLAIR images and rename all nifti files to image type
# moves files to anat and dwi folders

mkdir ${preop_path}/anat
mkdir ${preop_path}/dwi

for file in ${preop_path}/*.nii.gz ; do
  if [[ "${file}" == *"MPRAGE"* ]] || [[ "${file}" == *"T1"* ]] ; then
    fsl_deface ${file} ${preop_path}/anat/sub-${1}_ses-preop_mprage.nii.gz
    echo "MPRAGE defaced and renamed"
  elif [[ "${file}" == *"FLAIR"* ]] ; then
    fsl_deface ${file} ${preop_path}/anat/sub-${1}_ses-preop_flair.nii.gz
    echo "FLAIR defaced and renamed"
  elif [[ "${file}" == *"T2"* ]] ; then
    mv ${file} ${preop_path}/anat/sub-${1}_ses-preop_t2.nii.gz
    echo "T2 renamed"
  elif [[ "${file}" == *"FGATIR"* ]] ; then
    mv ${file} ${preop_path}/anat/sub-${1}_ses-preop_fgatir.nii.gz
    echo "FGATIR renamed"
  elif [[ "${file}" == *"SWI"* ]] ; then
    mv ${file} ${preop_path}/anat/sub-${1}_ses-preop_swi.nii.gz
    echo "SWI renamed"
  else mv ${file} ${preop_path}/dwi
  fi
done

mv ${preop_path}/*.bval ${preop_path}/dwi
mv ${preop_path}/*.bvec ${preop_path}/dwi

# anonymises and renames .json files

for file in ${preop_path}/*.json ; do
  if [[ "${file}" == *"MPRAGE"* ]] || [[ "${file}" == *"T1"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${preop_path}/anat/sub-${1}_ses-preop_mprage.json && rm ${file}
    echo "${file} anonymised"
  elif [[ "${file}" == *"FLAIR"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${preop_path}/anat/sub-${1}_ses-preop_flair.json && rm ${file}
    echo "${file} anonymised"
  elif [[ "${file}" == *"T2"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${preop_path}/anat/sub-${1}_ses-preop_t2.json && rm ${file}
    echo "${file} anonymised"
  elif [[ "${file}" == *"FGATIR"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${preop_path}/anat/sub-${1}_ses-preop_fgatir.json && rm ${file}
    echo "${file} anonymised"
  elif [[ "${file}" == *"SWI"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${preop_path}/anat/sub-${1}_ses-preop_swi.json && rm ${file}
    echo "${file} anonymised"
  else mv ${file} ${preop_path}/dwi
  fi
done

for file in ${preop_path}/dwi/*.json ; do
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${preop_path}/dwi/"${file/PAT01_/}" && rm ${file}
    echo "${file} anonymised"
done

for file in ${postop_path}/*.json ; do
  jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${postop_path}/sub-${1}_ses-postop_CT.json && rm ${file}
  echo "${file} anonymised"
done

for file in ${postop_path}/*.nii.gz ; do
    mv ${file} ${postop_path}/sub-${1}_ses-postop_CT.nii.gz
    echo "${file} renamed"
done

