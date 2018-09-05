require "factory_bot"

FactoryBot.define do
  factory(:article) do |f|
    f.title { Faker::Lorem.sentence }
    f.summary { Faker::Lorem.paragraphs.first }
    f.body { Faker::Lorem.paragraphs.join("\n\n") }
    f.post_date { 1.day.ago.to_date }
  end

  factory(:article_draft, :class => Article::Draft) do |f|
    f.association(:article)
    f.title { Faker::Lorem.sentence }
    f.summary { Faker::Lorem.paragraphs.first }
    f.body { Faker::Lorem.paragraphs.join("\n\n") }
    f.post_date { 1.day.ago.to_date }
  end

  factory(:article_with_draft, :parent => :article) do |f|
    f.association(:draft, :factory => :article_draft)
  end
end