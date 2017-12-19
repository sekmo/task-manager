require "rails_helper"

RSpec.describe Task, type: :model do
  describe "relationships" do
    it { should belong_to(:project) }
  end

  describe "validations" do
    it "is invalid without a title" do
      expect(build(:task, title: nil)).not_to be_valid
    end
  end
end
