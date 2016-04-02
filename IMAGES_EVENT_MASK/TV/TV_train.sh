echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.8G,tmem=7.8G
#$ -l h_rt=168:00:00
#$ -S /bin/bash
#$ -N TVtrainE
#$ -j y
#$ -cwd
#$ -t 4
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "TV_train $SGE_TASK_ID"