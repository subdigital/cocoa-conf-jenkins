require 'rubygems'
require 'xcodebuild'
require 'pry'

app_name = "SocialApp"
workspace = "#{app_name}.xcworkspace"
scheme = "#{app_name}"
progress = ENV['progress'] != nil
output_dir = "build"

XcodeBuild::Tasks::BuildTask.new do |t|
  t.sdk = "iphoneos"
  t.configuration = "Release"
  t.workspace = workspace
  t.scheme = scheme
  t.add_build_setting("ONLY_ACTIVE_ARCH", "NO")
  t.after_build do |build|
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

desc "Increments the build number"
task :bump_build_number do
  system "agvtool bump -all"
end

desc "Builds an IPA for distribution"
task "build_ipa" => [:install_distribution_cert, :install_provisioning_profiles, :bump_build_number, "xcode:cleanbuild"] do
  verbose = false
  release_dir = File.expand_path(File.join("./", output_dir))
  app_path = "#{release_dir}/#{app_name}.app"
  ipa_path = "#{release_dir}/#{app_name}.ipa"
  dsym_path = "#{release_dir}/#{app_name}.app.dSYM"

  package_cmd = <<-EOS
    /usr/bin/xcrun -sdk iphoneos PackageApplication #{verbose ? -v : ""} \\
     \"#{app_path}\" \\
     -o \"#{ipa_path}\"
  EOS
  
  puts "Zipping dSYM..."
  dsym_path = zip_dsym(dsym_path)
  puts "Zipped #{dsym_path}"

  puts "Packaging IPA for #{app_name} #{app_version}..."
  system package_cmd
  puts "Created #{ipa_path}"
end

desc "Uploads the latest ipa to testflight"
task :publish_testflight do
  ipa = Dir["build/*.ipa"].first
  fail "No IPA found to upload!  Run bundle exec rake build_ipa first" if ipa.nil?
  
  dsym = Dir["build/*.dSYM.zip"].first
  fail "No zipped dSYM found!" if dsym.nil?
  
  notes = `cat RELEASE_NOTES`

  upload_to_testflight(ipa, dsym, notes)
end

def upload_to_testflight(ipa_file, dsym_file, release_notes)
  api_token = ENV['testflight_api_token']
  team_token = ENV['testflight_team_token']
  
  cmd = <<-EOS
  /usr/bin/curl "http://testflightapp.com/api/builds.json" \
    -F file=@"#{ipa_file}" \
    -F dsym=@"#{dsym_file}" \
    -F api_token="${API_TOKEN}" \
    -F team_token="${TEAM_TOKEN}" \
    -F notes="Build uploaded automatically from Xcode."
  EOS
  system cmd
end

def zip_dsym(dsym)
  zip_path = dsym.chomp("/") + ".zip"
  system "zip -r #{zip_path} #{dsym}"
  zip_path
end

def app_version
  marketing_verison = `agvtool mvers -terse1`.chomp
  build_number =  `agvtool vers -terse`.chomp
  "#{marketing_verison} (Build #{build_number})"
end