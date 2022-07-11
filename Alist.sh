#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="Alist"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
APACHE_ROOT=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`
export QNAP_QPKG=$QPKG_NAME
export PIDF=/var/run/alist.pid

port=$(cat $QPKG_ROOT/data/config.json | awk -F '"port": '  '{print $2}'| awk '$1=$1'| head -n 1| awk -F ','  '{print $1}')

case "$1" in

  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi
    /bin/ln -sf $QPKG_ROOT /opt/$QPKG_NAME
    : ADD START ACTIONS HERE
     if [ ! -f "$QPKG_ROOT/alist" ]; then
        /sbin/log_tool  -N "Alist" -G "Error" -t1 -uSystem -p127.0.0.1 -mlocalhost -a "[Alist] 启动文件alist丢失，请尝试重新安装插件。"
     fi
     if [ ! -f "$QPKG_ROOT/data/config.json" ];then
     cp $QPKG_ROOT/data/config.json.default $QPKG_ROOT/data/config.json
     fi
      if [ ! -f "$QPKG_ROOT/data/data.db" ];then
     cp $QPKG_ROOT/data/data.db.default $QPKG_ROOT/data/data.db
     fi
         
     cd $QPKG_ROOT     
     ./alist >&1 & disown
     echo $! > $PIDF
    ;;

  stop)
    : ADD STOP ACTIONS HERE
        ID=$(more /var/run/alist.pid)
        if [ -e $PIDF ]; then
            kill -9 $ID
            rm -f $PIDF
            rm -rf /opt/$QPKG_NAME
        fi
    ;;

  restart)
    $0 stop
    $0 start
    ;;
  remove)
    ;;

  *)
    echo "Usage: $0 {start|stop|restart|remove}"
    exit 1
esac

exit 0
