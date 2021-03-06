# frozen_string_literal: true
require 'rails_helper'

describe GenericWork do
  let(:user)         { create(:user1) }
  let(:example_file) { create(:asset) }

  subject { described_class.new }

  describe "::human_readable_type" do
    subject { described_class.human_readable_type }
    it { is_expected.to eq("Asset") }
  end

  context "without setting a type" do
    subject { build(:asset_without_type) }
    it "raises and error" do
      expect(-> { subject.save }).to raise_error(ArgumentError, "Can't mint a UID without a prefix")
    end
  end

  describe "intial RDF types" do
    subject { described_class.new.type }
    it { is_expected.to include(AICType.Asset, AICType.Resource) }
  end

  describe "asserting StillImage" do
    subject { build(:asset) }

    specify { expect(subject.type).to include(AICType.Asset, AICType.StillImage) }

    describe "#to_solr" do
      let(:keyword) { create(:list_item) }

      before { subject.keyword = [keyword.uri] }

      it "contains our custom solr fields" do
        expect(subject.to_solr[Solrizer.solr_name("aic_type", :facetable)]).to include("Asset", "Still Image")
        expect(subject.to_solr[Solrizer.solr_name("keyword", :facetable)]).to contain_exactly(keyword.pref_label)
        expect(subject.to_solr[Solrizer.solr_name("keyword", :stored_searchable)]).to contain_exactly(keyword.pref_label)
      end
    end

    describe "minting uids" do
      let(:hash)  { Digest::MD5.hexdigest(subject.uid) }
      let(:dhash) { [hash[0, 8], hash[8, 4], hash[12, 4], hash[16, 4], hash[20..-1]].join('-') }

      before { subject.save }

      it "uses a checksum as a path" do
        expect(subject.id).to match(/^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/)
        expect(subject.id).to eql(dhash)
      end
    end
  end

  describe "setting type to Text" do
    subject { build(:text_asset) }
    specify { expect(subject.type).to include(AICType.Asset, AICType.Text) }

    describe "#to_solr" do
      specify { expect(subject.to_solr[Solrizer.solr_name("aic_type", :facetable)]).to include("Asset", "Text") }
    end

    describe "minting uids" do
      let(:hash)  { Digest::MD5.hexdigest(subject.uid) }
      let(:dhash) { [hash[0, 8], hash[8, 4], hash[12, 4], hash[16, 4], hash[20..-1]].join('-') }

      before { subject.save }

      it "uses a checksum as a path" do
        expect(subject.id).to match(/^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/)
        expect(subject.id).to eql(dhash)
      end
    end
  end

  describe "metadata" do
    context "defined in the presenter" do
      AssetPresenter.terms.each do |term|
        it { is_expected.to respond_to(term) }
      end
    end
  end

  describe "cardinality" do
    [:capture_device, :dept_created, :digitization_source, :compositing, :light_type, :transcript].each do |term|
      it "limits #{term} to a single value" do
        expect(described_class.properties[term.to_s].multiple?).to be false
      end
    end
  end

  describe "#asset_has_relationships?" do
    let!(:work) { create(:still_image_asset, user: user, title: ["Hello Title"]) }
    context "with relationships" do
      before { allow_any_instance_of(InboundRelationships).to receive(:present?).and_return(true) }
      it { is_expected.to be_asset_has_relationships }
    end
    context "without relationships" do
      it { is_expected.not_to be_asset_has_relationships }
    end
  end

  describe "#uid" do
    context "when changed" do
      subject do
        example_file.uid = "1234"
        example_file.save
        example_file.errors
      end
      its(:full_messages) { is_expected.to include("Uid must match checksum") }
    end

    context "when overriding" do
      let(:custom_uid) { build(:asset, uid: "SI-101010") }
      let(:hash)       { UidMinter.new("SI").hash("SI-101010") }
      before { custom_uid.save }
      subject { custom_uid }
      its(:id) { is_expected.to eq(hash) }
    end
  end

  describe "#title" do
    let(:work) { described_class.new }
    subject { work.title.first }
    context "without a pref_label" do
      it { is_expected.to be_nil }
    end
    context "without a pref_label" do
      let(:work) { described_class.create(pref_label: "A Label") }
      it { is_expected.to eq("A Label") }
    end
  end

  describe "::accepts_uris_for" do
    let(:work) { build(:asset) }
    let(:item) { create(:list_item) }

    context "using a multi-valued term" do
      subject { work }

      context "with a string" do
        before { work.keyword_uris = [item.uri.to_s] }
        its(:keyword) { is_expected.to contain_exactly(item) }
        its(:keyword_uris) { is_expected.to contain_exactly(item.uri.to_s) }
      end

      context "with a RDF::URI" do
        before { work.keyword_uris = [item.uri] }
        its(:keyword) { is_expected.to contain_exactly(item) }
        its(:keyword_uris) { is_expected.to contain_exactly(item.uri.to_s) }
      end

      context "with a singular value" do
        it "raises an ArgumentError" do
          expect { work.keyword_uris = item.uri }.to raise_error(ArgumentError)
        end
      end

      context "with empty strings" do
        before { work.keyword_uris = [""] }
        its(:keyword) { is_expected.to be_empty }
        its(:keyword_uris) { is_expected.to be_empty }
      end

      context "with empty arrays" do
        before { work.keyword_uris = [] }
        its(:keyword) { is_expected.to be_empty }
        its(:keyword_uris) { is_expected.to be_empty }
      end

      context "with existing values" do
        before { work.keyword_uris = [item.uri.to_s] }
        it "uses a null set to remote them" do
          expect(subject.keyword).not_to be_empty
          work.keyword_uris = []
          expect(subject.keyword).to be_empty
        end
      end
    end

    context "using a single-valued term" do
      subject { work }

      context "with a string" do
        before { work.digitization_source_uri = item.uri.to_s }
        its(:digitization_source) { is_expected.to eq(item) }
        its(:digitization_source_uri) { is_expected.to eq(item.uri.to_s) }
      end

      context "with a RDF::URI" do
        before { work.digitization_source_uri = item.uri }
        its(:digitization_source) { is_expected.to eq(item) }
        its(:digitization_source_uri) { is_expected.to eq(item.uri.to_s) }
      end

      context "with an empty string" do
        before { work.digitization_source_uri = "" }
        its(:digitization_source) { is_expected.to be_nil }
        its(:digitization_source_uri) { is_expected.to be_nil }
      end

      context "with an existing value" do
        before { work.digitization_source_uri = item.uri }

        it "uses nil to remove it" do
          expect { work.digitization_source_uri = nil }.to change { work.digitization_source }.to(nil)
        end

        it "uses an empty string to remove it" do
          expect { work.digitization_source_uri = "" }.to change { work.digitization_source }.to(nil)
        end
      end
    end

    context "with remaining terms" do
      it { is_expected.to respond_to(:document_type_uri=) }
      it { is_expected.to respond_to(:first_document_sub_type_uri=) }
      it { is_expected.to respond_to(:second_document_sub_type_uri=) }
      it { is_expected.to respond_to(:compositing_uri=) }
      it { is_expected.to respond_to(:light_type_uri=) }
      it { is_expected.to respond_to(:view_uris=) }
      it { is_expected.to respond_to(:document_type_uri) }
      it { is_expected.to respond_to(:first_document_sub_type_uri) }
      it { is_expected.to respond_to(:second_document_sub_type_uri) }
      it { is_expected.to respond_to(:compositing_uri) }
      it { is_expected.to respond_to(:light_type_uri) }
      it { is_expected.to respond_to(:view_uris) }
      it { is_expected.to respond_to(:attachment_uris) }
    end
  end

  describe "assigning representations" do
    let(:attachment) { create(:asset) }
    let(:asset)      { create(:asset, attachments: [attachment.uri]) }

    it "contains the correct kind of representations" do
      expect(asset.attachments).to contain_exactly(attachment)
      expect(asset.to_solr[Solrizer.solr_name("representation", :facetable)]).to contain_exactly("Is Attachment")
      expect(facets_for(Solrizer.solr_name("representation", :facetable), asset.id)).to contain_exactly("Is Attachment", 1)
      expect(facets_for(Solrizer.solr_name("representation", :facetable), attachment.id)).to contain_exactly("Has Attachment", 1)
    end
  end

  describe "FileSet types" do
    let(:asset)        { build(:asset) }
    let(:original)     { build(:original_file_set) }
    let(:intermediate) { build(:intermediate_file_set) }
    let(:preservation) { build(:preservation_file_set) }
    let(:legacy)       { build(:legacy_file_set) }
    let(:other)        { build(:file_set) }

    subject { asset }

    before { asset.members = [original, intermediate, preservation, legacy, other] }

    context "with an original file" do
      its(:original_file_set) { is_expected.to contain_exactly(original) }
    end

    context "with an intermediate file" do
      its(:intermediate_file_set) { is_expected.to contain_exactly(intermediate) }
    end

    context "with a preservation master" do
      its(:preservation_file_set) { is_expected.to contain_exactly(preservation) }
    end

    context "with a legacy file" do
      its(:legacy_file_set) { is_expected.to contain_exactly(legacy) }
    end
  end

  describe "#imaging_uid_placeholder" do
    it "returns the first imaging_uid" do
      fake_array = ["IM-1234"]
      allow(subject).to receive(:imaging_uid).and_return(fake_array)
      expect(fake_array).to receive(:first).and_call_original
      expect(subject.imaging_uid_placeholder).to eq("IM-1234")
    end
  end

  describe "#imaging_uid_placeholder=" do
    it "calls #imaing_uid=" do
      string = "IM-789"
      expect(subject).to receive(:imaging_uid=).and_call_original
      subject.imaging_uid_placeholder = string
      expect(subject.imaging_uid_placeholder).to eq(string)
    end
  end
end
