FILES=/home/anthony/Documents/testInfo/output/*
outfile=jarOut.csv

rm $outfile

for file in $FILES
do 
    more $file | perl processJars.pl $outfile
done