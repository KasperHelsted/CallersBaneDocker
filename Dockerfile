FROM alpine

# Set up dependencies
RUN apk add -U openjdk8 mysql-client bash unzip

# Set workdir
ENV SERVER_LOCATION=/opt/server
WORKDIR "$SERVER_LOCATION"


RUN mkdir -p callersbane \
    && wget -P callersbane https://download.scrolls.com/callersbane/server/CallersBane-Server.zip \
    && unzip -d callersbane callersbane/CallersBane-Server.zip \
    && rm callersbane/CallersBane-Server.zip \
    && rm -rf /var/cache/apk/*

# Copy the entrypoint file
COPY "./entrypoiny.sh" "./"
RUN chmod +x ./entrypoiny.sh

EXPOSE 8081-8082

ENTRYPOINT [ "/bin/bash" ]
CMD ["./entrypoiny.sh"]
