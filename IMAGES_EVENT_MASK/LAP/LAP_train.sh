echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.8G,tmem=7.8G
#$ -l h_rt=24:00:00
#$ -S /bin/bash
#$ -N LAPtrainE
#$ -j y
#$ -cwd
#$ -t 15
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "LAP_train $SGE_TASK_ID"