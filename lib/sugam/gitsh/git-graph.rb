#!/usr/bin/env ruby
require 'open3'

# Function to run a Git command and handle errors
def run_command(command)
  puts "Running command: #{command}"
  stdout, stderr, status = Open3.capture3(command)
  if status.success?
    puts stdout
  else
    puts "Error: #{stderr}"
    exit(1)
  end
end

command = "git log --graph --oneline --decorate --all --full-history --author-date-order --no-notes"
run_command(command)