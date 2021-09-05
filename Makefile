# -*- mode: Makefile -*-
# vim:list:listchars=tab\:>-:

bootstrap-consul:
	@echo "Bootstrapping the Consul cluster..."
	@salt-run state.orch orch.bootstrap-consul
