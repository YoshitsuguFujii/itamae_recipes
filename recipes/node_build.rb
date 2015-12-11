NDENV_DIR = "/home/#{node[:user]}/.ndenv"
NDENV_SCRIPT = "/etc/profile.d/ndenv.sh"

git NDENV_DIR do
  repository "git://github.com/riywo/ndenv.git"
  user node['ndenv']['user'] if user node['ndenv']['user']
  not_if "test -d #{NDENV_DIR}"
end

directory "#{NDENV_DIR}/plugins" do
  action :create
  not_if "test -d #{NDENV_DIR}/plugins"
end

git "#{NDENV_DIR}/plugins/node-build" do
  repository "git://github.com/riywo/node-build.git"
end

execute "set owner and mode for #{NDENV_DIR}" do
  command <<-EOH
    chown -R #{node[:user]}: #{NDENV_DIR}
    EOH
end

execute "expose ndenv path" do
  command <<-EOH
    echo 'export PATH="#{NDENV_DIR}/bin:$PATH"' >> #{NDENV_SCRIPT}
    echo 'eval "$(ndenv init -)"' >>  #{NDENV_SCRIPT}
  EOH
  not_if "echo $PATH | grep #{NDENV_DIR}"
end

node["ndenv"]["versions"].each do |version|
  execute "install node #{version}" do
    command <<-EOH
        source #{NDENV_SCRIPT}
        ndenv install #{version}
        ndenv rehash
        EOH
    user node['ndenv']['user'] if user node['ndenv']['user']
    not_if "source #{NDENV_SCRIPT}; ndenv versions | grep #{version}"
  end
end

execute "set global node #{node["ndenv"]["global"]}" do
  command <<-EOH
        source #{NDENV_SCRIPT}
        ndenv global #{node["ndenv"]["global"]}
        ndenv rehash
        EOH
    user node['ndenv']['user'] if user node['ndenv']['user']
    not_if "ndenv global | grep #{node["ndenv"]["global"]}"
end

execute "set environemt variables" do
  command <<-EOH
    echo 'export NODE_ENV=development' >> /home/#{node[:user]}/.zshenv
    echo 'export PATH="#{NDENV_DIR}/bin:$PATH"' >> /home/#{node[:user]}/.zshenv
    echo 'eval "$(ndenv init -)"'  >> /home/#{node[:user]}/.zshenv
  EOH
  not_if "cat /home/#{node[:user]}/.zshenv | grep 'export NODE_ENV'"
end
