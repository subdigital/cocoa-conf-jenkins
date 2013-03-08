require 'rubygems'
require 'xcodebuild'
require 'dotenv'
require 'pry'

Dotenv.load

app_name    = "SocialApp"
workspace   = "#{app_name}.xcworkspace"
company     = "NSScreencast"
company_id  = "com.nsscreencast"
scheme      = "#{app_name}"
progress    = ENV['progress'] != nil
output_dir  = "build"
test_target = "#{app_name}Tests"

build_task = XcodeBuild::Tasks::BuildTask.new do |t|
  t.sdk = "iphoneos"
  t.configuration = "Release"
  t.workspace = workspace
  t.scheme = scheme
  t.add_build_setting("ONLY_ACTIVE_ARCH", "NO")
  t.after_build do |build|
    built_products_dir = build.environment['BUILT_PRODUCTS_DIR']
    
    puts "WARNING: output_dir is nil.  Skipping to avoid blasting away the wrong folder" if output_dir.nil?
    puts "WARNING: built_products_dir could not be derived from the built output" if built_products_dir.nil?

    if output_dir && built_products_dir
      system("rm -rf #{output_dir} && mkdir -p #{output_dir}")
      system("cp -R #{built_products_dir}/* #{output_dir}")
    end
  end
  t.formatter = XcodeBuild::Formatters::ProgressFormatter.new if progress
end

task :prepare_for_test do
  build_task.sdk = "iphonesimulator"
  build_task.add_build_setting("TEST_AFTER_BUILD", "YES")
end

task :test => [:prepare_for_test, "xcode:cleanbuild"]

task :ci => [:build_ipa, :docs]

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

desc "Generates HTML documentation using appledoc"
task :docs do
  system <<-EOS
    appledoc \\
      --project-name #{app_name} \\
      --project-company #{company} \\
      --company-id #{company_id} \\
      --output docs \\
      --create-html \\
      --no-create-docset \\
      --ignore Pods \\
      --keep-intermediate-files .
  EOS
end

desc "Uploads the latest ipa to testflight"
task :publish_testflight do
  ipa = Dir["build/*.ipa"].first
  fail "No IPA found to upload!  Run bundle exec rake build_ipa first" if ipa.nil?
  
  dsym = Dir["build/*.app.dSYM.zip"].first
  fail "No zipped dSYM found!" if dsym.nil?
  
  upload_to_testflight(ipa, dsym)
end

def upload_to_testflight(ipa_file, dsym_file)
  api_token = ENV['testflight_api_token']
  team_token = ENV['testflight_team_token']
  
  raise "Please set the testflight_api_token environment variable" if api_token.nil?
  raise "Please set the testflight_team_token environment variable" if team_token.nil?
  
  cmd = <<-EOS
  /usr/bin/curl "http://testflightapp.com/api/builds.json" \\
    -F file=@"#{ipa_file}" \\
    -F dsym=@"#{dsym_file}" \\
    -F api_token="#{api_token}" \\
    -F team_token="#{team_token}" \\
    -F notes=@"RELEASE_NOTES"
  EOS
  system cmd
  
  puts
  puts "Uploaded build #{app_version} to testflight.  "
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