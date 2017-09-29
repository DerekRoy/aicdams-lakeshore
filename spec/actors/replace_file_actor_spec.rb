# frozen_string_literal: true
require 'rails_helper'

describe ReplaceFileActor do
  let(:user)          { create(:user1) }
  let(:actor)         { CurationConcerns::Actors::ActorStack.new(asset, user, [described_class, Sufia::CreateWithRemoteFilesActor]) }
  let(:file)          { File.open(File.join(fixture_path, "sun.png")) }
  let(:original_file) { Sufia::UploadedFile.create(file: file, user: user, use_uri: AICType.OriginalFileSet) }
  let(:asset)         { create(:asset) }
  let(:file_set)      { create(:intermediate_file_set) }
  let(:attributes)    { ActionController::Parameters.new(uploaded_files: ["1"], permissions_attributes: [], asset_type: nil) }

  before do
    Sufia::UploadedFile.create(id: "1", file: file, user: user, use_uri: AICType.IntermediateFileSet)
    file_set.depositor = "user1"
    file_set.save
    asset.ordered_members = [file_set]
    asset.save
  end

  it "replaces the content of the existing file set" do
    expect(IngestFileJob).to receive(:perform_later).with(
      asset.intermediate_file_set.first,
      end_with("tmp/test-uploads/sufia/uploaded_file/file/1/sun.png"),
      user,
      mime_type: "image/png", relation: "original_file")
    actor.update(attributes)
  end
end
