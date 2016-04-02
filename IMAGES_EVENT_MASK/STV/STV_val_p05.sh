echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=7.9G,tmem=7.9G
#$ -l h_rt=48:00:00
#$ -S /bin/bash
#$ -N STVvalE
#$ -j y
#$ -cwd
#$ -t 645-2100
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "STV_val_p05 $SGE_TASK_ID"