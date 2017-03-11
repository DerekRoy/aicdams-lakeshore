# frozen_string_literal: true
require 'rails_helper'

describe InboundRelationshipManagementService do
  let(:service) { described_class.new(resource) }

  describe "#add_or_remove" do
    context "without pre-existing relationships" do
      let(:resource) { create(:asset) }
      let(:work)     { create(:work) }

      subject { work }

      context "with an id" do
        before do
          service.add_or_remove(:representations, [work.id])
          work.reload
        end

        its(:representations) { is_expected.to contain_exactly(resource) }
      end

      context "with a uri" do
        before do
          service.add_or_remove(:representations, [work.uri.to_s])
          work.reload
        end

        its(:representations) { is_expected.to contain_exactly(resource) }
      end
    end

    context "when replacing a relationship" do
      let!(:resource) { create(:asset) }
      let!(:old_work) { create(:work, representation_uris: [resource.uri]) }
      let!(:work)     { create(:work) }

      it "removes the relationship from one work and adds it to the other" do
        expect(old_work.representations).to contain_exactly(resource)
        service.add_or_remove(:representations, [work.id])
        work.reload
        old_work.reload
        expect(work.representations).to contain_exactly(resource)
        expect(old_work.representations).to be_empty
      end
    end

    context "with preferred representations" do
      let(:resource) { "resource" }
      it "returns an error" do
        expect { service.add_or_remove(:preferred_representations, ["ids"]) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#update" do
    context "with a relationship other than preferred representations" do
      let(:resource) { "resource" }
      it "returns an error" do
        expect { service.update(:representations, ["ids"]) }.to raise_error(NotImplementedError)
      end
    end

    context "with preferred representations" do
      let(:resource) { create(:asset) }
      let(:work)     { create(:work) }

      subject { work }

      before do
        service.update(:preferred_representations, [work.id])
        work.reload
      end

      its(:preferred_representation) { is_expected.to eq(resource) }
    end
  end
end
