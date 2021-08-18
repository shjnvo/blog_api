require 'rails_helper'

RSpec.describe Blog, type: :model do
  it { is_expected.to validate_length_of(:title).is_at_most(50) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_uniqueness_of(:title) }
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to belong_to(:creator) }

  describe 'Blog methods' do
    let!(:user) { create(:user) }
    let!(:blog) { create(:blog, creator: user) }

    context '#unpublish!' do
      it do
        blog.unpublish!
        expect(blog.published_at.present?).to eq false
      end
    end

    context '#published' do
      it do
        blog.unpublish!
        blog.published
        expect(blog.published_at.present?).to eq true
      end
    end
  end
end
