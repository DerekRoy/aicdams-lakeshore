# frozen_string_literal: true
FactoryGirl.define do
  factory :aic_user, aliases: [:inactive_user], class: AICUser do
    given_name 'Joe'
    family_name 'Bob'
    nick 'joebob'

    factory :aic_user1, aliases: [:active_user] do
      id 'aic_user1'
      given_name 'First'
      family_name 'User'
      nick 'user1'
      active
    end

    factory :aic_user2 do
      id 'aic_user2'
      given_name 'Second'
      family_name 'User'
      nick 'user2'
      active
    end

    factory :aic_user3 do
      given_name 'Third'
      family_name 'User'
      nick 'inactiveuser'
    end

    factory :aic_department_user do
      id 'aic_department_user'
      given_name 'Department'
      family_name 'User'
      nick 'department_user'
      active
    end

    factory :aic_admin do
      id 'aic_admin'
      given_name 'Admin'
      family_name 'User'
      nick 'admin'
      active
    end

    trait :active do
      after(:build) do |user|
        user.type << AIC.ActiveUser
      end
    end
  end
end
