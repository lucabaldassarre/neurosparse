echo $HOSTNAME
#!/bin/sh
#$ -l h_vmem=3.8G,tmem=3.8G
#$ -l h_rt=4:00:00
#$ -S /bin/bash
#$ -N SLAPpars
#$ -j y
#$ -cwd
/share/apps/matlabR2011b/bin/matlab -nojvm -nodesktop -nodisplay -nosplash -singleCompThread -r "compute_val_errs"