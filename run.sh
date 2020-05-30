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
}' | tee $RESULT_DIR/purchase.summary.month.txt | sort -t $'\t' -k 3rn | head -n 5

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
