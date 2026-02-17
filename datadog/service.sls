{% from "datadog/map.jinja" import datadog_install_settings, datadog_integrations, datadog_checks with context %}
{% set config_file_path = '%s/%s'|format(datadog_install_settings.config_folder, datadog_install_settings.config_file) -%}

datadog-agent-service:
  service.running:
    - name: datadog-agent
    - enable: True
    - watch:
      - pkg: datadog-agent
      - file: {{ config_file_path }}
{%- if datadog_integrations | length %}
      - file: {{ datadog_install_settings.confd_path }}/*
{% endif %}
{%- if datadog_checks | length %}
      - file: {{ datadog_install_settings.checkd_path }}/*
{% endif %}
{%- if datadog_integrations is defined %}
{%- for integration_name in datadog_integrations %}
{%- if datadog_integrations[integration_name].version is defined %}
      - cmd: datadog_integration_{{ integration_name }}_version_{{ datadog_integrations[integration_name].version }}_installed
{% endif %}
{% endfor %}
{% endif %}
{%- if datadog_checks is defined %}
{%- for check_name in datadog_checks %}
{%- if datadog_checks[check_name].version is defined %}
      - cmd: datadog_check_{{ check_name }}_version_{{ datadog_checks[check_name].version }}_installed
{% endif %}
{% endfor %}
{% endif %}
