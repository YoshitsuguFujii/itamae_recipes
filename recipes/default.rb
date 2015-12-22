# SELinux disabled
execute 'setenforce 0' do
  not_if 'getenforce | grep Disabled'
end

file '/etc/selinux/config' do
  action :edit
  block do |content|
    next if content =~ /^SELINUX=disabled/
    content.gsub!(/^SELINUX=.*/, "SELINUX=disabled")
  end
end

# update
execute "update yum repo" do
  command "yum -y update"
end

package "epel-release"
package "gcc"
package "openssl-devel"
package "libyaml-devel"
package "readline-devel"
package "zlib-devel"
package "vim"
package "tar"
package "mysql-devel"
package "zsh"
package "libxml2-devel"
package "libxslt-devel"
package "lsof"

execute "change default shell to zsh" do
  user node[:user]
  command "sudo usermod -s /bin/zsh #{node[:user]}"
end

package "ctags"
package "tmux"
package 'http://swiftsignal.com/packages/centos/6/x86_64/the-silver-searcher-0.13.1-1.el6.x86_64.rpm' do
  not_if "ag --version"
end

execute 'install ajenti' do
  command "curl https://raw.githubusercontent.com/ajenti/ajenti/1.x/scripts/install-rhel.sh | sh"
  not_if "rpm -q ajenti"
end

# 必要ならいれる
# package "java-1.7.0-openjdk"

redis_version = nil
package 'redis' do
  version redis_version unless redis_version.nil?
  options '--enablerepo=epel'
end

include_recipe 'git.rb'
include_recipe 'mysql.rb'
include_recipe 'rtn_rbenv::system'
include_recipe 'node_build.rb'
include_recipe 'npm.rb'
include_recipe 'golang_build.rb'
# include_recipe 'audit.rb'
include_recipe 'postfix.rb'

execute "install peco" do
  command "source ~/.zshenv && go get github.com/peco/peco/cmd/peco"
  user node[:user]
  not_if "peco --version"
end

######## 設定に関するブロック
%w(.zshrc .vimrc).each do |rc|
  remote_file "/home/#{node[:user]}/#{rc}" do
    user node[:user]
    source "./remote_files/#{rc}"
    owner node[:user]
    group node[:group]
  end
end

zshenv_setting = <<"EOS"
export NODE_ENV=development
export LC_ALL=en_US.UTF-8

export RBENV_ROOT=/home/#{node[:user]}/.rbenv
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"
eval "$(rbenv init -)"
EOS
execute "add path to zshenv" do
  user node[:user]
  command <<-EOF
    echo '#{zshenv_setting}' >> /home/#{node[:user]}/.zshenv
    chown #{node[:user]}:#{node[:user]} /home/#{node[:user]}/.zshenv
  EOF
  not_if "cat /home/#{node[:user]}/.zshenv | grep '#{zshenv_setting.split("\n").first}'"
end

# vim persistent_undo
directory "~/.vimundo" do
  user node[:user]
  action :create # デフォルトのため記載不要だが書いたほうが可読性が高い
  owner node[:user]
  group node[:group]
end


######## ファイアーウォール
#ip_tables_setting = <<"EOS"
#iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
#EOS
#execute "iptables setting" do
#  command ip_tables_setting
#end


######## サービスに関連するブロック
service 'redis' do
  action [:start, :enable]
end

service 'ajenti' do
  action [:start, :enable]
end
