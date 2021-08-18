require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_secure_password }
  it { is_expected.to validate_length_of(:password).is_at_least(6) }
  it { is_expected.to validate_length_of(:name).is_at_least(5).is_at_most(50) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_inclusion_of(:role).in_array(['admin', 'user']) }
  it { is_expected.to validate_presence_of(:role) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to have_many(:blogs) }

  describe 'User methods' do
    let(:user) { create(:user) }
    context '#generate_token!' do
      it do
        user.generate_token!
        expect(user.token.present?).to be(true)
      end 
    end

    context '#reset_token!' do
      it do
        user.reset_token!
        expect(user.token.present?).to be(false)
      end 
    end

    context '#locked!' do
      it do
        user.locked!
        expect(user.locked?).to be(true)
      end 
    end

    context '#unlock!' do
      it do
        user.locked!
        user.unlock!
        expect(user.locked?).to be(false)
      end 
    end

    context '#admin?' do
      it 'is admin' do
        user.role = 'admin'
        expect(user.admin?).to be(true)
      end 

      it 'is user' do
        user.role = 'user'
        expect(user.admin?).to be(false)
      end 
    end
  end
end