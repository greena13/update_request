FactoryBot.define do
  factory :user do
    sequence :username do |n|
      "username #{n}"
    end

    sequence :email do |n|
      "email@#{n}address.com"
    end
  end
end
