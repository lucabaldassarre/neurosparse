echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.8G,vf=7.8G
#$ -l h_rt=96:00:00
#$ -S /bin/bash
#$ -N TVval2
#$ -j y
#$ -cwd
#$ -t 1-14
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "wrapper_TV_val_rerun $SGE_TASK_ID"