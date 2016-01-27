package "monit"

slackbot_setting = <<"EOS"
check process slackbot with pidfile /home/yoshitsugu/go/my-project/slackbot/current/tmp.pid
  start program = "/home/yoshitsugu/go/my-project/slackbot/current/bin/start.sh"
    as uid #{node[:user]} and gid #{node[:group]}
  if 5 restart within 5 cycles then timeout
EOS

file "/etc/monit.d/slackbot" do
  mode "644"
  content slackbot_setting
  user "root"
  group "root"
  notifies :reload, "service[monit]"
end

template '/etc/monit.conf' do
  source "templates/monit.conf.erb"
  owner "root"
  group "root"
  mode "700"
  notifies :reload, "service[monit]"
end

service "monit" do
  action %i(enable start)
end
