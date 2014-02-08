FILES=/Users/antkohan/Desktop/testInfo/sigs/*.sigs

outfileClass=sigClassOut.csv
outFileMethod=sigMethOut.csv
outFileAttr=sigAttrOut.csv

rm $outfileClass $outFileMethod $outFileAttr

for file in $FILES
do
    more $file | perl processSignatures.pl $outfileClass $outFileMethod $outFileAttr
done