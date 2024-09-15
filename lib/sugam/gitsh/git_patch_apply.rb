#!/usr/bin/env ruby

require 'open3'

# Function to run a shell command and capture output
def run_command(command)
  puts "Running command: #{command}"
  stdout, stderr, status = Open3.capture3(command)
  unless status.success?
    puts "Error running command: #{stderr.strip}"
    exit 1
  end
  stdout.strip
end

# Validate the patch
def validate_patch
  puts "Validating the patch before applying..."
  stdout, stderr, status = Open3.capture3('git apply --check commits.patch')
  if status.success?
    puts "Patch is valid and ready to apply."
    return true
  else
    puts "Patch validation failed: #{stderr.strip}"
    return false
  end
end

# Fix trailing whitespaces in the patch
def fix_patch
  puts "Attempting to fix the patch by removing trailing whitespaces..."
  # Using sed to remove trailing whitespace from the patch file
  run_command("sed -i '' 's/[ \t]*$//' commits.patch")
end

# Main script logic
def main(n)
  puts "Stashing current changes..."
  run_command('git stash')

  puts "Creating a patch from the last #{n} commits..."
  run_command("git format-patch -#{n} --stdout > commits.patch")

  puts "Checking out to the QA branch..."
  run_command('git checkout qa')

  # Validate the patch before applying
  if !validate_patch
    # Try fixing the patch by removing trailing whitespaces
    fix_patch
    # Validate the patch again after fixing
    if !validate_patch
      puts "Patch is still invalid after fixing. Exiting."
      exit 1
    end
  end

  puts "Applying patch to the QA branch using git am..."
  begin
    run_command('git am --signoff < commits.patch')
    puts "Patch applied successfully and committed as a single commit."
  rescue => e
    puts "Failed to apply patch: #{e.message}"
    exit 1
  end

  puts "Process completed successfully."
end

# Get the number of commits to create the patch from
if ARGV.length != 1
  puts "Usage: #{$0} <number_of_commits>"
  exit 1
end

n = ARGV[0].to_i
main(n)
