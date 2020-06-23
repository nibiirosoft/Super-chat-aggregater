#!/bin/bash
export LC_ALL=C
export LANG=C

CHANNELID=UCL-2thbJ7grC9fmGF4OLuTg

if [ "$1" != "" ]; then
  CHANNELID=$1
fi

SCRIPT_DIR=$(cd $(dirname $(readlink -f $0 || echo $0));pwd -P)

TAX=$(cat $SCRIPT_DIR/config.txt | grep TAX | cut -f 2)
FEE=$(cat $SCRIPT_DIR/config.txt | grep FEE | cut -f 2)
MARGIN=$(cat $SCRIPT_DIR/config.txt | grep MARGIN | cut -f 2)

echo "ChannelId=$CHANNELID, Tax=$TAX, Fee=$FEE, Margin=$MARGIN"

i=0
while true; do
  echo "["`date +'%Y/%m/%d %H:%M:%S'`"]" "[wget] $CHANNELID toppage"
  data=$(wget --no-check-certificate --no-cache --no-cookies --content-on-error=on "https://www.youtube.com/channel/$CHANNELID/videos?sort=da" -qO -)

  if echo -e "$data" | grep '404 Not Found' >/dev/null; then
    echo "Error: ChannelId '$CHANNELID' was not found. (404 Not Found)"
    exit
  fi

  if echo -e "$data" | grep 'watch?v=' >/dev/null; then
    TITLE=$(echo -e "$data" | grep 'g:title" content="' | sed 's/^.*content="\([^"]*\)">$/\1/' | sed 's/ \/ /_/g' | sed 's/[ \&/]/_/g')
    echo "Title=$TITLE"

    RESULT_DIR="${CHANNELID}_${TITLE}"
    #rm -rf $RESULT_DIR
    mkdir -p $RESULT_DIR
    break
  fi

  i=$((i+1))
  if [ $i > 3 ]; then
    echo "Error: video id was not found in '$CHANNELID' toppage."
    exit
  fi
done

rm -f $RESULT_DIR/watch.list.txt
while true; do
  videoIds=$(echo -e "$data" | grep 'watch?v=' | sed -e 's/^.*watch?v=\([^"]*\)".*$/\1/' | sed -e 's/\\//' | awk '!a[$0]++')
  echo -e "$videoIds" >> $RESULT_DIR/watch.list.txt

  n=$(echo -e "$videoIds" | wc -l)
  videoIds_n=$((videoIds_n + n))

  continuation=$(echo -e "$data" | grep 'continuation=' | sed -e 's/^.*;continuation=\([^"&]*\)[&"].*$/\1/' | sed -e 's/\\//')

  if [ "$continuation" == "" ]; then
    break
  fi

  while true; do
    echo "["`date +'%Y/%m/%d %H:%M:%S'`"]" "[wget] videos #$videoIds_n"
    data=$(wget --no-check-certificate --no-cache --no-cookies --content-on-error=on "https://www.youtube.com/browse_ajax?continuation=$continuation" -qO -)

    if echo -e "$data" | head -n 1 | grep -v reload >/dev/null; then
      break
    fi
  done
done

i=0
n=$(cat $RESULT_DIR/watch.list.txt | wc -l)
rm -f $RESULT_DIR/purchase.list.txt $RESULT_DIR/purchase.list2.txt $RESULT_DIR/purchase.summary.video.txt
cat $RESULT_DIR/watch.list.txt | while read id; do
  i=$((i+1))
  url="https://www.youtube.com/watch?v=$id"

  echo "["`date +'%Y/%m/%d %H:%M:%S'`"]" "[get_super_chat.py] (#$i/$n) videoId=$id"
  $SCRIPT_DIR/bin/get_super_chat.py "$url" | sed 's/\xc2\xa0//g' | sed 's/\xef\xbf\xa5/\\/g' | sed 's/\xc2\xa3/GBP/g' | sed 's/\xe2\x82\xa9/KPW/g' | sed 's/\xe2\x82\xb9/INR/g' | sed 's/\xe2\x82\xac/EUR/g' | tee -a $RESULT_DIR/purchase.list.txt | awk -F '\t' 'BEGIN{OFS="\t";
    while(getline < "'$SCRIPT_DIR/config.txt'") {
      if ($1!=""){
        xe[$1] = $2;
      }
    }
  }{
    id = $1;
    date = $2;
    name = $3;
    c = $4;
    amount = $5;
    comment = $6;
    add = 0;
    if(xe[c] > 0){
      add = amount * xe[c];
    }
    else{
      add = 0;
      print c, amount >> "'$RESULT_DIR/purchase.summary.other.txt'";
    }
    total += int(add);
    print id, date, name, add, comment;
  }END{
    if(total > 0){
      print id, date, total >> "'$RESULT_DIR/purchase.summary.video.txt'"
    }
  }' >> $RESULT_DIR/purchase.list2.txt
