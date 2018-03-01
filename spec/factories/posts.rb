FactoryBot.define do
  factory :post do
    sequence :title do |n|
      "Post #{n}"
    end

    sequence :body do |n|
      "body #{n}"
    end
  end
end
