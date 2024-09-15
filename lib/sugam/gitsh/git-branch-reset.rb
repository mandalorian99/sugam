#!/usr/bin/env ruby
require 'optparse'
require 'open3'

def run_git_command(command)
  output, status = Open3.capture2e(command)
  unless status.success?
    puts "Error running command: #{command}\n#{output}"
    exit(1)
  end
  output
end

# Function to delete and recreate a branch
def reset_branch(branch_name)
  if branch_name == 'master' || branch_name == 'main'
    puts "Warning: Deleting the #{branch_name} branch is not allowed!"
    exit(1)
  end

  puts "Resetting #{branch_name} branch..."
  run_git_command("git branch -D #{branch_name}")
  run_git_command("git checkout -b #{branch_name} origin/master")
  puts "#{branch_name} branch has been reset successfully."
end

# Parse command-line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: git branch-reset [--qa | --staging]"

  opts.on('--qa', 'Reset the QA branch') do
    options[:branch] = 'qa'
  end

  opts.on('--staging', 'Reset the Staging branch') do
    options[:branch] = 'staging'
  end
end.parse!

if options[:branch]
  reset_branch(options[:branch])
else
  puts "Please specify a branch to reset with --qa or --staging"
end
