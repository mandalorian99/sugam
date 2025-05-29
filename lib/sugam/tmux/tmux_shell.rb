#!/usr/bin/env ruby

# tmux_session_setup.rb
# Creates a 4-pane tmux session with predefined layouts and commands

require 'open3'

SESSION_NAME = "dev"
LAYOUT = "tiled"  # Other options: even-vertical, even-horizontal, main-vertical, main-horizontal

PROJECTS = [
  {
    path: "~/projects/legion/hb-new-frontend",
    command: ""
  },
  {
    path: "~/projects/legion/hellobar_new",
    command: ""
  },
  {
    path: "~/projects/legion/hellobar-api",
    command: ""
  },
  {
    path: "~/projects/vstack",
    command: ""
  }
]

def run_tmux_command(command)
  Open3.capture3("tmux #{command}")
end

# Check for existing session and kill if exists
existing_session = run_tmux_command("has-session -t #{SESSION_NAME} 2>/dev/null")
if existing_session[2].success?
  puts "Existing session found. Killing #{SESSION_NAME}..."
  run_tmux_command("kill-session -t #{SESSION_NAME}")
end

# Create new session
run_tmux_command("new-session -d -s #{SESSION_NAME} -c #{PROJECTS[0][:path]}")
run_tmux_command("send-keys -t #{SESSION_NAME} '#{PROJECTS[0][:command]}' C-m")

# Create panes and run commands
(1..3).each do |i|
  run_tmux_command("split-window -t #{SESSION_NAME} -c #{PROJECTS[i][:path]}")
  run_tmux_command("send-keys -t #{SESSION_NAME}.#{i} '#{PROJECTS[i][:command]}' C-m")
  run_tmux_command("select-layout -t #{SESSION_NAME} #{LAYOUT}")
end

# Final layout configuration
run_tmux_command("select-pane -t #{SESSION_NAME}.0")
run_tmux_command("set-window-option -t #{SESSION_NAME} synchronize-panes off")

# Attach to session
exec "tmux attach -t #{SESSION_NAME}"
