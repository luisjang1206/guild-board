class Project < ApplicationRecord
  belongs_to :user

  has_many :board_columns, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :project_keys, dependent: :destroy
  has_many :activity_logs, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }

  after_create :create_default_board_columns
  after_create :create_default_project_key

  private

  def create_default_board_columns
    [
      [ "Backlog", 0 ],
      [ "Todo", 1 ],
      [ "In Progress", 2 ],
      [ "Review", 3 ],
      [ "Done", 4 ]
    ].each do |name, position|
      board_columns.create!(name: name, position: position)
    end
  end

  def create_default_project_key
    ProjectKey.generate_for(self, name: "Default")
  end
end
