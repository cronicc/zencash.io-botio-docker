FROM zencash/gosu-base:latest

MAINTAINER cronicc@protonmail.com

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get -y update && apt-get --no-install-recommends -y install apt-utils && apt-get -y upgrade \
    && apt-get --no-install-recommends -y install build-essential git ruby-dev nodejs-legacy npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN gem install jekyll bundler 

RUN npm install -g bower gulp

RUN mkdir -p /home/user

RUN git clone https://github.com/cronicc/botio.git /home/user/botio && cd /home/user/botio \
    && npm install -g

RUN git clone https://github.com/cronicc/botio-files-zencash.io.git /home/user/botio-files-zencash.io \
    && cd /home/user/botio-files-zencash.io && npm install

#move /home/user out of the way because it will interfere with user creation in entrypoint.sh
RUN mv /home/user /home/temp

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

ENV NODE_ENV=production

EXPOSE 8000

CMD botio start -u $GITHUB_USER -p $GITHUB_PASS $DEBUG
