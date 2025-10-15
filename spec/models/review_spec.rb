require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:valid_attributes) do
    {
      richness: 4,
      sweetness: 3,
      bitterness: 2,
      aftertaste: 4,
      appearance: 5,
      user_id: user.id,
      product_id: product.id
    }
  end

  describe 'validations' do
    it 'creates a valid review' do
      review = Review.new(valid_attributes)
      expect(review).to be_valid
    end

    [ :richness, :sweetness, :bitterness, :aftertaste, :appearance ].each do |score_attr|
      it "requires #{score_attr}" do
        review = Review.new(valid_attributes.merge(score_attr => nil))
        expect(review).not_to be_valid
        expect(review.errors[score_attr]).to include('は1〜5で評価してください')
      end

      it "requires #{score_attr} between 1 and 5" do
        review = Review.new(valid_attributes.merge(score_attr => 0))
        expect(review).not_to be_valid
        expect(review.errors[score_attr]).to include('は1〜5で評価してください')
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:user) }
  end

  describe '#average_score' do
    it 'calculates average of all scores' do
      review = Review.create!(valid_attributes)
      expect(review.average_score).to eq(3.6)
    end
  end
end
