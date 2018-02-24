# frozen_string_literal: true
require 'rails_helper'

describe DuplicateUploadVerificationService do
  let(:uploaded_file)  { create(:uploaded_file) }
  let(:service)        { described_class.new(uploaded_file) }
  let(:file_digest)    { uploaded_file.checksum }
  let(:asset)          { create(:asset) }
  let(:duplicate_file) { double }

  subject { service.duplicates }

  describe "#duplicates" do
    context "when no duplicates exist" do
      before { allow(FileSet).to receive(:where).with(digest_ssim: file_digest).and_return([]) }
      it "returns an empty array" do
        is_expected.to be_empty
      end
    end

    context "when duplicates exist" do
      before do
        allow(duplicate_file).to receive(:parent).and_return(asset)
        allow(FileSet).to receive(:where).with(digest_ssim: file_digest).and_return([duplicate_file])
      end

      it "returns the duplicate asset" do
        is_expected.to contain_exactly(asset)
      end
    end
  end

  describe "::unique?" do
    subject { described_class.unique?(uploaded_file) }
    context "when no duplicates exist" do
      before { allow(FileSet).to receive(:where).with(digest_ssim: file_digest).and_return([]) }
      it { is_expected.to be(true) }
    end
  end
end
