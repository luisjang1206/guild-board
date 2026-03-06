# frozen_string_literal: true

return unless Rails.env.development?
return if Project.exists?

user = User.find_by(role: :super_admin) || User.first
return unless user

colors = %w[#3B82F6 #10B981 #EF4444 #F59E0B #8B5CF6 #EC4899]

2.times do |i|
  project = user.projects.create!(
    name: "Sample Project #{i + 1}",
    description: "This is a sample project for demonstration purposes."
  )
  # after_create callbacks automatically create 5 BoardColumns + 1 default ProjectKey

  labels = [ "Frontend", "Backend", "Bugfix" ].map.with_index do |name, j|
    project.labels.create!(name: name, color: colors[j])
  end

  columns = project.board_columns.order(:position)
  5.times do |j|
    task = project.tasks.create!(
      title: "Sample Task #{j + 1}",
      description: "Description for sample task #{j + 1}",
      board_column: columns.sample,
      priority: [ 0, 1, 2 ].sample,
      position: j,
      creator_type: "user",
      creator_id: user.id.to_s
    )
    task.labels << labels.sample
    task.checklists.create!(content: "Step #{j + 1}", position: 0)
  end

  puts "Seeded project: #{project.name}"
end
