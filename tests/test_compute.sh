#!/usr/bin/env bash

( [ "${KAMATERA_API_CLIENT_ID}" = "" ] || [ "${KAMATERA_API_SECRET}" == "" ] ) && echo missing required env vars && exit 1

[ "${KAMATERA_API_URL}" != "" ] && echo KAMATERA_API_URL=${KAMATERA_API_URL}

rm -rf tests/output && mkdir -p tests/output &&\
ansible-playbook tests/compute_datacenters_playbook.yml -e output_dir=`pwd`/tests/output
[ "$?" != "0" ] && echo failed to run compute_datacenters_playbook && exit 1

python -c "
import json
with open('tests/output/kamatera_datacenters.json') as f:
  datacenters = json.load(f)
assert set(datacenters[0].keys()) == set(['category', 'subCategory', 'name', 'id']), set(datacenters[0].keys())
for k,v in datacenters[0].items():
  assert len(v) > 1, '%s=%s' % (k, v)
"
[ "$?" != "0" ] && echo failed to test datacenters output && exit 1

ansible-playbook tests/compute_options_playbook.yml -e output_dir=`pwd`/tests/output -e datacenter=EU-LO
[ "$?" != "0" ] && echo failed to run compute_options_playbook && exit 1

python -c "
import json
with open('tests/output/kamatera_datacenter_capabilities.json') as f:
  capabilities = json.load(f)
assert set(capabilities.keys()) == set(['cpuTypes', 'defaultMonthlyTrafficPackage', 'diskSizeGB', 'monthlyTrafficPackage']), set(capabilities.keys())
for k,v in capabilities.items():
  assert len(v) > 0, '%s=%s' % (k,v)
with open('tests/output/kamatera_datacenter_images.json') as f:
  images = json.load(f)
assert set(images[0].keys()) == set(['datacenter', 'code', 'name', 'osDiskSizeGB', 'ramMBMin', 'os', 'id']), set(images[0].keys())
for k,v in images[0].items():
  if k == 'osDiskSizeGB':
    assert v > 0, '%s=%s' % (k,v)
  else:
    assert len(v) > 0, '%s=%s' % (k,v)
for image in images:
  if image['os'] == 'Ubuntu' and image['code'] == '18.04 64bit':
    image_id = image['id']
print(' -e datacenter=EU-LO -e image=%s -e cpu_type=%s -e cpu_cores=%s -e ram_mb=%s -e disk_size_gb=%s -e disk_size_2_gb=%s ' % (
  image_id, capabilities['cpuTypes'][0]['id'], capabilities['cpuTypes'][0]['cpuCores'][2],
  capabilities['cpuTypes'][0]['ramMB'][4], capabilities['diskSizeGB'][4], capabilities['diskSizeGB'][2]
))
" > tests/output/compute_args
[ "$?" != "0" ] && echo failed to test compute options output && exit 1

ansible-playbook tests/compute_playbook.yml -e output_dir=`pwd`/tests/output `cat tests/output/compute_args`
[ "$?" != "0" ] && echo failed to run compute_playbook && exit 1

echo Great Success
exit 0