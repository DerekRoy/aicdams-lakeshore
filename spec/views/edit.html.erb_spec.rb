require 'rails_helper'

describe "generic_files/edit.html.erb" do

  let(:resource_version) do
    ActiveFedora::VersionsGraph::ResourceVersion.new.tap do |v|
      v.uri = 'http://example.com/version1'
      v.label = 'version1'
      v.created = '2014-12-09T02:03:18.296Z'
    end
  end
  let(:version_list) { Sufia::VersionListPresenter.new([resource_version]) }
  let(:versions_graph) { double(all: [version1]) }
  let(:content) { double('content', mimeType: 'application/pdf') }

  let(:generic_file) do
    stub_model(GenericFile, id: '123',
      depositor: 'bob',
      resource_type: ['Book', 'Dataset'])
  end

  let(:form) { ResourceEditForm.new(generic_file) }

  let(:page) do
    render
    page = Capybara::Node::Simple.new(rendered)
  end

  before do
    allow(generic_file).to receive(:content).and_return(content)
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    assign(:generic_file, generic_file)
    assign(:form, form)
    assign(:version_list, version_list)
  end

  # TODO: Flesh this out when we get to the view stage
  it "shows aictype:Resource fields" do
    expect(page).to have_selector("input#generic_file_title", count: 1)
  end

end
