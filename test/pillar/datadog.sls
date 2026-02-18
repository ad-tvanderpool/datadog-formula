datadog:
  config:
    api_key: aaaaaaaabbbbbbbbccccccccdddddddd
    site: datadoghq.com
    hostname: test

  integrations: {}

  checks:
    directory:
      config:
        instances:
          - directory: "/srv/pillar"
            name: "pillars"

  install_settings:
    agent_version: latest
