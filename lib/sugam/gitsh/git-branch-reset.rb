#!/usr/bin/env ruby
require 'optparse'
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

# Checkout to master or main branch
def checkout_to_main_or_master
  branches = ['master', 'main']
  branch = branches.find { |b| system("git show-ref --quiet refs/heads/#{b}") }

  if branch
    run_command("git checkout #{branch}")
  else
    puts "Error: Neither 'master' nor 'main' branch exists. Exiting..."
    exit(1)
  end
end

# Stash local changes
def stash_local_changes
  run_command("git stash")
end

# Reset the specified branch
def reset_branch(branch)
  if branch == 'master' || branch == 'main'
    puts "Error: Cannot reset the 'master' or 'main' branch. Exiting..."
    exit(1)
  end

  # Delete the branch and recreate it from the current main/master branch
  run_command("git branch -D #{branch}") if system("git show-ref --quiet refs/heads/#{branch}")
  run_command("git checkout -b #{branch}")
end

# Main script execution
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: git-branch-reset --qa or --staging"

  opts.on('--qa', 'Reset QA branch') do
    options[:branch] = 'qa'
  end

  opts.on('--staging', 'Reset Staging branch') do
    options[:branch] = 'staging'
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

# Ensure the branch is specified
unless options[:branch]
  puts "Error: Please specify a branch using --qa or --staging"
  exit(1)
end

# Perform the operations
stash_local_changes
checkout_to_main_or_master
reset_branch(options[:branch])

puts "#{options[:branch]} branch reset successfully."
