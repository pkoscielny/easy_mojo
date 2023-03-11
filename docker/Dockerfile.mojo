FROM perl:5.36.0

# Add same user as host user to prevent from permission problems.
# https://www.fullstaq.com/knowledge-hub/blogs/docker-and-the-host-filesystem-owner-matching-problem
ARG uid
ARG gid
ARG user_name
ARG group_name

RUN apt update && \
    apt upgrade -y && \
    apt install -y apt-utils sqlite3 && \
    cpanm Carton && \
    mkdir /easy_mojo && \
# Install liquibase:
    apt install -y default-jre && \
    wget --quiet https://github.com/liquibase/liquibase/releases/latest/download/liquibase-4.20.0.tar.gz && \
    mkdir /liquibase && \
    tar xzf liquibase-4.20.0.tar.gz -C /liquibase && \
# Create compatible user with host user:
    addgroup --gid $gid $group_name && \
    adduser --uid $uid --gid $gid --gecos "" --disabled-password $user_name

USER $user_name

#COPY . /easy_mojo/

WORKDIR /easy_mojo

ENV PATH="/liquibase:/easy_mojo/local/bin:${PATH}"
ENV PERL5LIB="/easy_mojo/local/lib/perl5:${PERL5LIB}"

ENTRYPOINT ["/easy_mojo/docker/mojo_entrypoint.sh"]

EXPOSE 3000
CMD ["carton", "exec", "hypnotoad", "-f", "script/app.pl"]