FROM amazon/aws-lambda-ruby:2.7

RUN yum install -y git tar
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n \
  && bash n 8.16.0
RUN npm install -g yarn@1.21.1

WORKDIR ${LAMBDA_TASK_ROOT}

ADD Gemfile* ./

RUN bundle config set --global frozen 'true' \
  && bundle config set --global without 'development test'\
  && bundle install --path=./vendor/bundle --retry 3

COPY lib ./lib
COPY app.rb .

CMD ["app.App::Handler.process"]
