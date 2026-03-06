# frozen_string_literal: true

require "fast_mcp"

FastMcp.mount_in_rails(
  Rails.application,
  name: "guild-board",
  version: "1.0.0",
  path_prefix: "/mcp",
  localhost_only: Rails.env.local?,
  allowed_origins: Rails.env.production? ? [ ENV.fetch("MCP_ALLOWED_ORIGIN", "localhost") ] : nil
) do |server|
  Rails.application.config.after_initialize do
    server.register_tools(*ApplicationTool.descendants)
  end
end
