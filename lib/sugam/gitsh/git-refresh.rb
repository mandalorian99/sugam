#!/usr/bin/env ruby
require 'optparse'
require 'open3'

def stash_changes
  puts "Stashing current changes..."
  system('git stash')
end

def checkout_branch(branch)
  puts "Checking out to #{branch}..."
  if system("git checkout #{branch}")
    puts "Checked out to #{branch} successfully."
  else
    puts "Failed to checkout to #{branch}. Exiting..."
    nil
  end
end

def update_branch(branch)
  puts "Updating #{branch}..."
  if system("git pull origin #{branch}")
    puts "#{branch} is up to date."
  else
    puts "Failed to update #{branch}. Exiting..."
    nil
  end
end

def refresh_branch(target_branch)
  if ['qa', 'staging'].include?(target_branch)
    stash_changes
    # Checkout to master/main
    checkout_branch('master') || checkout_branch('main')
    update_branch('master') || update_branch('main')

    # Delete the local branch and recreate it from master/main
    puts "Refreshing #{target_branch} branch..."
    system("git branch -D #{target_branch}")
    if system("git checkout -b #{target_branch}")
      puts "#{target_branch} branch has been refreshed."
    else
      puts "Failed to refresh #{target_branch}. Exiting..."
      exit 1
    end
  else
    puts "Invalid branch! Only 'qa' or 'staging' are allowed."
    exit 1
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: git-refresh --qa or git-refresh --staging"

  opts.on("--qa", "Refresh QA branch") do
    options[:branch] = 'qa'
  end

  opts.on("--staging", "Refresh Staging branch") do
    options[:branch] = 'staging'
  end
end.parse!

if options[:branch]
  refresh_branch(options[:branch])
else
  puts "Please specify --qa or --staging."
end
