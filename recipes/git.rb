package "git"
package "tig"

execute "add path to zshenv" do
  command <<-EOF
    git config --global color.ui auto
    git config --global user.name "#{node[:git][:name]}"
    git config --global user.email "#{node[:git][:email]}"
  EOF
end
