# frozen_string_literal: true

require 'git'
require 'securerandom'

module GitHelper
  GIT_USER_NAME = ENV['GIT_USER_NAME']
  GIT_USER_PASSWORD = ENV['GIT_PASSWORD']
  GIT_USER_EMAIL = ENV['GIT_EMAIL']

  REPOS_TO_CHECK = ['https://github.com/ahmetyalp/library.git']

  class << self
    def bump_and_push(dependency, version)
      tmp_path = "/tmp/repos/#{SecureRandom.alphanumeric}"

      as_logged_in do
        REPOS_TO_CHECK.each do |repo|
          g = Git.clone(repo, repo.split('/')[-1], path: tmp_path)
          g.checkout("panda-#{dependency}-#{version}", :b => true)
          g.chdir do
            File.open('package.json', 'r+') do |file|
              package = JSON.parse(file.read)
              package['dependencies']['express'] = version # TODO: change 'express' with dependency

              file.rewind
              file.truncate(0)
              file.write JSON.pretty_generate(package)
              file.write "\n"
            end

            system("yarn install --force") # TODO: find better way to produce yarn.lock
          end

          g.commit("Bump #{dependency} version to: #{version}", all: true)
          g.push(remote='origin', branch="panda-#{dependency}-#{version}")
        end
      end

      FileUtils.remove_dir tmp_path
    end

    private

    def as_logged_in(&block)
      Git.global_config('user.email', GIT_USER_EMAIL)
      Git.global_config('user.name', GIT_USER_NAME)
      Git.global_config('user.password', GIT_USER_PASSWORD)

      File.open('/tmp/.git-credentials', 'w') { |f| f.write "https://#{GIT_USER_NAME}:#{GIT_USER_PASSWORD}@github.com" }
      Git.global_config('credential.helper', 'store --file=/tmp/.git-credentials')
      Git.global_config('credential.https://github.com.username', GIT_USER_NAME)

      Git.global_config('http.sslverify', 'false')

      yield block
    end
  end
end
