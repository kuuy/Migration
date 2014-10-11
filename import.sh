#/bin/bash -

echo $$ > tmp/import.pid

function import()
{
  link=($(cat link/$1))
  dir=tmp/${1}
  file=${dir}/${2}.${link[5]}
  if [ ! -f $file ]; then
    echo "$file" >> log/error.imp
  fi
  mysql -h127.0.0.1 -P3306 -uroot -p ${link[5]} < ${file}
  rm $file
}

IFS=$'\n'

[ ! -f log/db.exp ] && { exit; }

dbs=($(cat log/db.exp))

dbl=
if [ -f log/db.imp ]; then
  dbl=($(cat log/db.imp))
fi

i=0
while [ "$i" -lt "${#dbs[@]}" ]; do
  db=${dbs[$i]}
  echo 2:$i $db
  [ $dbl ] && [ ${dbl[$i]+qb} ] && { i=$(( $i + 1 )) && continue; }
  
  [ ! -f log/${db}.exp ] && { exit; }
  tbs=($(cat log/${db}.exp))
  
  tbl=
  if [ -f log/${db}.imp ]; then
    tbl=($(cat log/${db}.imp))
  fi
  
  j=0
  while [ "$j" -lt "${#tbs[@]}" ]; do
    tb=${tbs[$j]}
    echo 3:$j $tb
    [ $tbl ] && [ ${tbl[$j]+qb} ] && { j=$(( $j + 1 )) && continue; }
    import $db $tb
    j=$(( $j + 1 ))
    echo "$tb" >> log/${db}.imp
    exit
  done
  i=$(( $i + 1 ))
  echo "$db" >> log/db.imp
  break
done

