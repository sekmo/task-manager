class Task < ApplicationRecord
  belongs_to :project
  validates :title, presence: true

  def attributes
    {"id" => nil, "title" => nil}
  end
end
