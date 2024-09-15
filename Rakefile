require "bundler/gem_tasks"
task :default => :spec

require 'rake'
require 'fileutils'

namespace :sugam do
  desc "Setup gitsh scripts by copying them to /usr/local/bin without .rb extension"
  task :install do
    source_dir = File.expand_path('lib/sugam/gitsh')
    destination_dir = '/usr/local/bin'

    # Ensure the source directory exists
    unless Dir.exist?(source_dir)
      puts "Source directory #{source_dir} does not exist!"
      exit 1
    end

    # Collect all files from the source directory
    files = Dir.entries(source_dir).select { |f| File.file?(File.join(source_dir, f)) && f.end_with?('.rb') }

    if files.empty?
      puts "No .rb files found in #{source_dir} to copy."
      exit 1
    end

    puts "Copying files from #{source_dir} to #{destination_dir} without .rb extension..."

    files.each do |file|
      # Remove the .rb extension from the file name
      file_without_extension = File.basename(file, '.rb')
      source_file = File.join(source_dir, file)
      destination_file = File.join(destination_dir, file_without_extension)

      begin
        # Copy the file to /usr/local/bin without .rb extension
        FileUtils.cp(source_file, destination_file)

        # Make the file executable
        FileUtils.chmod("u+x", destination_file)

        puts "Successfully copied and made executable: #{file_without_extension}"
      rescue Errno::EACCES
        # If there is a permission issue, retry with sudo
        puts "Permission denied, attempting to copy with sudo for #{file_without_extension}..."
        system("sudo cp #{source_file} #{destination_file}")
        system("sudo chmod +x #{destination_file}")

        if $?.exitstatus == 0
          puts "File #{file_without_extension} copied and made executable with sudo."
        else
          puts "Failed to copy #{file_without_extension} even with sudo."
          exit 1
        end
      end
    end

    puts "Setup complete."
  end
end