done


echo '----'
cat $RESULT_DIR/purchase.summary.video.txt | sort -t $'\t' -k 3rn | head -n 5

echo '----'
cat $RESULT_DIR/purchase.list2.txt | awk -F '\t' 'BEGIN{OFS="\t";OFMT="%.0f"}{
  split($2, array, "-");
  total[array[1]"-"array[2]] += $4;
}END{
  for(month in total){
    print month, total[month], int(total[month]/1000)/10"万";
  }
}' | sort | tee $RESULT_DIR/purchase.summary.month.txt | sort -t $'\t' -k 3rn | head -n 5

echo '----'
cat $RESULT_DIR/purchase.list2.txt | awk -F '\t' 'BEGIN{OFS="\t";OFMT="%.0f"}{
  split($2, array, "-");
  total[array[1]] += $4;
}END{
  for(year in total){
    print year, total[year], int(total[year]/1000)/10"万";
  }
}' | tee $RESULT_DIR/purchase.summary.year.txt

echo -e "Total	Tax($(echo "$TAX*100/1" | bc)%)	Fee($(echo "$FEE*100/1" | bc)%)	Margin($(echo "$MARGIN*100/1" | bc)%)	Profit" > $RESULT_DIR/purchase.summary.total.txt
cat $RESULT_DIR/purchase.list2.txt | awk -F '\t' 'BEGIN{OFS="\t";}{
  total += int($4);
}END{
  print total;
}' | awk -F '\t' '{OFS="\t";}{
  a = $1*(1-1/(1+'$TAX'));
  b = ($1-a)*'$FEE';
  c = ($1-a-b)*'$MARGIN';
  d = $1-a-b-c;
  printf "%.1f万	%.1f万	%.1f万	%.1f万	%.1f万\n", int($1/10000), int(a/10000), int(b/10000), int(c/10000), int(d/10000);
}' >> $RESULT_DIR/purchase.summary.total.txt

echo '----'
cat $RESULT_DIR/purchase.summary.total.txt

cat $RESULT_DIR/purchase.list2.txt | awk -F '\t' '{OFS="\t";}{
  a[$3] += $4;
}END{
  for(id in a){
    print id, a[id], int(a[id]/1000)/10"万";
  }
}' |  sort -t $'\t' -k 2rn > $RESULT_DIR/purchase.summary.name.txt

echo '----'
cat $RESULT_DIR/purchase.summary.name.txt | head -n 5

echo '----'
cat $RESULT_DIR/purchase.summary.other.txt 2>/dev/null

rm -f $RESULT_DIR/purchase.summary.name.*.txt
cat $RESULT_DIR/purchase.summary.name.txt | head -n 5 | awk -F '\t' '{OFS="\t";}{
  name = $1;

  file = "'$RESULT_DIR/purchase.list2.txt'";
  while(getline < file) {
    if(oldId!="" && oldId!=$1){
      print oldId, oldDate, name, pay, int(pay/(pay+other)*1000)/10"%" >> "'$RESULT_DIR/purchase.summary.name.'"name".txt"
      pay = 0;
      other = 0;
    }
    if($3==name){
      pay += $4;
    }
    else{
      other += $4;
    }

    oldId = $1;
    oldDate = $2;
  }
  close(file);

  print oldId, oldDate, name, pay, int(pay/(pay+other)*1000)/10"%" >> "'$RESULT_DIR/purchase.summary.name.'"name".txt"
}'
