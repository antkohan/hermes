FILES=/opt/mavenDates/*
outfile=jarOut.csv

rm $outfile

for file in $FILES
do 
    echo $file
    more $file | perl processJars.pl $outfile
done