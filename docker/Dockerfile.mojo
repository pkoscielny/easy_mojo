FROM perl:5.36.0

# Add same user as host user to prevent from permission problems.
# https://www.fullstaq.com/knowledge-hub/blogs/docker-and-the-host-filesystem-owner-matching-problem
ARG uid
ARG gid
ARG user_name
ARG group_name

RUN cpanm Carton && \
    mkdir /easy_mojo && \
    addgroup --gid $gid $group_name && \
    adduser --uid $uid --gid $gid --gecos "" --disabled-password $user_name

USER $user_name

#COPY . /easy_mojo/

WORKDIR /easy_mojo

# If you want to run Perl without carton.
ENV PATH="/easy_mojo/local/bin:${PATH}"
ENV PERL5LIB="/easy_mojo/local/lib/perl5:${PERL5LIB}"

ENTRYPOINT ["/easy_mojo/docker/mojo_entrypoint.sh"]

EXPOSE 3000
CMD ["carton", "exec", "hypnotoad", "-f", "script/app.pl"]