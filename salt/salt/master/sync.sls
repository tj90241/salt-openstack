master-salt-run-sync:
  cmd.run:
    - name: salt-run saltutil.sync_all

    {# Force this to execute before anything in salt.master. #}
    - order: 1

master-salt-sync:
  module.run:
    - name: saltutil.sync_all

    {# Force this to execute before anything in salt.master. #}
    - order: 2
