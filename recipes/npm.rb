execute "npm install" do
  command <<-EOF
    source ~/.zshenv
    npm install -g bower grunt-cli
  EOF
  user node['ndenv']['user'] if user node['ndenv']['user']
  not_if "grunt --version"
end
