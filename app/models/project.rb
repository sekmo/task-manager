class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  validates :name, presence: true

  def attributes
    {"id" => nil, "name" => nil}
  end
end
