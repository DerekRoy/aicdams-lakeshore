# frozen_string_literal: true
require 'rails_helper'

describe SolrDocument do
  describe "methods from Permissions::Readable" do
    context "by default" do
      its(:public?) { is_expected.to be false }
      its(:private?) { is_expected.to be false }
      its(:department?) { is_expected.to be true }
    end
    context "when registered" do
      before { subject["read_access_group_ssim"] = ["registered"] }
      its(:department?) { is_expected.to be false }
      its(:registered?) { is_expected.to be true }
    end
  end

  describe "image types from Hydra::Works::MimeTypes" do
    it "contains Hydra types and psd types" do
      expect(subject.class.image_mime_types).to contain_exactly("image/png",
                                                                "image/jpeg",
                                                                "image/jpg",
                                                                "image/jp2",
                                                                "image/bmp",
                                                                "image/gif",
                                                                "image/tiff")
    end
  end

  describe "#visibility" do
    subject { described_class.new(asset.to_solr).visibility }
    context "with department assets" do
      let(:asset) { build(:department_asset) }
      it { is_expected.to eq("department") }
    end
    context "with registered assets" do
      let(:asset) { build(:registered_asset) }
      it { is_expected.to eq("authenticated") }
    end
    context "by default" do
      let(:asset) { build(:asset) }
      it { is_expected.to eq("department") }
    end
  end

  describe "#title_or_label" do
    before { subject[Solrizer.solr_name("pref_label", :stored_searchable)] = "Title or label" }
    its(:title_or_label) { is_expected.to eq("Title or label") }
  end

  describe "#hydra_model" do
    let(:asset) { build(:department_asset) }
    subject { described_class.new(asset.to_solr) }
    its(:hydra_model) { is_expected.to eq(GenericWork) }
  end

  describe "#type" do
    let(:asset) { build(:department_asset) }
    subject { described_class.new(asset.to_solr) }
    its(:type) { is_expected.to include(AICType.Resource) }
  end

  describe "#fedora_uri" do
    let(:good_uri) do
      URI.join(ActiveFedora.config.credentials[:url],
               ActiveFedora.config.credentials[:base_path],
               "id").to_s
    end

    let(:bad_uri) do
      URI.join("https://bad.example.com/rest",
               ActiveFedora.config.credentials[:base_path],
               "id").to_s
    end

    context "when the FQDN matches the configured Fedora instance" do
      subject { described_class.new(Solrizer.solr_name('fedora_uri', :symbol) => good_uri) }
      its(:fedora_uri) { is_expected.to eq(good_uri) }
    end

    context "when the FQDN does not match the configured Fedora instance" do
      subject { described_class.new(Solrizer.solr_name('fedora_uri', :symbol) => bad_uri) }
      its(:fedora_uri) { is_expected.to eq(good_uri) }
    end
  end

  it { is_expected.to respond_to(:citi_uid) }
  it { is_expected.to respond_to(:uid) }
  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:document_ids) }
  it { is_expected.to respond_to(:representation_ids) }
  it { is_expected.to respond_to(:preferred_representation_id) }
  it { is_expected.to respond_to(:attachment_ids) }
  it { is_expected.to respond_to(:artist_id) }
  it { is_expected.to respond_to(:current_location_id) }
  it { is_expected.to respond_to(:aic_depositor) }
  it { is_expected.to respond_to(:depositor_full_name) }
  it { is_expected.to respond_to(:dept_created) }
  it { is_expected.to respond_to(:dept_created_citi_uid) }
  it { is_expected.to respond_to(:thumbnail_path) }
  it { is_expected.to respond_to(:related_image_id) }

  describe "Agent terms" do
    it { is_expected.to respond_to(:birth_year) }
    it { is_expected.to respond_to(:birth_date) }
    it { is_expected.to respond_to(:death_year) }
    it { is_expected.to respond_to(:death_date) }
  end

  describe "Work terms" do
    describe "#department" do
      let(:work)       { build(:work) }
      let(:department) { build(:department, pref_label: "Department of Works") }
      before { allow(work).to receive(:department).and_return([department]) }
      subject { described_class.new(work.to_solr, id: "1234") }
      its(:department) { is_expected.to contain_exactly("Department of Works") }
    end

    it { is_expected.to respond_to(:creator_display) }
    it { is_expected.to respond_to(:credit_line) }
    it { is_expected.to respond_to(:date_display) }
    it { is_expected.to respond_to(:dimensions_display) }
    it { is_expected.to respond_to(:earliest_year) }
    it { is_expected.to respond_to(:exhibition_history) }
    it { is_expected.to respond_to(:gallery_location) }
    it { is_expected.to respond_to(:inscriptions) }
    it { is_expected.to respond_to(:latest_year) }
    it { is_expected.to respond_to(:main_ref_number) }
    it { is_expected.to respond_to(:medium_display) }
    it { is_expected.to respond_to(:object_type) }
    it { is_expected.to respond_to(:place_of_origin) }
    it { is_expected.to respond_to(:provenance_text) }
    it { is_expected.to respond_to(:publication_history) }
    it { is_expected.to respond_to(:publ_ver_level) }
  end

  describe "Exhibition terms" do
    it { is_expected.to respond_to(:start_date) }
    it { is_expected.to respond_to(:end_date) }
    it { is_expected.to respond_to(:name_official) }
    it { is_expected.to respond_to(:name_working) }
    it { is_expected.to respond_to(:exhibition_type) }
  end

  describe "Place terms" do
    it { is_expected.to respond_to(:lat) }
    it { is_expected.to respond_to(:long) }
  end

  describe "Asset terms" do
    it { is_expected.to respond_to(:capture_device) }
    it { is_expected.to respond_to(:digitization_source) }
    it { is_expected.to respond_to(:document_types) }
    it { is_expected.to respond_to(:legacy_uid) }
    it { is_expected.to respond_to(:keyword) }
    it { is_expected.to respond_to(:compositing) }
    it { is_expected.to respond_to(:imaging_uid) }
    it { is_expected.to respond_to(:light_type) }
    it { is_expected.to respond_to(:view) }
    it { is_expected.to respond_to(:transcript) }
    it { is_expected.to respond_to(:publish_channels) }
    it { is_expected.to respond_to(:view_notes) }
    it { is_expected.to respond_to(:visual_surrogate) }
    it { is_expected.to respond_to(:external_resources) }
    it { is_expected.to respond_to(:licensing_restrictions) }
    it { is_expected.to respond_to(:public_domain?) }
    it { is_expected.to respond_to(:publishable?) }
    it { is_expected.to respond_to(:copyright_representatives) }
    it { is_expected.to respond_to(:caption) }
  end

  describe "Resource terms" do
    it { is_expected.to respond_to(:batch_uid) }
    it { is_expected.to respond_to(:contributors) }
    it { is_expected.to respond_to(:created_by) }
    it { is_expected.to respond_to(:uid) }
    it { is_expected.to respond_to(:language) }
    it { is_expected.to respond_to(:publisher) }
    it { is_expected.to respond_to(:rights) }
    it { is_expected.to respond_to(:rights_statement) }
    it { is_expected.to respond_to(:rights_holder) }
    it { is_expected.to respond_to(:alt_label) }
  end

  describe "Collection terms" do
    it { is_expected.to respond_to(:collection_type) }
  end
end
