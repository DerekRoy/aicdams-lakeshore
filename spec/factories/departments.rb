# frozen_string_literal: true
FactoryGirl.define do
  factory :department do
    sequence(:citi_uid) { |n| "department-#{n}" }

    factory :department100 do
      id 'department100'
      pref_label "Department 100"
      citi_uid   "100"
    end

    factory :department200 do
      id 'department200'
      pref_label "Department 200"
      citi_uid   "200"
    end

    factory :department99, aliases: ['admins'] do
      id 'department99'
      pref_label "Administrators"
      citi_uid   "99"
    end
  end
end
