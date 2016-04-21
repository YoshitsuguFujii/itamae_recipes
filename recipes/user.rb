require "yaml"

SECRET_YML="secret.yml"

unless File.exists?(SECRET_YML)
  raise "secret.ymlを作成してください"
end
secret = YAML::load_file(SECRET_YML)

node[:groups].each do |group|
  group "group name" do
    groupname group[:name] # 任意指定。指定がない場合ブロック引数が利用される。
    gid group[:gid] # 任意指定
  end
end

node[:users].each do |user|
  user "create user" do
    action :create
    username user[:user]
    password secret[user[:user]]["password"]
    home "/home/#{user[:user]}"
    gid  user[:gid]
  end

  directory "/home/#{user[:user]}/.ssh" do
    owner user[:user]
    group user[:group]
    mode "700"
  end

  ssh_key = if File.exists?(user[:public_key])
              File.read(user[:public_key])
            else
              user[:public_key]
            end

  file "/home/#{user[:user]}/.ssh/authorized_keys" do
    content ssh_key
    owner user[:user]
    group user[:group]
    mode "600"
  end
end

# sudo可能にする
template "/etc/sudoers" do
  source "remote_files/sudoers"
  mode   "440"
  owner  "root"
  group  "root"
end

file "/etc/ssh/sshd_config" do
  mode "777"
  user "root"
  group "root"
end

file "/etc/ssh/sshd_config" do
  action :edit
  user "root"
  group "root"
  mode "600"
  block do |content|
    content.gsub!(/^PasswordAuthentication .+$/, "PasswordAuthentication no")
    #content.gsub!(/^PermitRootLogin.+$/, "PermitRootLogin no")
  end
end

service 'sshd' do
  action :restart
end
