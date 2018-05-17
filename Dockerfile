FROM hashicorp/terraform:light
RUN apk --no-cache add bash ncurses
WORKDIR /desiredstate
COPY dstf.sh .
WORKDIR /data
ENTRYPOINT ["bash", "/desiredstate/dstf.sh"]
