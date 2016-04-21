package 'nginx' do
    action :install
end

group "group name" do
  groupname node[:nginx][:group_name]
  gid node[:nginx][:gid]
end

user "create user" do
  action :create
  username node[:nginx][:user_name]
  gid node[:nginx][:gid]
end

execute "ban login nginx user" do
  command "usermod -s /bin/false #{node[:nginx][:user_name]}"
end

template "/etc/nginx/nginx.conf" do
  source "templates/nginx.conf.erb"
end

service 'nginx' do
  action [:enable, :start]
end
