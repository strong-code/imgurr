# coding: utf-8

# Platform is a centralized point to shell out platform specific functionality
# like clipboard access or commands to open URLs.
#
#
# Clipboard is a centralized point to shell out to each individual platform's
# clipboard, pasteboard, or whatever they decide to call it.
#
# Source: https://github.com/holman/boom
# 
module Imgurr
  class Platform
    class << self
      # Public: tests if currently running on darwin.
      #
      # Returns true if running on darwin (MacOS X), else false
      def darwin?
        !!(RUBY_PLATFORM =~ /darwin/)
      end

      # Public: tests if currently running on windows.
      #
      # Apparently Windows RUBY_PLATFORM can be 'win32' or 'mingw32'
      #
      # Returns true if running on windows (win32/mingw32), else false
      def windows?
        !!(RUBY_PLATFORM =~ /mswin|mingw/)
      end

      # Public: returns the command used to open a file or URL
      # for the current platform.
      #
      # Currently only supports MacOS X and Linux with `xdg-open`.
      #
      # Returns a String with the bin
      def open_command
        if darwin?
          'open'
        elsif windows? 
          'start'
        else
          'xdg-open'
        end
      end

      # Public: opens a given URL in the browser. This
      # method is designed to handle multiple platforms.
      #
      # Returns nothing
      def open(url)
        unless windows?
          system("#{open_command} '#{url.gsub("\'","'\\\\''")}'")
        else
          system("#{open_command} #{url.gsub("\'","'\\\\''")}")
        end
      end

      # Public: returns the command used to copy a given Item's value to the
      # clipboard for the current platform.
      #
      # Returns a String with the bin
      def copy_command
        if darwin?
          'pbcopy'
        elsif windows?
          'clip'
        else
          'xclip -selection clipboard'
        end
      end
      
      # Public: copies a given URL value to the clipboard. This method is
      # designed to handle multiple platforms.
      #
      # Returns nothing
      def copy(url)
        IO.popen(copy_command,"w") {|cc|  cc.write(url)}
        url
      end

      # Public: opens the JSON file in an editor for you to edit. Uses the
      # $EDITOR environment variable, or %EDITOR% on Windows for editing.
      # This method is designed to handle multiple platforms.
      # If $EDITOR is nil, try to open using the open_command.
      #
      # Returns a String with a helpful message.
      def edit(json_file)
        unless $EDITOR.nil?
          unless windows?
            system("`echo $EDITOR` #{json_file} &")
          else
            system("start %EDITOR% #{json_file}")
          end
        else
          system("#{open_command} #{json_file}")
        end

        'Make your edits, and do be sure to save.'
      end
    end
  end
end