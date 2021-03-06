# frozen_string_literal: false
require 'rails_helper'

describe Sufia::UploadedFile do
  let(:file) do
    ActionDispatch::Http::UploadedFile.new(filename:     "sun.png",
                                           content_type: "image/png",
                                           tempfile:     File.new(File.join(fixture_path, "sun.png")))
  end
  let(:user) { create(:user1) }

  subject { described_class.new(file: file, user: user, use_uri: use) }

  describe "#use_uri" do
    let(:use) { "http://file.use.uri" }
    its(:use_uri) { is_expected.to eq(use) }
  end
end
