FROM gcr.io/google.com/cloudsdktool/cloud-sdk:slim

WORKDIR /scripts

COPY snap_delete.sh /scripts/snap_delete.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /scripts/snap_delete.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
