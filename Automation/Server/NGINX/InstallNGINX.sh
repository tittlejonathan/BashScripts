#!/usr/bin/env bash
#+----------------------------------------------------------------------------+
#+ BashScripts/Automation/Server/NGINX/InstallNGINX.sh
#+----------------------------------------------------------------------------+
#+ 1). This is designed for use on Debian/Ubuntu only (for the time being).
#+ 2). This is the initial commit; it does the job, but needs optimizing.
#+ 3). This is mainly used on deployments that also have PHP (see packages).
#+----------------------------------------------------------------------------+
#+ @github      https://github.com/tittlejonathan/BashScripts
#+----------------------------------------------------------------------------+
#+ 2016-20-01   Initial Commit - Intended as a "Quick" Auto-Install
#+----------------------------------------------------------------------------+
clear

#+----------------------------------------------------------------------------+
#+ Initial System Setup
#+----------------------------------------------------------------------------+
#+ Syncronize Packages against OS Repositories, Upgrade Existing and Install
#+ Packages required for NGINX (as well as *some* packages needed for PHP).
#+----------------------------------------------------------------------------+
apt-get update && apt-get upgrade -y

apt-get install -y apt-transport-https apt-utils autoconf automake bc bison build-essential ccache chrpath cmake curl flex gcc gcovr git-core google-perftools g++ icu-devtools lcov libapt-pkg-dev libbz2-dev libcurl4-openssl-dev libedit-dev libenchant-dev libevent-core-2.0-5 libevent-dev libevent-extra-2.0-5 libevent-openssl-2.0-5 libevent-pthreads-2.0-5 libgmp-dev libgoogle-perftools-dev libicu-dev libjpeg-dev libjpeg62-turbo-dev libltdl-dev liblzma-dev libmagic-dev libmcrypt-dev libmhash-dev libpspell-dev libreadline-dev librecode-dev libssl-dev libsystemd-dev libtidy-dev libvpx-dev libxml2-dev libxmltok1-dev libxpm-dev libxslt1-dev libxt-dev libzthread-dev make pbzip2 pkg-config python python-software-properties python3-software-properties re2c rng-tools snmp software-properties-common uuid-dev

#+----------------------------------------------------------------------------+
#+ Storage
#+----------------------------------------------------------------------------+
storageDir="/usr/local/src"

#+----------------------------------------------------------------------------+
#+ NGINX Configuration: Directories
#+----------------------------------------------------------------------------+
nginxBase="/etc/nginx"
nginxSbin="/usr/sbin/nginx"
nginxCache="${nginxBase}/cache"
nginxCacheFastCgi="${nginxCache}/fastcgi"
nginxCacheClient="${nginxCache}/client"
nginxCacheProxy="${nginxCache}/proxy"
nginxCacheUwsgi="${nginxCache}/uwsgi"
nginxCacheScgi="${nginxCache}/scgi"
nginxConfd="${nginxBase}/conf"
nginxConfdServer="${nginxConfd}/server"
nginxConfdDomains="${nginxConfd}/domains"
nginxLogs="${nginxBase}/logs"
nginxLogsDomains="${nginxLogs}/domains"
nginxLogsServer="${nginxLogs}/server"
nginxLogsServerAccess="${nginxLogsServer}/access"
nginxLogsServerError="${nginxLogsServer}/error"
nginxSsl="${nginxBase}/ssl"
nginxTmp="${nginxBase}/tmp"

#+----------------------------------------------------------------------------+
#+ NGINX Configuration: Files
#+----------------------------------------------------------------------------+
nginxConf="${nginxConfdServer}/nginx.conf"
nginxLock="${nginxTmp}/nginx.lock"
nginxAccessLog="${nginxLogsServerAccess}/access.log"
nginxErrorLog="${nginxLogsServerError}/error.log"
nginxPid="${nginxTmp}/nginx.pid"

#+----------------------------------------------------------------------------+
#+ NGINX
#+----------------------------------------------------------------------------+
nginxVersion="1.9.9"
nginxDirectory="${storageDir}/nginx-${nginxVersion}"
nginxFileName="nginx-${nginxVersion}.tar.gz"
nginxArchive="http://nginx.org/download/${nginxFileName}"

