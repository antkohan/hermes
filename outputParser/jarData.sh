FILES=/home/tony/Documents/Work/testInfo/output/*
outfile=jarOut.csv

rm $outfile

for file in $FILES
do 
    more $file | perl processJars.pl $outfile
done