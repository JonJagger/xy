FROM cyberdojo/sinatra-base
LABEL maintainer=jon@jaggersoft.com

COPY --chown=nobody:nogroup . /app

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG XY_PORT
ENV PORT=${XY_PORT}
EXPOSE ${PORT}

USER nobody
CMD [ "/app/up.sh" ]
