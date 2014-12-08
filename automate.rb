#!/opt/rh/ruby193/root/usr/bin/ruby
=begin
#################################################################

automate.rb

This method allow you to sync one of your Cloudforms automation
domain with a GIT repo of your choice.

by Marco Berube

#################################################################
=end

require 'yaml'

yaml_path = File.dirname($0) + '/automate.yaml'
automate_config = YAML.load_file(yaml_path)

# GENERAL CONFIGURATION
BASE = automate_config['general']['base']
DSDUMP_PATH = automate_config['general']['temp']

# GIT CONFIGURATION
GIT_USERNAME = automate_config['git']['username']
GIT_PASSWORD = automate_config['git']['password']
GIT_REPO = automate_config['git']['repo']
GIT_DOMAIN_ROOT = automate_config['git']['domain_root']
GIT_URL = automate_config['git']['url'] + "/#{GIT_USERNAME}/#{GIT_REPO}.git"
GIT_BRANCH = automate_config['git']['branch']

# CFME CONFIGURATION
CFME_DOMAIN = automate_config['cfme']['domain']


#
#   EXPORT CLOUDFORMS DATASTORE IN A TEMPORARY FOLDER : #{DSDUMP_PATH}
#
def dsdump()
	system ("cd /var/www/miq/vmdb && script/rails runner script/rake evm:automate:backup BACKUP_ZIP_FILE=#{BASE}/backup_exported.zip OVERWRITE=true")
	system ("rm -rf #{DSDUMP_PATH}")
	system ("mkdir -p #{DSDUMP_PATH}")
	system ("unzip /git/backup_exported.zip -d #{DSDUMP_PATH}/")
end



case ARGV[0]

	when "dsdump"
		dsdump()

	when "git-pull"

		system ("rm -rf #{BASE}/#{GIT_USERNAME}")
		system ("mkdir -p #{BASE}/#{GIT_USERNAME}")
		system ("cd #{BASE}/#{GIT_USERNAME} && git clone -b #{GIT_BRANCH} https://#{GIT_URL}")
		system ("rsync -av #{BASE}/#{GIT_USERNAME}/#{GIT_DOMAIN_ROOT}/#{CFME_DOMAIN} #{DSDUMP_PATH}")
		system ("cd #{DSDUMP_PATH} && zip -r #{BASE}/backup_imported.zip ./*")
	    system ("cd /var/www/miq/vmdb && script/rails runner script/rake evm:automate:restore BACKUP_ZIP_FILE=#{BASE}/backup_imported.zip")

	when "git-push"

		dsdump()
		system ("rsync -av #{DSDUMP_PATH}/#{CFME_DOMAIN} #{BASE}/#{GIT_USERNAME}/#{GIT_DOMAIN_ROOT}")
		system ("cd #{BASE}/#{GIT_USERNAME}/#{GIT_REPO}/ && git add -A")
		system ("cd #{BASE}/#{GIT_USERNAME}/#{GIT_REPO}/ && git commit -m 'Cloudforms Automate Model Sync'")
		system ("cd #{BASE}/#{GIT_USERNAME}/#{GIT_REPO}/ && git remote set-url origin https://#{GIT_USERNAME}:#{GIT_PASSWORD}@#{GIT_URL}")
		system ("cd #{BASE}/#{GIT_USERNAME}/#{GIT_REPO}/ && git push")

	else

		puts "automate <subcommand>"
		puts "	dsdump 		Datastore dump in a temporary folder: #{DSDUMP_PATH}"
		puts "	git-pull	Pull git updates into Cloudforms DB"
		puts "	git-push	Push Cloudforms DB updates to git repo"

end
