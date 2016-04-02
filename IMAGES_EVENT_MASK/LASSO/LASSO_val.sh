echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.9G,tmem=7.9G
#$ -l h_rt=24:00:00
#$ -S /bin/bash
#$ -N LASSOvalE
#$ -j y
#$ -cwd
#$ -t 4-210
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "LASSO_val $SGE_TASK_ID"