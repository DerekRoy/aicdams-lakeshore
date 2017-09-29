# frozen_string_literal: true
FactoryGirl.define do
  factory :user do
    factory :user1, aliases: [:default_user] do
      email 'user1'
      department '100'
      initialize_with { User.find_or_create_by(email: 'user1') }

      before(:create) do
        create(:aic_user1) unless AICUser.exists?("aic_user1")
        create(:department100) unless Department.exists?("department100")
      end
    end

    factory :user2, aliases: [:different_user] do
      email 'user2'
      department '200'
      initialize_with { User.find_or_create_by(email: 'user2') }

      before(:create) do
        create(:aic_user2) unless AICUser.exists?("aic_user2")
        create(:department200) unless Department.exists?("department200")
      end
    end

    factory :department_user do
      email 'department_user'
      department '100'
      initialize_with { User.find_or_create_by(email: 'department_user') }

      before(:create) do
        create(:aic_department_user) unless AICUser.exists?("aic_department_user")
        create(:department100) unless Department.exists?("department100")
      end
    end

    factory :admin do
      email 'admin'
      department '99'
      initialize_with { User.find_or_create_by(email: 'admin') }

      before(:create) do
        create(:aic_admin) unless AICUser.exists?("aic_admin")
        create(:department99) unless Department.exists?("department99")
      end
    end

    factory :apiuser do
      email 'apiuser'
      password 'password'
    end
  end
end
