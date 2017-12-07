require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "validations" do
    it "is invalid without a name" do
      expect(build(:project, name: nil)).not_to be_valid
    end
  end
end
