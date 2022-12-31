# -*- mode: Makefile -*-
# vim:list:listchars=tab\:>-:

bootstrap-consul:
	@echo "Bootstrapping the Consul cluster..."
	@salt-run state.orch orch.bootstrap-consul

upgrade-salt:
	@echo "Upgrading Salt Minions..."
	@salt \* cmd.shell 'cd /tmp; nohup /bin/bash -c "killall salt-minion; systemctl stop salt-minion; apt-get install -y salt-minion; systemctl start salt-minion" &'
