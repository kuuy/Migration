#/bin/bash -

echo $$ > tmp/export.pid

function export()
{
  link=($(cat link/$1))
  dir=tmp/${1}
  file=${dir}/${2}.${link[5]}
  if [ ! -d $dir ]; then
    mkdir $dir
  fi
  if [ -f $file ]; then
    rm $file
  fi
  
  mysqldump --host=${link[0]} --port ${link[1]} -u${link[2]} -p${link[3]} --databases $1 --tables ${link[4]} --default-character-set=${link[5]} --lock-tables=false  --force > ${file}
}

IFS=$'\n'

dbs=($(cat db.list))
dbl=
if [ -f log/db.exp ]; then
  dbl=($(cat log/db.exp))
fi

i=0
while [ "$i" -lt "${#dbs[@]}" ]; do
  db=${dbs[$i]}
  echo 0:$i $db
  [ $dbl ] && [ ${dbl[$i]+qb} ] && { i=$(( $i + 1 )) && continue; }
  tbs=($(cat tbl/$db))
  tbl=
  if [ -f log/${db}.exp ]; then
    tbl=($(cat log/${db}.exp))
  fi
  j=0
  while [ "$j" -lt "${#tbs[@]}" ]; do
    tb=${tbs[$j]}
    echo 1:$j $tb
    [ $tbl ] && [ ${tbl[$j]+qb} ] && { j=$(( $j + 1 )) && continue; }
    export $db $tb
    j=$(( $j + 1 ))
    echo "$tb" >> log/${db}.exp
    exit
  done
  i=$(( $i + 1 ))
  echo "$db" >> log/db.exp
  break
done

