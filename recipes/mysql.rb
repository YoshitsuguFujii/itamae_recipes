# mysql
package 'http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm' do
  not_if 'rpm -q mysql-community-release-el6-5'
end

%w( mysql-community-server mysql-community-devel ).each do |pkg|
  package pkg
end

utf8mb4_settting = <<"EOS"

[mysqld]
character-set-server = utf8mb4
character-set-client-handshake  = FALSE
character_set_server            = utf8mb4
collation_server                = utf8mb4_unicode_ci
innodb_file_format = Barracuda
innodb_file_per_table = 1
innodb_large_prefix

[client]
default-character-set=utf8mb4

[mysql]
default-character-set=utf8mb4
EOS

execute "set db charset to utf8mb4" do
  command <<-EOF
    echo '#{utf8mb4_settting}' >> /etc/my.cnf
  EOF
end

service 'mysqld' do
  action [:start, :enable]
end

execute "allow remote host access" do
  # MySQLにリモートホストから接続できるようにする -> http://xyk.hatenablog.com/entry/2013/11/08/142548
  command "mysql -e \"grant all privileges on *.* to root@'192.168.%'\"";
end

