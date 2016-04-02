echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=1.8G,vf=1.8G
#$ -l h_rt=4:00:00
#$ -S /bin/bash
#$ -N SLAPcheck
#$ -j y
#$ -cwd
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "SLAP_check_val"