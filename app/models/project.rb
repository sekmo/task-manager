class Project < ApplicationRecord
  validates :name, presence: true

  def attributes
    {"id" => nil, "name" => nil}
  end
end
