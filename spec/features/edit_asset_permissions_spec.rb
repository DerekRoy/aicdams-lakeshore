# frozen_string_literal: true
require 'rails_helper'

describe "Editing asset permissions" do
  context "when removing permissions from an asset" do
    let!(:user)     { create(:default_user) }
    let!(:other)    { create(:different_user) }
    let!(:asset)    { create(:department_asset, :with_metadata, edit_users: [other]) }
    let!(:file_set) { create(:intermediate_file_set, edit_users: [other]) }

    before do
      asset.ordered_members = [file_set]
      asset.save
      sign_in_with_js(user)
      visit(edit_polymorphic_path(asset))
    end

    it "copies the permissions to the file set" do
      within("ul.nav-tabs") { click_link("Share") }
      within("#share") do
        expect(page).to have_content(user.email)
        expect(page).to have_content("other")
      end
      find(".remove_perm").click
      click_button("Save")
      expect(page).to have_content("Apply changes to contents?")
      click_button("Yes please.")
      expect(page).to have_content(asset.pref_label.first)
      expect(asset.reload.edit_users).to contain_exactly(user.user_key)
      expect(asset.file_sets.first.edit_users).to contain_exactly(user.user_key)
    end
  end
end
