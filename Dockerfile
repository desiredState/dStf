FROM hashicorp/terraform:light

WORKDIR /desiredstate

COPY dstf.sh .

WORKDIR /data

ENTRYPOINT ["bash", "/desiredstate/dstf.sh"]