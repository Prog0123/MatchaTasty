require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:valid_attributes) do
      {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'Password123',
        password_confirmation: 'Password123'
      }
    end

    describe 'name validation' do
      it 'requires a name' do
        user = User.new(valid_attributes.merge(name: nil))
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("を入力してください")
      end

      it 'requires name to be at least 2 characters' do
        user = User.new(valid_attributes.merge(name: 'A'))
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include('は2文字以上で入力してください')
      end

      it 'requires name to be less than or equal to 50 characters' do
        long_name = 'A' * 51
        user = User.new(valid_attributes.merge(name: long_name))
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include('は50文字以内で入力してください')
      end

      it 'accepts valid name length (2-50 characters)' do
        user = User.new(valid_attributes.merge(name: 'John Doe'))
        expect(user).to be_valid
      end
    end

    describe 'password validation' do
      it 'requires password with uppercase, lowercase, and digit' do
        invalid_passwords = [
          'password1',      # no uppercase
          'PASSWORD1',      # no lowercase
          'Password'        # no digit
        ]
        invalid_passwords.each do |pwd|
          user = User.new(valid_attributes.merge(password: pwd, password_confirmation: pwd))
          expect(user).not_to be_valid
          expect(user.errors[:password]).to include('は大文字、小文字、数字を含む必要があります')
        end
      end

      it 'accepts password with uppercase, lowercase, and digit' do
        user = User.new(valid_attributes.merge(password: 'StrongPass123', password_confirmation: 'StrongPass123'))
        expect(user).to be_valid
      end
    end

    describe 'email validation' do
      it 'requires email uniqueness' do
        User.create!(valid_attributes)
        duplicate_user = User.new(valid_attributes)
        expect(duplicate_user).not_to be_valid
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:products) }
    it { is_expected.to have_many(:reviews).dependent(:destroy) }
  end

  describe 'attachments' do
    it { is_expected.to have_one_attached(:avatar) }
  end
end
