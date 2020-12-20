FROM amazon/aws-lambda-ruby:2.7

WORKDIR ${LAMBDA_TASK_ROOT}

ADD Gemfile* ./

RUN bundle config set --global frozen 'true' \
  && bundle config set --global without 'development test'\
  && bundle install --path=./vendor/bundle --retry 3

COPY app.rb .

CMD ["app.App::Handler.process"]
