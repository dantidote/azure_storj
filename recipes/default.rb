#
# Cookbook:: azure-storj
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


package 'git'
package 'python'
package 'build-essential'

include_recipe 'chef-client'

# bash 'download_npm' do
# 	user 'storj'
# 	environment ({'HOME' => '/home/storj', 'USER' => 'storj' })
# 	code <<-EOH
# 	HOME=/home/storj
# 	wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
# 	EOH
# end

# bash 'install_npm' do
# 	code <<-EOH
# 	export NVM_DIR="/home/storj/.nvm"
#     [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# 	set
# 	nvm install --lts
# 	npm install --global storjshare-daemon
# 	EOH
# 	user 'storj'
# end

ssh_authorize_key 'hermes' do
  key 'AAAAB3NzaC1yc2EAAAABJQAAAQEAqc66AqvoiqAu2QWwQGgj9swLZXjXAjtT/4FRkiVcynfQGDXqZ7s9lgHk9/VUKfB2Mk+XJ8hhEu0j14/UyM6i5HGZogCBLnBKyObQHq4dHjN0XP4oSdqEAGkM7UjrmmhBdLl0EIlgQUVdQQFpoCBBG922iBeDCIkhG1S59qLUls2mtEvpQ2KYUfReXHTMS2Vk1I6pdFhk7Vz4DP9yH72no/VMFADll1zydi1EEadxdSEyMWfW3VdTkC2lsIHaQ3LLQAks0otA7Yp825w+d1b8qaOlAIcOaasjmKemtpMFfoKXpFEJiwC64J04SJgMlfE4xaWbDdWfDYQ1bDnORl9u6Q=='
  user 'storj'
end

ssh_authorize_key 'work' do
  key 'AAAAB3NzaC1yc2EAAAABJQAAAQEAynorG4FRev4EImn7ajdT/VEaOyDWj1B9Nku/ZJB+YqjKuULItagdlSrRziJQC11tDzrP6n9E8MuGhbQrT8LhJuka47Bhu5wT1BeIAmQOcG6tqx3QHUTdcQ+o+BjeeIcj45PJoU0jNAgOQN1lvahTgbxfNtdchxALa8XId2M4ZW4N7SBLNlV/M0anRwygrUmgygRR2CFnju/sKIKc8pbTXjkUXelf4aw+13ykcyZWsl/qittNgHS37CnLT2D/3qRb6jjcdjvoG+XvggJKz02SIiPWYzx4pS6ehC1xYgEoTZj42/tspfTrvby4FoBev5k+1VqhpIQBpi1MecjJbUvgPw=='
  user 'storj'
end

filesystem 'storj' do
	fstype 'ext4'
	device '/dev/sdc'
	mount '/media/storage'
	action [:create, :enable, :mount]
end

bash 'generate storj config'do
  user 'storj'
  code 'storjshare create --storj "0xa596b226f7d9fc2a5899d2a514b1ca3992aaac38" --storage /media/storage/ --size 0.9TB --rpcaddress `curl ifconfig.co` --manualforwarding --noedit -o ~/storj.conf'
  not_if { ::File.exist?('~/storj.conf') }
end

bash 'start storjshare daemon' do
	user 'storj'
  environment ({'HOME' => '/home/storj', 'USER' => 'storj', 'NVM_DIR' => '/home/storj/.nvm' , 'PATH' => "/home/storj/.nvm/versions/node/v8.9.1/bin/:#{ENV['PATH']}" })
	code '/home/storj/.nvm/versions/node/v8.9.1/bin/storjshare daemon'
end

bash 'start storjshare client' do
	user 'storj'
	environment ({'HOME' => '/home/storj', 'USER' => 'storj', 'NVM_DIR' => '/home/storj/.nvm', 'PATH' => "/home/storj/.nvm/versions/node/v8.9.1/bin/:#{ENV['PATH']}" })
	code '/home/storj/.nvm/versions/node/v8.9.1/bin/storjshare start -c /home/storj/storj.conf'
end
