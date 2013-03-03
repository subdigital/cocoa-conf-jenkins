require 'rubygems'
require 'xcodebuild'
require 'pry'

progress = ENV['progress'] != nil
output_dir = "build"

XcodeBuild::Tasks::BuildTask.new do |t|
  t.sdk = "iphoneos"
  t.configuration = "Release"
  t.workspace = "SocialApp.xcworkspace"
  t.scheme = "SocialApp"
  t.add_build_setting("ONLY_ACTIVE_ARCH", "NO")
  t.after_build do |build|
    # binding.pry
    built_products_dir = build.environment['BUILT_PRODUCTS_DIR']
    system("rm -rf #{output_dir} && mkdir -p #{output_dir}")
    system("cp -R #{built_products_dir}/* #{output_dir}")
  end
  t.formatter = XcodeBuild::Formatters::ProgressFormatter.new if progress
end

desc "Installs the provisioning profiles present in the provisioning directory"
task :install_provisioning_profiles do
  Dir["provisioning/*.mobileprovision"].each do |file|
    system("scripts/install_provisioning_profile.sh #{file}")
  end
end

desc "Adds the distribution certificate to the jenkins keychain"
task :install_distribution_cert do
  system "security unlock -p jenkins jenkins"
  system "security import provisioning/ios_distribution.p12 -k ~/Library/Keychains/jenkins -P jenkins"
end

desc "Builds an IPA for distribution"
task "build_ipa" => [:install_provisioning_profiles, "xcode:cleanbuild"] do
  puts "Building ipa"
end