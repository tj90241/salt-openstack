# -*- mode: Makefile -*-
# vim:list:listchars=tab\:>-:

bootstrap-consul:
	salt-run state.orch orch.bootstrap-consul
