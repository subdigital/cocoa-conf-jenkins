# based on https://gist.github.com/3349345
# Thanks, @alloy!
#
# To get your project ready for this, you'll have to create a scheme for your unit test project, make sure run is checked in 
# the build step, and then delete the Test Host setting.
# Also, make sure you have the colored and open4 gems installed.

require 'rubygems'
require 'colored'
require 'pathname'
require 'open4'

# Change these to what is appropriate for your project
source_root = File.expand_path("../", __FILE__)
workspace = "SocialApp.xcworkspace"
scheme = "SocialApp"

verbose = !!ARGV.delete("--verbose")


class TestOutput < Array
  def initialize(io, verbose, source_root)
    @io, @verbose, @source_root = io, verbose, Pathname.new(source_root)
  end

  def <<(line)
    return if !@verbose && line =~ /^Test (Case|Suite)/
    super
    @io << case line
    when /^Run test case/
      line.bold.white
    when /error/
      line.red
    when /\[PASSED\]/
      line.green
    when /\[PENDING\]/
      line.yellow
    when /^(.+?\.m)(:\d+:\s.+?\[FAILED\].+)/m
      if $1 == 'Unknown.m'
        line.red
      else
        (Pathname.new($1).relative_path_from(@source_root).to_s + $2).red
      end
    else
      line
    end
    self
  end
end

cmd = "xcodebuild -workspace #{workspace} -scheme #{scheme} -sdk iphonesimulator TEST_AFTER_BUILD=YES ONLY_ACTIVE_ARCH=NO build"
stdout = TestOutput.new(STDOUT, verbose, source_root)
stderr = TestOutput.new(STDERR, verbose, source_root)
status = Open4.spawn(cmd, :stdout => stdout, :stderr => stderr, :status => true)
exit status.exitstatus
