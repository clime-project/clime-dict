# ToDo : 下記 wikipedia のページからは 1300 程度しか回収できない。3000 くらいあるらしいので、
# ToDo : どこか別の場所を探す必要がありそう。

OUTFILE="06.emoji.tmp"
TMPFILE="06.$$.tmp"
curl https://ja.wikipedia.org/wiki/Unicode%E3%81%AEEmoji%E3%81%AE%E4%B8%80%E8%A6%A7 > ${TMPFILE}

L1=$(cat ${TMPFILE} | grep -n '^<tbody>'  | cut -d ':' -f 1)
L2=$(cat ${TMPFILE} | grep -n '^</tbody>' | cut -d ':' -f 1)

echo ";;-*-MODE:lisp-*-"  > ${OUTFILE}
echo "("                 >> ${OUTFILE}
cat ${TMPFILE} \
	| head -${L2} \
	| tail -$((L2 - L1 + 1)) \
	| perl -0pe 's@</td>\n<td>@<delim>@g' \
	| perl -0pe 's@\n</td>@<delim>@g' \
	| grep '^<td ' \
	| perl -pe 's@^.+?<delim>(.+)$@\1@' \
	| perl -pe 's@<delim></tr>$@@' \
	| perl -pe 's@<delim>@,@' \
	| perl -0pe 's@<.+?>@@g' \
	| tr [:upper:] [:lower:] | tr ' ' '-' \
	| grep -v '^u+00[0-7]' \
	| perl -pe 's/^u\+(.+?),(.+)$/(#x\1 "\2")/' >> ${OUTFILE}
echo ")"                 >> ${OUTFILE}

rm -f ${TMPFILE}
