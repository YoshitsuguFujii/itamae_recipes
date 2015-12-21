
# stop sendmail and chkconfig off
execute 'stop_sendmail' do
  command <<-EOC
    service sendmail stop
    chkconfig sendmail off
  EOC
  only_if "chkconfig --list | grep sendmail | grep 3:on"
end

# install postfix
package "postfix"

# set postfix as MTA
execute 'set_postfix_as_mta' do
  command <<-EOC
    alternatives --set mta /usr/sbin/sendmail.postfix
  EOC
  not_if "ls -la /etc/alternatives/mta | grep /usr/sbin/sendmail.postfix"
end

# backup /etc/postfix/main.cf
main_cf = "/etc/postfix/main.cf"

execute 'move_main_cf_original' do
  command <<-EOC
    mv #{main_cf} #{main_cf}.org_#{Time.now.strftime("%Y%m%d")}
  EOC
  only_if "test -e '#{main_cf}'"
end

# create /etc/postfix/main.cf from template
template main_cf do
  source "templates/main.cf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, 'service[postfix]'
end

# chkconfig on & set service & start
execute 'chkconfig_add_postfix' do
  command <<-EOC
    chkconfig --add postfix
  EOC
  not_if "chkconfig --list postfix"
end

execute "Maikdir" do
  command <<-EOC
    mkdir -p /etc/skel/Maildir/{new,cur,tmp}
    chmod -R 700 /etc/skel/Maildir/
  EOC
end

service "postfix" do
  action %i(enable start)
end
