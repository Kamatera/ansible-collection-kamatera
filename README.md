# Kamatera Ansible Collection

Ansible collection for management of Kamatera cloud compute resources

## Installation

* Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) version 2.9 or higher
* Install the Kamatera Ansible collection:
  * `ansible-galaxy collection install kamatera.kamatera`

## Getting Kamatera API keys

You can get the keys from the Kamatera Console under API > Keys

Set the keys in environment variables:

```
export KAMATERA_API_CLIENT_ID=
export KAMATERA_API_SECRET=
```

## Example playbooks

### Get available datacenter locations

Write the available datacenter locations to a JSON file at `/tmp/kamatera_datacenters.json`

```
- name: Get capabilities
  hosts: localhost
  tasks:
    - kamatera.kamatera.kamatera_compute_options: {}
      register: datacenters
    - copy:
        content: "{{ datacenters.datacenters | to_nice_json }}"
        dest: "/tmp/kamatera_datacenters.json"
```

### Get available server capabilities

Write the available server capabilities for the selected datacenter to JSON files at:

- `/tmp/kamatera_datacenter_capabilities.json`
- `/tmp/kamatera_datacenter_images.json`

```
- name: Get capabilities
  hosts: localhost
  tasks:
    - kamatera.kamatera.kamatera_compute_options:
        datacenter: "{{ datacenter }}"
      register: capabilities
    - copy:
        content: "{{ capabilities.images | to_nice_json }}"
        dest: "/tmp/kamatera_datacenter_images.json"
    - copy:
        content: "{{ capabilities.capabilities | to_nice_json }}"
        dest: "/tmp/kamatera_datacenter_capabilities.json"
```

### Server provisioning and operations

Create a server, perform various operations on it and terminate it 

```
- name: Provisioning and operations example
  hosts: localhost
  tasks:
    - kamatera.kamatera.kamatera_compute:
        server_names: ['{{ server_name }}_1','{{ server_name }}_2']
        state: present
        datacenter: "{{ datacenter }}"
        image: "{{ image }}"
        cpu_type: "{{ cpu_type }}"
        cpu_cores: "{{ cpu_cores }}"
        ram_mb: "{{ ram_mb }}"
        disk_size_gb: "{{ disk_size_gb }}"
        extra_disk_sizes_gb:
          - "{{ disk_size_2_gb }}"
      register: res
    - kamatera.kamatera.kamatera_compute:
        server_names: '{{ res.server_names }}'
        state: restarted
      register: res
    - kamatera.kamatera.kamatera_compute:
        server_names: '{{ res.server_names }}'
        state: stopped
      register: res
    - kamatera.kamatera.kamatera_compute:
        server_names: '{{ res.server_names }}'
        state: running
      register: res
    - kamatera.kamatera.kamatera_compute:
        server_names: '{{ res.server_names }}'
        state: absent
```
