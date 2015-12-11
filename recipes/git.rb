package "curl-devel"
package "expat-devel"
package "gettext-devel"
package "openssl-devel"
package "zlib-devel"
package "perl-ExtUtils-MakeMaker"
package "wget"

GIT_VERSION = "2.4"

execute "delete git" do
  command <<-EOH
    sudo yum -y erase git
  EOH
  user node[:user] if user node['user']
  not_if "git --version | grep #{GIT_VERSION}"
end

execute "install git" do
  command <<-EOH
    wget https://www.kernel.org/pub/software/scm/git/git-#{GIT_VERSION}.0.tar.gz
    tar zxvf git-#{GIT_VERSION}.0.tar.gz
    cd git-#{GIT_VERSION}.0
    sudo make prefix=/usr/local all
    sudo make prefix=/usr/local install
  EOH
  user node[:user] if user node['user']
  not_if "git --version | grep #{GIT_VERSION}"
end

package "tig"
execute "add path to zshenv" do
  user node[:user]
  command <<-EOF
    git config --global color.ui auto
    git config --global user.name "#{node[:git][:name]}"
    git config --global user.email "#{node[:git][:email]}"
  EOF
end
