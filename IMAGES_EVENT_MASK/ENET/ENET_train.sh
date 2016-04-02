echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.8G,tmem=7.8G
#$ -l h_rt=96:00:00
#$ -S /bin/bash
#$ -N ENETtrainE
#$ -j y
#$ -cwd
#$ -t 4
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "ENET_train $SGE_TASK_ID"