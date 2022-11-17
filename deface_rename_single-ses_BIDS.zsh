#!/bin/zsh

# for single session MRI data: sorts into anat and dwi, BIDS format
# $1 = surgery date 'yyyy-mm-dd'
# $2 = session name, e.g. postop1

#defaces and renames images in bids format and anonymises .json files
# creates image_hds file and slicesdir


# edit path
pathtoses=/Volumes/brydrive/DBS_for_processing/sub-${1}/ses-${2}


# reorient all nifti images
for file in ${pathtoses}/*.nii.gz ; do
  fslreorient2std ${file}
  echo "${file} reoriented"
done

# deface reoriented T1 and FLAIR images and rename all nifti files to image type
# moves files to anat and dwi folders

mkdir ${pathtoses}/anat
mkdir ${pathtoses}/dwi

for file in ${pathtoses}/*.nii.gz ; do
  if [[ "${file}" == *"MPRAGE"* ]] || [[ "${file}" == *"T1"* ]] ; then
    fsl_deface ${file} ${pathtoses}/anat/sub-${1}_ses-${2}_mprage.nii.gz
    echo "MPRAGE defaced and renamed"
  elif [[ "${file}" == *"FLAIR"* ]] ; then
    fsl_deface ${file} ${pathtoses}/anat/sub-${1}_ses-${2}_flair.nii.gz
    echo "FLAIR defaced and renamed"
  elif [[ "${file}" == *"T2"* ]] ; then
    mv ${file} ${pathtoses}/anat/sub-${1}_ses-${2}_t2.nii.gz
    echo "T2 renamed"
  elif [[ "${file}" == *"FGATIR"* ]] ; then
    mv ${file} ${pathtoses}/anat/sub-${1}_ses-${2}_fgatir.nii.gz
    echo "FGATIR renamed"
  elif [[ "${file}" == *"SWI"* ]] ; then
    mv ${file} ${pathtoses}/anat/sub-${1}_ses-${2}_swi.nii.gz
    echo "SWI renamed"
  else mv ${file} ${pathtoses}/dwi
  fi
done

mv ${pathtoses}/*.bval ${pathtoses}/dwi
mv ${pathtoses}/*.bvec ${pathtoses}/dwi

# anonymises and renames .json files

for file in ${pathtoses}/*.json ; do
  if [[ "${file}" == *"MPRAGE"* ]] || [[ "${file}" == *"T1"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${pathtoses}/anat/sub-${1}_ses-${2}_mprage.json && rm ${file}
    echo "${file} anonymised"
  elif [[ "${file}" == *"FLAIR"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${pathtoses}/anat/sub-${1}_ses-${2}_flair.json && rm ${file}
    echo "${file} anonymised"
  elif [[ "${file}" == *"T2"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${pathtoses}/anat/sub-${1}_ses-${2}_t2.json && rm ${file}
    echo "${file} anonymised"
  elif [[ "${file}" == *"FGATIR"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${pathtoses}/anat/sub-${1}_ses-${2}_fgatir.json && rm ${file}
    echo "${file} anonymised"
  elif [[ "${file}" == *"SWI"* ]] ; then
    jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${pathtoses}/anat/sub-${1}_ses-${2}_swi.json && rm ${file}
    echo "${file} anonymised"
  else filename=$(basename ${file})
  jq "del(.PatientName, .PatientID, .AccessionNumber, .PatientBirthDate, .PatientSex, .PatientWeight)" ${file} > ${pathtoses}/dwi/"${filename/PAT01_/}" && rm ${file}
  echo "${file} anonymised"
  fi
done


#create file with fslhd info of all nifti files in anat
for file in ${pathtoses}/anat/*.nii.gz ; do
filename=$(basename ${file} .nii.gz)
echo ${filename}
  fslhd ${file} > ${pathtoses}/anat/${filename}.txt
done

# combines text files and deletes original
for file in ${pathtoses}/anat/*.txt ; do
   cat ${file} >> ${pathtoses}/anat/image_hds.txt && rm ${file}
done

#slicesdir for anat
cd ${pathtoses}/anat/
slicesdir *.nii.gz
cd
