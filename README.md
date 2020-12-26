# panda-bot

Verify that your private Nodejs dependencies works on all projects as intended

# SETUP

## AWS Lambda

Push the docker image to ECR and deploy to a Lambda instance. Set `GIT_EMAIL`, `GIT_PASSWORD`, `GIT_USER_NAME` and `SLACK_BOT_USER_TOKEN` env variables according to your credentials. Set `HOME` to  `/tmp`

Add `HTTP` trigger

## Github

Create a webhook to your lambda function. Select `Branch and Tag Creation` and `Statuses`

You can edit the repos to be checked againts new versions from `REPOS_TO_CHECK` variable at https://github.com/ahmetyalp/panda-bot/blob/master/lib/git.rb