#+----------------------------------------------------------------------------+
#+ ZLib
#+----------------------------------------------------------------------------+
zlibVersion="1.2.8"
zlibDirectory="${storageDir}/zlib-${zlibVersion}"
zlibFileName="zlib-${zlibVersion}.tar.gz"
zlibArchive="http://zlib.net/${zlibFileName}"

#+----------------------------------------------------------------------------+
#+ PCRE
#+----------------------------------------------------------------------------+
pcreVersion="8.37"
pcreDirectory="${storageDir}/pcre-${pcreVersion}"
pcreFileName="pcre-${pcreVersion}.tar.gz"
pcreArchive="http://sourceforge.net/projects/pcre/files/pcre/${pcreVersion}/${pcreFileName}/download"

#+----------------------------------------------------------------------------+
#+ NGINX User & Group
#+----------------------------------------------------------------------------+
nginxUser="nginx"
nginxGroup="nginx"

#+----------------------------------------------------------------------------+
#+ Create Directories
#+----------------------------------------------------------------------------+
mkdir -p ${nginxBase}
mkdir -p ${nginxCacheFastCgi}
mkdir -p ${nginxCacheClient}
mkdir -p ${nginxCacheProxy}
mkdir -p ${nginxCacheUwsgi}
mkdir -p ${nginxCacheScgi}
mkdir -p ${nginxConfdServer}
mkdir -p ${nginxConfdDomains}
mkdir -p ${nginxLogsDomains}
mkdir -p ${nginxLogsServerAccess}
mkdir -p ${nginxLogsServerError}
mkdir -p ${nginxSsl}
mkdir -p ${nginxTmp}

#+----------------------------------------------------------------------------+
#+ Create User:Group
#+----------------------------------------------------------------------------+
useradd -M -d /etc/nginx nginx

#+----------------------------------------------------------------------------+
#+ Download Required Files
#+----------------------------------------------------------------------------+
cd ${storageDir}
wget ${nginxArchive} -O ${nginxFileName}
wget ${zlibArchive} -O ${zlibFileName}
wget ${pcreArchive} -O ${pcreFileName}
tar -zxf "${storageDir}/${nginxFileName}"
tar -zxf "${storageDir}/${zlibFileName}"
tar -zxf "${storageDir}/${pcreFileName}"

#+----------------------------------------------------------------------------+
#+ Run NGINX Configure
#+----------------------------------------------------------------------------+
cd ${nginxDirectory}

./configure                                                                 \
--prefix=${nginxBase}                                                       \
--sbin-path=${nginxSbin}                                                    \
--conf-path=${nginxConf}                                                    \
--pid-path=${nginxPid}                                                      \
--error-log-path=${nginxErrorLog}                                           \
--http-log-path=${nginxAccessLog}                                           \
--user=${nginxUser}                                                         \
--group=${nginxGroup}                                                       \
--lock-path=${nginxLock}                                                    \
--http-client-body-temp-path=${nginxCacheClient}                            \
--http-proxy-temp-path=${nginxCacheProxy}                                   \
--http-fastcgi-temp-path=${nginxCacheFastCgi}                               \
--http-uwsgi-temp-path=${nginxCacheUwsgi}                                   \
--http-scgi-temp-path=${nginxCacheScgi}                                     \
--with-threads                                                              \
--with-file-aio                                                             \
--with-http_ssl_module                                                      \
--with-http_v2_module                                                       \
--with-http_realip_module                                                   \
--with-http_addition_module                                                 \
--with-http_gunzip_module                                                   \
--with-http_gzip_static_module                                              \
--with-pcre="${pcreDirectory}"                                              \
--with-pcre-jit                                                             \
--with-zlib="${zlibDirectory}"                                              \
--with-stream                                                               \
--with-stream_ssl_module                                                    \
--with-google_perftools_module

make && make install

#+----------------------------------------------------------------------------+
#+ Copy Configuration to /etc/nginx/conf/*
#+----------------------------------------------------------------------------+
cp -R "${PWD}/*" "${nginxConfdServer}"

#+----------------------------------------------------------------------------+
#+ Clean Up
#+----------------------------------------------------------------------------+
rm "${nginxConfdServer}/*.default"
rm -rf ${nginxDirectory}
rm -rf ${pcreDirectory}
rm -rf ${zlibDirectory}
rm "${storageDir}/${nginxFileName}"
rm "${storageDir}/${zlibFileName}"
rm "${storageDir}/${pcreFileName}"