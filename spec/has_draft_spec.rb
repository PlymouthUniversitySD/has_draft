require "spec_helper"

describe HasDraft do
  before(:all) do
    ActiveSupport::Deprecation.silenced = true
  end

  context "Model with has_draft" do
    it "should expose #draft_class_name as Draft" do
      expect(Article.draft_class_name).to eql("Draft")
    end

    it "should expose #draft_class as Article::Draft" do
      expect(Article.draft_class).to eql(Article::Draft)
    end

    it "should default #draft_foreign_key as article_id" do
      expect(Article.draft_foreign_key).to eql("article_id")
    end

    it "should default #draft_table_name as article_drafts" do
      expect(Article.draft_table_name).to eql("article_drafts")
    end

    it "should expose #with_draft and #without_draft scopes" do
      expect { Article.with_draft.to_a }.to_not raise_error
      expect { Article.without_draft.to_a }.to_not raise_error
    end

    describe "Draft Model" do
      it "should be defined under the Article namespace" do
        expect(Article.constants.map(&:to_s)).to include('Draft')
      end

      it "should expose #original_class as Article" do
        expect(Article::Draft.original_class).to eql(Article)
      end
    end
  end

  context "an article" do
    before { @article = FactoryBot.create(:article) }

    context "when instantiating a new draft" do
      before { @article.instantiate_draft! }

      it "should create draft" do
        expect(@article.draft).to_not be_nil
        expect(@article.draft).to_not be_new_record
      end

      it "should copy draft fields" do
        Article.draft_columns.each do |column|
          expect(@article.send(column)).to eql(@article.draft.send(column))
        end
      end
    end

    context "when destroying an existing draft" do
      before do
        @article = FactoryBot.create(:article_with_draft)
        @article.destroy_draft!
      end

      it "should associated draft" do
        expect(@article.draft).to be_nil
      end
    end

    context "when replacing with draft" do
      before do
        @article = FactoryBot.create(:article_with_draft)
        @article.replace_with_draft!
      end

      it "should still have draft" do
        expect(@article.draft).to_not be_nil
      end

      it "should now have the same field values as draft" do
        Article.draft_columns.each do |column|
          expect(@article.send(column)).to eql(@article.draft.send(column))
        end
      end
    end
  end

  context "Draft class extends" do

    it "ActiveRecord::Base when no options are passed" do
      expect(Article::Draft.superclass).to eql(ActiveRecord::Base)
    end

    it "the class passed in with the :extends option" do
      expect(BlogPost::Draft.superclass).to eql(Post)
    end
  end

  context "Draft class belongs to" do

    it "self when :belongs_to is not specified" do
      expect(Article::Draft.reflect_on_association(:article).macro).to eql(:belongs_to)
    end

    it "the model passed in with the :belongs_to option" do
      expect(BlogPost::Draft.reflect_on_association(:post).macro).to eql(:belongs_to)
    end
  end

end
