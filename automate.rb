#!/opt/rh/ruby193/root/usr/bin/ruby
=begin
#################################################################

automate.rb

This method allow you to sync one of your Cloudforms automation
domain with a GIT repo of your choice.

by Marco Berube

#################################################################
=end


# BASE FOLDER
BASE="/git"

# GIT CONFIGURATION SETTINGS
GIT_USERNAME="<your_username>"   
GIT_PASSWORD="<your_password>"
GIT_REPO="CloudFormsPOC"
GIT_DOMAIN_ROOT="CloudFormsPOC/Automate"
GIT_URL="github.com/#{GIT_USERNAME}/#{GIT_REPO}.git"
GIT_BRANCH="master"

# CLOUDFORMS DOMAIN THAT YOU WANT TO SYNC ON GIT, 
# CURRENTLY LIMITED TO ONLY ONE DOMAIN FROM YOUR DATASTORE
CFME_DOMAIN="CloudFormsPOC"

# TEMPORARY FOLDER TO EXTRACT DATASTORE FILES
DSDUMP_PATH="/git/localdomains"


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
