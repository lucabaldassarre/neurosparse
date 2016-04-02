echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.8G,tmem=7.8G
#$ -l h_rt=24:00:00
#$ -S /bin/bash
#$ -N LASSOtrE
#$ -j y
#$ -cwd
#$ -t 1-15
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "LASSO_train $SGE_TASK_ID"