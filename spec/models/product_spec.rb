require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    {
      name: 'Delicious Cake',
      shop_name: 'Sweet Shop',
      category: :cake,
      price: 1500,
      user_id: user.id
    }
  end

  describe 'validations' do
    it 'creates a valid product' do
      product = Product.new(valid_attributes)
      expect(product).to be_valid
    end

    it 'requires a name' do
      product = Product.new(valid_attributes.merge(name: nil))
      expect(product).not_to be_valid
      expect(product.errors[:name]).to include("を入力してください")
    end

    it 'requires a shop_name' do
      product = Product.new(valid_attributes.merge(shop_name: nil))
      expect(product).not_to be_valid
      expect(product.errors[:shop_name]).to include("を入力してください")
    end

    it 'requires a category' do
      product = Product.new(valid_attributes.merge(category: nil))
      expect(product).not_to be_valid
      expect(product.errors[:category]).to include("を入力してください")
    end

    it 'requires price to be greater than 0' do
      product = Product.new(valid_attributes.merge(price: 0))
      expect(product).not_to be_valid
      expect(product.errors[:price]).to include('は0より大きい値にしてください')
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:taggings) }
    it { is_expected.to have_one(:review).dependent(:destroy) }
  end
end
