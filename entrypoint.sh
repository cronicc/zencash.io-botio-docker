#!/bin/bash

# Add local user
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}
GRP_ID=${LOCAL_GRP_ID:-9001}

echo "Starting with UID/GID : $USER_ID/$GRP_ID"
groupadd -g $GRP_ID user
useradd --shell /bin/bash -u $USER_ID -g $GRP_ID -o -c "" -m user
export HOME=/home/user/botio-files-zencash.io

#if a webhook secret was provided, update botio config with it
if [[ -v GITHUB_SECRET ]] && [ -e "/home/temp/botio-files-zencash.io/config.json" ] && ! grep -q github_secret /home/temp/botio-files-zencash.io/config.json ; then
  #remove the last occurrence of } and remove trailing newlines
  sed -i '1h;1!H;$!d;g;s/\(.*\)}/\1/' /home/temp/botio-files-zencash.io/config.json \
  && sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' /home/temp/botio-files-zencash.io/config.json \
  && truncate -s -1 /home/temp/botio-files-zencash.io/config.json \
  && echo -e ',\n  "github_secret": "'$GITHUB_SECRET'"\n}\n' >> /home/temp/botio-files-zencash.io/config.json
fi

#copy back the temporary user folder
if [ -d "/home/temp" ]; then
  chown -R $USER_ID:$GRP_ID /home/temp \
  && cd /home/temp && find ./ -maxdepth 1 -mindepth 1 -exec mv -t /home/user {} + \
  && cd && rm -r /home/temp
fi

exec /usr/local/bin/gosu user "$@"
