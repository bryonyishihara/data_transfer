#!/bin/zsh

#create file with fslhd info of all nifti files
for file in *.nii.gz ; do
filename=$(basename ${file} .nii.gz)
echo ${filename}
  fslhd ${file} > ${filename}.txt
done

# combines text files and deletes original
# && only executes second command if first is successful
for file in *.txt ; do
   cat ${file} >> image_hds.txt && rm ${file}
done
