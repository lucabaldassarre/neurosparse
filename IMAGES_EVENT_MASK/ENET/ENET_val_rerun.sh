echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.8G,tmem=7.8G
#$ -l h_rt=48:00:00
#$ -S /bin/bash
#$ -N ENETval2
#$ -j y
#$ -cwd
#$ -t 1-300
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "ENET_val_rerun $SGE_TASK_ID"