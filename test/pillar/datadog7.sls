datadog:
  config:
    api_key: aaaaaaaabbbbbbbbccccccccdddddddd
    site: datadoghq.com
    hostname: test-7

  integrations:
    # Test installing a third-party integration
    bind9:
      config:
        instances:
          - {}
      version: 1.0.0

  checks:
    directory:
      config:
        instances:
          - directory: "/srv/pillar"
            name: "pillars"

  install_settings:
    agent_version: latest
