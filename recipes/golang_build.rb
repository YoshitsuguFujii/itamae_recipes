ENV_FILE = "/home/#{node[:user]}/.zshenv"
GO_DIR = "/home/#{node[:user]}/.go"

git "clone goenv" do
  repository "https://github.com/wfarr/goenv.git"
  destination "/home/#{node[:user]}/.goenv"
  user node[:user]
end

execute "modify path for goenv" do
  command <<-EOF
    echo 'export PATH=/home/#{node[:user]}/.goenv/bin:\$PATH' >> #{ENV_FILE}
    echo 'export GOPATH=/home/#{node[:user]}/.goenv/bin:\$PATH' >> #{ENV_FILE}
    echo 'eval \"\$(goenv init -)\"' >> #{ENV_FILE}
    echo 'export GOENVGOROOT=$HOME/.goenvs' >> #{ENV_FILE}
    echo 'export GOENVTARGET=$HOME/bin' >> #{ENV_FILE}
    echo 'export GOENVHOME=$HOME/workspace' >> #{ENV_FILE}
    echo 'export GOPATH=$HOME/go/third-party:$HOME/go/my-project' >> #{ENV_FILE}
    echo 'export PATH=$HOME/go/third-party/bin:$HOME/go/my-project/bin:$PATH' >> #{ENV_FILE}
  EOF
  not_if "cat #{ENV_FILE} | grep 'GOPATH' "
end

node["goenv"]["versions"].each do |version|
  execute "install golang #{version}" do
    command <<-EOH
        source #{ENV_FILE}
        goenv install #{version}
        goenv rehash
        EOH
    user node[:user] if user node['user']
    not_if "goenv versions | grep #{version}"
  end
end

execute "set global go #{node["goenv"]["global"]}" do
  command <<-EOH
        source #{ENV_FILE}
        goenv global #{node["goenv"]["global"]}
        goenv rehash
        EOH
  user node[:user] if user node['user']
  not_if "goenv global | grep #{node["goenv"]["global"]}"
end

execute "install go package" do
  command <<-EOH
    source #{ENV_FILE}
    go get github.com/mattn/gom
    go get github.com/pilu/fresh
  EOH
  user node[:user] if user node['user']
end

directory "bin" do
  owner node[:user]
  group node[:group]
end

execute "install direnv" do
  command <<-EOH
    source #{ENV_FILE}
    curl -L https://github.com/direnv/direnv/releases/download/v2.6.0/direnv.linux-amd64 > ~/bin/direnv
    chmod +x ~/bin/direnv
    echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
  EOH
  user node[:user] if user node['user']
  not_if "which direnv"
end
