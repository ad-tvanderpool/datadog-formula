{% from "datadog/map.jinja" import datadog_config, datadog_install_settings, datadog_integrations, datadog_checks with context %}
{% set config_file_path = '%s/%s'|format(datadog_install_settings.config_folder, datadog_install_settings.config_file) -%}

datadog_yaml_installed:
  file.managed:
    - name: {{ config_file_path }}
    - source: salt://datadog/files/datadog.yaml.jinja
    - user: dd-agent
    - group: dd-agent
    - mode: 600
    - template: jinja
    - require:
      - pkg: datadog-pkg

{# Manage third-party integrations (conf.d) #}
{% if datadog_integrations is defined and datadog_integrations | length %}
{% for integration_name in datadog_integrations %}

# Make sure the integration directory is present
datadog_{{ integration_name }}_integration_folder_installed:
  file.directory:
    - name: {{ datadog_install_settings.confd_path }}/{{ integration_name }}.d
    - user: dd-agent
    - group: root
    - mode: 700

datadog_{{ integration_name }}_integration_installed:
  file.managed:
    - name: {{ datadog_install_settings.confd_path }}/{{ integration_name }}.d/conf.yaml
    - source: salt://datadog/files/conf.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_name: {{ integration_name }}

{%- if datadog_integrations[integration_name].version is defined %}

datadog_integration_{{ integration_name }}_version_{{ datadog_integrations[integration_name].version }}_installed:
  cmd.run:
    - name: sudo -u dd-agent datadog-agent integration install datadog-{{ integration_name }}=={{ datadog_integrations[integration_name].version }}
    - unless: sudo -u dd-agent datadog-agent integration freeze | grep datadog-{{ integration_name }}=={{ datadog_integrations[integration_name].version }}
{%- endif %}

{% endfor %}
{% endif %}

{# Manage custom checks (check.d) #}
{% if datadog_checks is defined and datadog_checks | length %}
{% for check_name in datadog_checks %}

# Make sure the check directory is present
datadog_{{ check_name }}_check_folder_installed:
  file.directory:
    - name: {{ datadog_install_settings.checkd_path }}/{{ check_name }}.d
    - user: dd-agent
    - group: root
    - mode: 700

datadog_{{ check_name }}_check_installed:
  file.managed:
    - name: {{ datadog_install_settings.checkd_path }}/{{ check_name }}.d/conf.yaml
    - source: salt://datadog/files/conf.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_name: {{ check_name }}

{%- if datadog_checks[check_name].version is defined %}

datadog_check_{{ check_name }}_version_{{ datadog_checks[check_name].version }}_installed:
  cmd.run:
    - name: sudo -u dd-agent datadog-agent integration install datadog-{{ check_name }}=={{ datadog_checks[check_name].version }}
    - unless: sudo -u dd-agent datadog-agent integration freeze | grep datadog-{{ check_name }}=={{ datadog_checks[check_name].version }}
{%- endif %}

{% endfor %}
{% endif %}

{% set install_info_path = '%s/install_info'|format(datadog_install_settings.config_folder) -%}
install_info_installed:
  file.managed:
    - name: {{ install_info_path }}
    - source: salt://datadog/files/install_info.jinja
    - user: dd-agent
    - group: dd-agent
    - mode: 600
    - template: jinja
    - require:
      - pkg: datadog-pkg
