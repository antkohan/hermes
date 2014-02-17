FILES=/opt/mavenDates/*
outfile=fileOut.csv

rm $outfile

for file in $FILES
do
    echo $file
    more $file | perl processFileData.pl $outfile
done