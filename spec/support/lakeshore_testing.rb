# frozen_string_literal: true

require 'active_fedora/cleaner'

class LakeshoreTesting
  class << self
    # Removes all resources from Fedora and Solr and restores
    # the repository to a minimal testing state
    def restore
      ActiveFedora::Cleaner.clean!
      cleanout_redis
      reset_derivatives
      reset_uploads
      ListManager.new(File.join(Rails.root, "config/lists/status.yml")).create
      ActiveFedora::Base.all.map(&:update_index)
    end

    def cleanout_redis
      Redis.current.keys.map { |key| Redis.current.del(key) }
    rescue => e
      Logger.new(STDOUT).warn "WARNING -- Redis might be down: #{e}"
    end

    def continuous_integration?
      ENV.fetch("TRAVIS", false)
    end

    def reset_derivatives
      FileUtils.rm_rf("#{Rails.root}/tmp/test-derivatives")
      FileUtils.mkdir_p("#{Rails.root}/tmp/test-derivatives")
      Sufia.config.derivatives_path = "#{Rails.root}/tmp/test-derivatives"
    end

    def reset_uploads
      FileUtils.rm_rf("#{Rails.root}/tmp/test-uploads")
      FileUtils.mkdir_p("#{Rails.root}/tmp/test-uploads")
      Sufia.config.upload_path = ->() { Rails.root + 'tmp' + 'test-uploads' }
    end
  end
end

RSpec.configure do |config|
  # Clean out everything and create required fixtures
  config.before :suite do
    LakeshoreTesting.restore
  end

  # Clean out everything before each feature test
  config.before :each do |example|
    LakeshoreTesting.restore if example.metadata[:type] == :feature
  end
end
